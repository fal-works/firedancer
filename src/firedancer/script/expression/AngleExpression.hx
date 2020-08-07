package firedancer.script.expression;

import reckoner.Geometry.DEGREES_TO_RADIANS;
import firedancer.types.Angle;
import firedancer.script.expression.FloatLikeExpressionData;

/**
	Abstract over `FloatLikeExpressionData` that can be implicitly converted from `Angle`.
**/
@:notNull @:forward
abstract AngleExpression(
	FloatLikeExpressionData
) from FloatLikeExpressionData to FloatLikeExpressionData {
	/**
		The factor by which the constant values should be multiplied when writing into `AssemblyCode`.
	**/
	public static extern inline final constantFactor = DEGREES_TO_RADIANS;

	@:from public static extern inline function fromEnum(
		e: FloatLikeExpressionEnum
	): AngleExpression {
		final data: FloatLikeExpressionData = {
			data: e,
			constantFactor: constantFactor
		};
		return data;
	}

	@:from public static extern inline function fromAngle(value: Angle): AngleExpression {
		final data: FloatLikeExpressionData = {
			data: FloatLikeExpressionEnum.Constant(value),
			constantFactor: constantFactor
		};
		return data;
	}

	@:from static extern inline function fromFloat(value: Float): AngleExpression
		return fromAngle(value);

	@:from static extern inline function fromInt(value: Int): AngleExpression
		return fromFloat(value);

	@:from static extern inline function fromFloatExpression(
		expr: FloatExpression
	): AngleExpression {
		return FloatLikeExpressionData.create(expr.data, constantFactor);
	}

	@:op(-A)
	extern inline function unaryMinus(): AngleExpression
		return this.unaryMinus();

	@:op(A + B)
	static extern inline function add(
		a: AngleExpression,
		b: AngleExpression
	): AngleExpression {
		return a.add(b);
	}

	@:op(A - B)
	static extern inline function subtract(
		a: AngleExpression,
		b: AngleExpression
	): AngleExpression {
		return a.subtract(b);
	}

	@:op(A * B) @:commutative
	static extern inline function multiply(
		expr: AngleExpression,
		factor: FloatExpression
	): AngleExpression {
		return expr.multiply(factor);
	}

	@:op(A / B)
	static extern inline function divide(
		a: AngleExpression,
		b: FloatExpression
	): AngleExpression {
		return a.divide(b);
	}

	@:op(A % B)
	static extern inline function modulo(
		a: AngleExpression,
		b: FloatExpression
	): AngleExpression {
		return a.modulo(b);
	}
}
