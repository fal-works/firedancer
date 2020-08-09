package firedancer.script.api_components;

import firedancer.script.expression.IntExpression;
import firedancer.script.expression.FloatExpression;
import firedancer.assembly.Opcode.*;

/**
	Provides functions for generating pseudorandom numbers.
**/
class Random {
	public function new() {}

	/**
		Provides functions for generating pseudorandom integer values.
	**/
	public final int = new RandomInt();

	/**
		Provides functions for generating pseudorandom angle values.
	**/
	public final angle = new RandomAngle();

	/**
		Gets a random value between `0` and `1`.
	**/
	public inline function ratio(): FloatExpression
		return FloatExpression.fromEnum(Runtime(Variable(calc(RandomRatioV))));

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
}

class RandomAngle {
	public function new() {}

	/**
		Gets a random angle between `min` and `max`.
	**/
	public inline function between(
		min: AngleExpression,
		max: AngleExpression
	): AngleExpression {
		return min + AngleExpression.fromEnum(Runtime(UnaryOperation({
			constantOperator: Instruction(calc(RandomFloatCV)),
			runtimeOperator: calc(RandomFloatVV)
		}, max - min)));
	}

	/**
		Gets a random angle between `-max` and `max`.
	**/
	public inline function signed(max: AngleExpression): AngleExpression {
		return max.unaryOperation({
			constantOperator: Instruction(calc(RandomFloatSignedCV)),
			runtimeOperator: calc(RandomFloatSignedVV)
		});
	}

	/**
		Gets a random angle in range `[-centralAngle / 2, centralAngle / 2)`.

		Same effect as `random.signed(centralAngle / 2)`.
	**/
	public inline function grouping(centralAngle: AngleExpression): AngleExpression
		return signed(centralAngle / 2);
}

class RandomInt {
	public function new() {}

	/**
		Gets a random angle between `min` and `max`.
	**/
	public inline function between(
		min: IntExpression,
		max: IntExpression
	): IntExpression {
		return min + IntExpression.fromEnum(Runtime(UnaryOperation({
			constantOperator: Instruction(calc(RandomIntCV)),
			runtimeOperator: calc(RandomIntVV)
		}, max - min)));
	}

	/**
		Gets a random angle between `-max` and `max`.
	**/
	public inline function signed(max: IntExpression): IntExpression {
		return max.unaryOperation({
			constantOperator: Instruction(calc(RandomIntSignedCV)),
			runtimeOperator: calc(RandomIntSignedVV)
		});
	}
}
