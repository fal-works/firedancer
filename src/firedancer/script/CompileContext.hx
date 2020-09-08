package firedancer.script;

import firedancer.assembly.Instruction;
import firedancer.assembly.AssemblyCode;
import firedancer.assembly.ValueType;
import firedancer.assembly.AssemblyCodePackage;
import firedancer.script.expression.GenericExpression;

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

		final existingId = codeList.indexOfFirst(cur -> cur.equals(code));
		if (existingId.isSome()) return existingId.unwrap();

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
		Creates an `AssemblyCodePackage` instance.
	**/
	public function createPackage(): AssemblyCodePackage {
		return {
			codeList: this.codeList,
			nameIndexMap: this.nameIndexMap
		};
	}
}

class LocalVariableTable {
	/**
		Stack of `LocalVariable` instances.
	**/
	final variableStack: Array<LocalVariable>;

	/**
		Stack for storing the size of `variableStack` at the beginning of each scope.
	**/
	final variableCountStack: Array<UInt>;

	final context: CompileContext;

	public function new(context: CompileContext) {
		this.variableStack = [];
		this.variableCountStack = [];
		this.context = context;
	}

	/**
		Starts a new scope.
	**/
	public function startScope(): Void
		this.variableCountStack.push(this.variableStack.length);

	/**
		Ends the current scope.
		Pops all variables that were pushed after the last call of `startScope()`.
		@return `AssemblyCode` that frees variables that have been declared in the current scope.
	**/
	public function endScope(): AssemblyCode {
		final maybeTargetSize = variableCountStack.pop();
		if (maybeTargetSize.isNone()) throw "Called endScope() before startScope().";
		final targetSize = maybeTargetSize.unwrap();

		final freeInstructions: AssemblyCode = [];
		final variableStack = this.variableStack;
		while (targetSize < variableStack.length) {
			final variable = variableStack.pop().unwrap();
			freeInstructions.push(Free(variable.name, variable.type));
		}

		return freeInstructions;
	}

	/**
		Registers a local variable that is valid in the current scope.
	**/
	public function push(name: String, type: ValueType): Void {
		this.variableStack.push({
			name: name,
			type: type,
			context: this.context
		});
	}

	/**
		@return `LocalVariable` that was declared in the narrowest scope.
		Throws error if a variable with `name` was never declared.
	**/
	public function get(name: String): LocalVariable {
		final variableStack = this.variableStack;
		var i = variableStack.length.int() - 1;

		while (i >= 0) {
			final variable = variableStack[i];
			if (variable.name == name) return variable;
			--i;
		}

		throw 'Unknown local variable: $name';
	}
}

@:structInit
class LocalVariable {
	public final name: String;
	public final type: ValueType;

	final context: CompileContext;

	/**
		Creates an `AssemblyCode` that assigns the value of `this` local variable
		to the int/float register.
	**/
	public function load(): AssemblyCode {
		return switch this.type {
		case Int: [Load(Int(Var(this.name)))];
		case Float: [Load(Float(Var(this.name)))];
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
			Store(Int(Reg), this.name);
		case Float:
			Store(Float(Reg), this.name);
		case Vec:
			throw "Local variable of vector type is not supported.";
		}

		return [
			value.load(context),
			[store]
		].flatten();
	}

	/**
		Creates an `AssemblyCode` that adds `value` to the local variable specified by `this`.
	**/
	public function addValue(value: GenericExpression): AssemblyCode {
		final store: Instruction = switch this.type {
		case Int:
			Add(Int(Var(this.name), Reg));
		case Float:
			Add(Float(Var(this.name), Reg));
		case Vec:
			throw "Local variable of vector type is not supported.";
		}

		return [
			value.load(context),
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

		return [Increment(this.name)];
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

		return [Decrement(this.name)];
	}
}
