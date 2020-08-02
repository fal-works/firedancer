package firedancer.script.expression.subtypes;

import firedancer.assembly.Opcode;

/**
	Expression of any 2D vector that has to be evaluated in runtime.
**/
enum VecRuntimeExpressionEnum {
	Cartesian(x: FloatExpression, y: FloatExpression);
	Polar(length: FloatExpression, angle: AzimuthExpression);

	/**
		@param loadV `Opcode` for loading the value to the current volatile vector.
	**/
	Variable(loadV: Opcode);
}
