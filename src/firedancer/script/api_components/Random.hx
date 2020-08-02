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
	public inline function float(max: FloatExpression): FloatLikeExpressionEnum {
		return FloatLikeExpressionEnum.Runtime(UnaryOperator({
			operateFloatCV: RandomFloatCV,
			operateFloatVV: RandomFloatVV
		}, max));
	}
}
