package firedancer.script.api_components;

import firedancer.script.expression.FloatExpression;
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
		return FloatExpression.fromEnum(Runtime(UnaryOperation({
			constantOperator: Instruction(calc(RandomFloatCV)),
			runtimeOperator: calc(RandomFloatVV)
		}, max)));
	}

	/**
		Gets a random value between `min` and `max`.
	**/
	public inline function between(
		min: FloatExpression,
		max: FloatExpression
	): FloatExpression {
		return min + FloatExpression.fromEnum(Runtime(UnaryOperation({
			constantOperator: Instruction(calc(RandomFloatCV)),
			runtimeOperator: calc(RandomFloatVV)
		}, max - min)));
	}

	/**
		Gets a random value between `-max` and `max`.
	**/
	public inline function signed(max: FloatExpression): FloatExpression {
		return FloatExpression.fromEnum(Runtime(UnaryOperation({
			constantOperator: Instruction(calc(RandomFloatSignedCV)),
			runtimeOperator: calc(RandomFloatSignedVV)
		}, max)));
	}

	/**
		Gets a random angle in range `[-centralAngle / 2, centralAngle / 2)`.

		Same effect as `random.signed(centralAngle / 2)`.
	**/
	public inline function grouping(centralAngle: AngleExpression): AngleExpression {
		return FloatExpression.fromEnum(Runtime(UnaryOperation({
			constantOperator: Instruction(calc(RandomFloatSignedCV)),
			runtimeOperator: calc(RandomFloatSignedVV)
		}, centralAngle / 2)));
	}
}
