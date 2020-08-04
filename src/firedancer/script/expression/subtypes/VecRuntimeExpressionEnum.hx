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

	UnaryOperator(vec: VecExpression);
	BinaryOperator(vecA: VecExpression, vecB: VecExpression);
	BinaryOperatorWithFloat(vec: VecExpression, float: FloatExpression);
}
