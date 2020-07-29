package firedancer.script;

import banker.vector.Vector;
import firedancer.assembly.AssemblyCode;
import firedancer.bytecode.RuntimeContext;

/**
	Context for compiling bullet patterns.
**/
class CompileContext {
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

	public function new() {}

	/**
		Registers `code` in `this` context (if absent)
		so that it can be retrieved by a specific ID number.
		@return The ID for `code`.
	**/
	public function setCode(code: AssemblyCode): UInt {
		final codeList = this.codeList;

		if (codeList.has(code))
			return codeList.indexOf(code, 0);

		final index = codeList.length;
		codeList.push(code);

		return index;
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
		Creates a `RuntimeContext` instance.
	**/
	public function createRuntimeContext() {
		final bytecodeList = Vector.fromArrayCopy(this.codeList.map(code -> code.compile()));

		return new RuntimeContext(bytecodeList, this.nameIndexMap);
	}
}
