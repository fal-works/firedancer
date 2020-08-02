package firedancer.script.expression;

import firedancer.script.expression.subtypes.VecConstant;
import firedancer.script.expression.subtypes.VecRuntimeExpression;

/**
	Expression representing any 2D vector.
**/
enum VecExpressionEnum {
	Constant(value: VecConstant);
	Runtime(expression: VecRuntimeExpression);
}
