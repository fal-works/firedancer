package firedancer.script.expression.subtypes;

import firedancer.assembly.Opcode;

/**
	Expression of any 2D vector that has to be evaluated in runtime.
**/
enum VecRuntimeExpressionEnum {
	Cartesian(x: FloatExpression, y: FloatExpression);
	Polar(length: FloatExpression, angle: AngleExpression);

	/**
		@param loadV `Opcode` for loading the value to the current volatile vector.
	**/
	Variable(loadV: Opcode);

	UnaryOperator(type: VecUnaryOperatorType, vec: VecExpression);
	BinaryOperator(vecA: VecExpression, vecB: VecExpression);
	BinaryOperatorWithFloat(vec: VecExpression, float: FloatExpression);
}

@:structInit
class VecUnaryOperatorType {
	public final constantOperator: VecConstantUnaryOperator;

	/**
		Any `Opcode` that operates the volatile vector and reassigns it.
	**/
	public final operateVV: Opcode;
}

enum VecConstantUnaryOperator {
	/**
		Calculates immediately in compile-time.
		@param func Any function that takes a vector value and returns another vector.
	**/
	Immediate(func: (vec: VecConstant) -> VecConstant);

	/**
		Applies a single instruction.
		@param opcodeCV Any `Opcode` that operates a given constant vector and assigns the result to the volatile vector.
	**/
	Instruction(opcodeCV: Opcode);
}
