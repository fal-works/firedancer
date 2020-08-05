package firedancer.script.api_components;

import firedancer.script.expression.FloatExpression;
import firedancer.script.expression.FloatLikeExpressionEnum;
import firedancer.assembly.Opcode.*;

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
			constantOperator: Instruction(general(RandomFloatCV)),
			operateVV: general(RandomFloatVV)
		}, max));
	}

	/**
		Gets a random angle in range `[-centralAngle / 2, centralAngle / 2)`.
	**/
	public inline function angle(?centralAngle: AngleExpression): AngleExpression {
		final centralAngle = Nulls.coalesce(centralAngle, 360.0);

		return FloatLikeExpressionEnum.Runtime(UnaryOperator({
			constantOperator: Instruction(general(RandomFloatSignedCV)),
			operateVV: general(RandomFloatSignedVV)
		}, centralAngle / 2));
	}
}
