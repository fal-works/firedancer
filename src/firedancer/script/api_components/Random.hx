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
		Gets a random value between `0` and `max`.
	**/
	public inline function float(max: FloatExpression): FloatExpression {
		return FloatLikeExpressionEnum.Runtime(UnaryOperator({
			constantOperator: Instruction(calc(RandomFloatCV)),
			operateVV: calc(RandomFloatVV)
		}, max));
	}

	/**
		Gets a random value between `min` and `max`.
	**/
	public inline function between(min: FloatExpression, max: FloatExpression): FloatExpression {
		return min + FloatLikeExpressionEnum.Runtime(UnaryOperator({
			constantOperator: Instruction(calc(RandomFloatCV)),
			operateVV: calc(RandomFloatVV)
		}, max - min));
	}

	/**
		Gets a random value between `-max` and `max`.
	**/
	public inline function signed(max: FloatExpression): FloatExpression {
		return FloatLikeExpressionEnum.Runtime(UnaryOperator({
			constantOperator: Instruction(calc(RandomFloatSignedCV)),
			operateVV: calc(RandomFloatSignedVV)
		}, max));
	}

	/**
		Gets a random angle in range `[-centralAngle / 2, centralAngle / 2)`.

		Same effect as `random.signed(centralAngle / 2)`.
	**/
	public inline function grouping(centralAngle: AngleExpression): AngleExpression {
		return FloatLikeExpressionEnum.Runtime(UnaryOperator({
			constantOperator: Instruction(calc(RandomFloatSignedCV)),
			operateVV: calc(RandomFloatSignedVV)
		}, centralAngle / 2));
	}
}
