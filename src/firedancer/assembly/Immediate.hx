package firedancer.assembly;

/**
	Immediate value embedded in an `Instruction`.
**/
enum Immediate {
	/**
		A 32-bit integer value.
	**/
	Int(value: haxe.Int32);

	/**
		A 64-bit float value.
	**/
	Float(value: Float);

	/**
		A vector of two 64-bit float values.
	**/
	Vec(x: Float, y: Float);
}
