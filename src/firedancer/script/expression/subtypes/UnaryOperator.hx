package firedancer.script.expression.subtypes;

import firedancer.assembly.Opcode;

@:structInit
class UnaryOperator<T> {
	/**
		Enum that determines how to operate a constant value.
	**/
	public final constantOperator: ConstantUnaryOperator<T>;

	/**
		Any `Opcode` that operates the volatile value and reassigns the result to the volatile value.
	**/
	public final runtimeOperator: Opcode;
}

enum ConstantUnaryOperator<T> {
	/**
		Calculates immediately in compile-time.
		@param func Any function that takes a raw value and returns another raw value.
	**/
	Immediate(func: (v: T) -> T);

	/**
		Applies a single instruction.
		@param opcodeCV Any `Opcode` that operates a given constant float and assigns the result to the volatile float.
	**/
	Instruction(opcodeCV: Opcode);

	/**
		Uses `UnaryOperator.runtimeOperator`.
	**/
	None;
}
