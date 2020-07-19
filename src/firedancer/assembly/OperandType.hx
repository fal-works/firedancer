package firedancer.assembly;

/**
	Type of `Operand`.
**/
enum abstract OperandType(Int) {
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
