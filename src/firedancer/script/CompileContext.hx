package firedancer.script;

import banker.vector.Vector;
import firedancer.vm.ProgramPackage;
import firedancer.assembly.Instruction;
import firedancer.assembly.AssemblyCode;
import firedancer.assembly.ValueType;
import firedancer.assembly.Optimizer;
import firedancer.assembly.Assembler;
import firedancer.script.expression.GenericExpression;
#if debug
import sneaker.print.Printer.println;
#end

/**
	Context for compiling bullet patterns.
**/
class CompileContext {
	/**
		Manages available local variables.
	**/
	public final localVariables: LocalVariableTable;

	/**
		Stack for storing the label ID to be used for the next label.
	**/
	public var nextLabelIdStack: Array<UInt> = [UInt.zero];

	/**
		List of `AssemblyCode` that should be able to retrieved by an `UInt` ID.
	**/
	final codeList: Array<AssemblyCode> = [];

	/**
		Mapping from names to ID numbers of `AssemblyCode` instances.
	**/
	final nameIndexMap = new Map<String, UInt>();

	/**
		Stack of injection code.
		@see `pushInjectionCode()`
	**/
	final injectionStack: Array<AssemblyCode> = [];

	public function new() {
		this.localVariables = new LocalVariableTable(this);
	}

	/**
		Registers `code` in `this` context (if absent)
		so that it can be retrieved by a specific ID number.
		@return The ID for `code`.
	**/
	public function setCode(code: AssemblyCode): UInt {
		final codeList = this.codeList;

		if (codeList.has(code))
			return codeList.indexOf(code, 0);

		final id = codeList.length;
		codeList.push(code);

		return id;
	}

	/**
		Registers `code` in `this` context so that it can be retrieved by `name` as well as its ID.
	**/
	public function setNamedCode(code: AssemblyCode, name: String): UInt {
		final index = this.setCode(code);

		final map = this.nameIndexMap;
		#if debug
		if (map.exists(name)) throw 'Duplicate pattern name: $name';
		#end
		map.set(name, index);

		return index;
	}

	/**
		@return The entire injection code that have been pushed by `pushInjectionCode()`.
		The order is reversed so that the last pushed code comes first.
		@see `pushInjectionCode()`
	**/
	public inline function getInjectionCode(): AssemblyCode {
		final code = this.injectionStack.copy();
		code.reverse();
		return code.flatten();
	}

	/**
		Pushes `code` so that it is injected in every frame
		(i.e. before every `Break` operation or some sort of equivalent)
		within the current node list being compiled.
		@param code
	**/
	public inline function pushInjectionCode(code: AssemblyCode): Void
		this.injectionStack.push(code);

	/**
		Pops the injection code that was previously pushed by `pushInjectionCode()`.
	**/
	public inline function popInjectionCode(): Void
		this.injectionStack.pop();

	/**
		Creates a `ProgramPackage` instance.
	**/
	public function createPackage(optimize = true): ProgramPackage {
		var codeList = this.codeList;
		if (optimize) codeList = codeList.map(Optimizer.optimize);

		#if debug
		for (id in 0...codeList.length) {
			println('[ASSEMBLY] ID: $id');
			println('${codeList[id].toString()}\n');
		}
		#end

		final assembled = codeList.map(Assembler.assemble);
		final bytecodeList = Vector.fromArrayCopy(assembled);

		return new ProgramPackage(bytecodeList, this.nameIndexMap);
	}
}

class LocalVariableTable {
	/**
		Stack of `LocalVariable` instances.
	**/
	final addressStack: Array<LocalVariable>;

	/**
		Stack for storing the size of `addressStack` at the beginning of each scope.
	**/
	final variableCountStack: Array<UInt>;

	/**
		Address offset value for the next pushed variable.
	**/
	var address: UInt;

	final context: CompileContext;

	public function new(context: CompileContext) {
		this.addressStack = [];
		this.variableCountStack = [];
		this.address = UInt.zero;
		this.context = context;
	}

	/**
		Starts a new scope.
	**/
	public function startScope(): Void
		this.variableCountStack.push(this.addressStack.length);

	/**
		Ends the current scope.
		Pops all variables that were pushed after the last call of `startScope()`.
	**/
	public function endScope(): Void {
		final maybeTargetSize = variableCountStack.pop();
		if (maybeTargetSize.isNone()) throw "Called endScope() before startScope().";
		final targetSize = maybeTargetSize.unwrap();

		final addressStack = this.addressStack;
		while (targetSize < addressStack.length) addressStack.pop();
	}

	/**
		Registers a local variable that is valid in the current scope.
		@return The address that can be used for the registered local variable.
	**/
	public function push(name: String, type: ValueType): UInt {
		final address = this.address;

		this.addressStack.push({
			name: name,
			type: type,
			address: address,
			context: this.context
		});

		this.address = address + type.size;

		return address;
	}

	/**
		@return `LocalVariable` that was declared in the narrowest scope.
		Throws error if a variable with `name` was never declared.
	**/
	public function get(name: String): LocalVariable {
		final addressStack = this.addressStack;
		var i = addressStack.length.int() - 1;

		while (i >= 0) {
			final variable = addressStack[i];
			if (variable.name == name) return variable;
			--i;
		}

		throw 'Unknown local variable: $name';
	}
}

@:structInit class LocalVariable {
	public final name: String;
	public final type: ValueType;
	public final address: UInt;

	final context: CompileContext;

	/**
		Creates an `AssemblyCode` that assigns the value of `this` local variable
		to the current volatile int/float.
	**/
	public function loadToVolatile(): AssemblyCode {
		return switch this.type {
		case Int: [Load(Int(Var(address)))];
		case Float: [Load(Float(Var(address)))];
		case Vec: throw "Local variable of vector type is not supported.";
		};
	}

	/**
		Creates an `AssemblyCode` that assigns `value` to the local variable specified by `this`.

		This does not check the type of `value` and it should be checked/determined before being passed.
	**/
	public function setValue(value: GenericExpression): AssemblyCode {
		final store: Instruction = switch this.type {
		case Int:
			Store(Int(Reg), address);
		case Float:
			Store(Float(Reg), address);
		case Vec:
			throw "Local variable of vector type is not supported.";
		}

		return [
			value.loadToVolatile(context),
			[store]
		].flatten();
	}

	/**
		Creates an `AssemblyCode` that adds `value` to the local variable specified by `this`.
	**/
	public function addValue(value: GenericExpression): AssemblyCode {
		final store: Instruction = switch this.type {
		case Int:
			Add(Int(Var(address), Reg));
		case Float:
			Add(Float(Var(address), Reg));
		case Vec:
			throw "Local variable of vector type is not supported.";
		}

		return [
			value.loadToVolatile(context),
			[store]
		].flatten();
	}

	/**
		Creates an `AssemblyCode` that increments the local variable specified by `this`.

		Available only if `this.type` is `Int`.
	**/
	public function increment(): AssemblyCode {
		switch this.type {
		case Int:
		default: throw "Cannot increment local variable that is not an integer.";
		}

		return [Increment(address)];
	}

	/**
		Creates an `AssemblyCode` that decrements the local variable specified by `this`.

		Available only if `this.type` is `Int`.
	**/
	public function decrement(): AssemblyCode {
		switch this.type {
		case Int:
		default: throw "Cannot decrement local variable that is not an integer.";
		}

		return [Decrement(address)];
	}
}
