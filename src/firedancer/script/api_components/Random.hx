package firedancer.script.api_components;

import firedancer.script.expression.FloatExpression;
import firedancer.script.expression.FloatLikeExpressionEnum;

/**
	Provides functions for generating pseudorandom numbers.
**/
class Random {
	public function new() {}

	/**
		Gets a random value in range `[0, max)`.
	**/
	public inline function float(max: FloatExpression): FloatExpression {
		return FloatLikeExpressionEnum.Runtime(UnaryOperator({
			operateFloatCV: RandomFloatCV,
			operateFloatVV: RandomFloatVV
		}, max));
	}

	/**
		Gets a random angle in range `[0, 360)`.
	**/
	public inline function angle(): AngleExpression {
		return FloatLikeExpressionEnum.Runtime(UnaryOperator({
			operateFloatCV: RandomFloatCV,
			operateFloatVV: RandomFloatVV
		}, AngleExpression.fromConstantAngle(360)));
	}
}
