package firedancer.script.expression;

import reckoner.Geometry.DEGREES_TO_RADIANS;
import firedancer.assembly.AssemblyCode;
import firedancer.assembly.Opcode;
import firedancer.types.Angle;

/**
	Abstract over `FloatLikeExpressionEnum` that can be implicitly converted from `Angle`.
**/
@:notNull @:forward
abstract AngleExpression(
	FloatLikeExpressionEnum
) from FloatLikeExpressionEnum to FloatLikeExpressionEnum {
	/**
		The factor by which the constant values should be multiplied when writing into `AssemblyCode`.
	**/
	public static extern inline final constantFactor = DEGREES_TO_RADIANS;

	@:from public static extern inline function fromAngle(value: Angle): AngleExpression
		return FloatLikeExpressionEnum.Constant(value);

	@:from static extern inline function fromFloat(value: Float): AngleExpression
		return fromAngle(value);

	@:from static extern inline function fromInt(value: Int): AngleExpression
		return fromFloat(value);

	@:from static extern inline function fromFloatExpression(
		expr: FloatExpression
	): AngleExpression {
		return expr.toEnum();
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

	/**
		Creates an `AssemblyCode` that assigns `this` value to the current volatile float.
	**/
	public function loadToVolatile(): AssemblyCode
		return this.loadToVolatile(constantFactor);

	/**
		Creates an `AssemblyCode` that runs either `constantOpcode` or `volatileOpcode`
		receiving `this` value as argument.
	**/
	public function use(constantOpcode: Opcode, volatileOpcode: Opcode): AssemblyCode
		return this.use(constantOpcode, volatileOpcode, constantFactor);

	public extern inline function toEnum(): FloatLikeExpressionEnum
		return this;
}
