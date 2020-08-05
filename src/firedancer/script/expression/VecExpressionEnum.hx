package firedancer.script.expression;

/**
	Expression representing any 2D vector.
**/
enum VecExpressionEnum {
	Cartesian(x: FloatExpression, y: FloatExpression);
	Polar(length: FloatExpression, angle: AngleExpression);
}
