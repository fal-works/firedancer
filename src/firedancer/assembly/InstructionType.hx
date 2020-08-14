package firedancer.assembly;

/**
	Object for specifying operand types of any `Instruction`.
**/
abstract InstructionType(Array<ValueType>) from Array<ValueType> {
	/**
		Casts `this` to the underlying type (an array of `ValueType`).
	**/
	@:to public extern inline function operandTypes(): Array<ValueType>
		return this;

	/**
		Calculates the bytecode length in bytes that is required for a single `Instruction`.
	**/
	public function bytecodeLength(): UInt {
		var len = Opcode.size;

		for (i in 0...this.length) len += this[i].size;

		return len;
	}
}
