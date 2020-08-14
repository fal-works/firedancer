package firedancer.assembly;

import banker.binary.internal.Constants.*;

/**
	Object for specifying operand types of any `AssemblyStatement`.
**/
abstract StatementType(Array<ValueType>) from Array<ValueType> {
	/**
		Casts `this` to the underlying type (an array of `ValueType`).
	**/
	@:to public extern inline function operandTypes(): Array<ValueType>
		return this;

	/**
		Calculates the bytecode length in bytes that is required for a single `AssemblyStatement`.
	**/
	public function bytecodeLength(): UInt {
		var len = Opcode.size;

		for (i in 0...this.length) len += this[i].size;

		return len;
	}
}
