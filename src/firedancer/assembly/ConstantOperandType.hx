package firedancer.assembly;

/**
	Type of `ConstantOperand`.
**/
enum abstract ConstantOperandType(Int) {
	/**
		A 32-bit integer value.
	**/
	final Int;

	/**
		A 64-bit float value.
	**/
	final Float;

	/**
		A vector of two 64-bit float values.
	**/
	final Vec;
}
