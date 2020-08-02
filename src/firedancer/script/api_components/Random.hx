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
		Gets a random angle in range `[-centralAngle / 2, centralAngle / 2)`.
	**/
	public inline function angle(?centralAngle: AngleExpression): AngleExpression {
		final centralAngle = Nulls.coalesce(centralAngle, 360.0);

		return FloatLikeExpressionEnum.Runtime(UnaryOperator({
			operateFloatCV: RandomFloatSignedCV,
			operateFloatVV: RandomFloatSignedVV
		}, centralAngle / 2));
	}
}
