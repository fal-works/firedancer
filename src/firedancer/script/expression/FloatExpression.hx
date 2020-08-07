package firedancer.script.expression;

import firedancer.script.expression.FloatLikeExpressionData;

/**
	Abstract over `FloatLikeExpressionData` that can be implicitly cast from `Float`.
**/
@:notNull @:forward
abstract FloatExpression(
	FloatLikeExpressionData
) from FloatLikeExpressionData to FloatLikeExpressionData {
	/**
		The factor by which the constant values should be multiplied when writing into `AssemblyCode`.
	**/
	public static extern inline final constantFactor = 1.0;

	@:from public static extern inline function fromEnum(e: FloatLikeExpressionEnum): FloatExpression {
		final data: FloatLikeExpressionData = {
			data: e,
			constantFactor: constantFactor
		};
		return data;
	}

	@:from static extern inline function fromFloat(value: Float): FloatExpression {
		final data: FloatLikeExpressionData = {
			data: FloatLikeExpressionEnum.Constant(value),
			constantFactor: constantFactor
		};
		return data;
	}

	@:from static extern inline function fromInt(value: Int): FloatExpression
		return fromFloat(value);

	@:op(-A)
	extern inline function unaryMinus(): FloatExpression
		return this.unaryMinus();

	@:op(A + B)
	static extern inline function add(
		a: FloatExpression,
		b: FloatExpression
	): FloatExpression {
		return a.add(b);
	}

	@:op(A - B)
	static extern inline function subtract(
		a: FloatExpression,
		b: FloatExpression
	): FloatExpression {
		return a.subtract(b);
	}

	@:op(A * B)
	static extern inline function multiply(
		a: FloatExpression,
		b: FloatExpression
	): FloatExpression {
		return a.multiply(b);
	}

	@:op(A / B)
	static extern inline function divide(
		a: FloatExpression,
		b: FloatExpression
	): FloatExpression {
		return a.divide(b);
	}

	@:op(A % B)
	static extern inline function modulo(
		a: FloatExpression,
		b: FloatExpression
	): FloatExpression {
		return a.modulo(b);
	}
}
