package firedancer.assembly;

import banker.binary.internal.Constants.*;

/**
	Object for specifying operand types of any `AssemblyStatement`.
**/
abstract StatementType(Array<OperandType>) from Array<OperandType> {
	static extern inline final opcodeBytecodeLength = LEN32;

	/**
		Casts `this` to the underlying type (an array of `OperandType`).
	**/
	@:to public extern inline function operandTypes(): Array<OperandType>
		return this;

	/**
		Calculates the bytecode length in bytes that is required for a single `AssemblyStatement`.
	**/
	public function bytecodeLength(): UInt {
		var len = opcodeBytecodeLength;

		for (i in 0...this.length) len += switch this[i] {
			case Int: LEN32;
			case Float: LEN64;
			case Vec: LEN64 + LEN64;
		}

		return len;
	}
}
