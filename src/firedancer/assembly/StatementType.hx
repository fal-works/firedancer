package firedancer.assembly;

import banker.binary.internal.Constants.*;

/**
	Object for specifying operand types of any `AssemblyStatement`.
**/
abstract StatementType(Array<ConstantOperandType>) from Array<ConstantOperandType> {
	/**
		Casts `this` to the underlying type (an array of `ConstantOperandType`).
	**/
	@:to public extern inline function operandTypes(): Array<ConstantOperandType>
		return this;

	/**
		Calculates the bytecode length in bytes that is required for a single `AssemblyStatement`.
	**/
	public function bytecodeLength(): UInt {
		var len = Opcode.size;

		for (i in 0...this.length) len += switch this[i] {
			case Int: LEN32;
			case Float: LEN64;
			case Vec: LEN64 + LEN64;
		}

		return len;
	}
}
