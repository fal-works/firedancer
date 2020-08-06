package firedancer.script.expression;

import firedancer.assembly.AssemblyCode;
import firedancer.assembly.Opcode;

/**
	Abstract over `FloatLikeExpressionEnum` that can be implicitly cast from `Float`.
**/
@:notNull @:forward
abstract FloatExpression(
	FloatLikeExpressionEnum
) from FloatLikeExpressionEnum to FloatLikeExpressionEnum {
	/**
		The factor by which the constant values should be multiplied when writing into `AssemblyCode`.
	**/
	public static extern inline final constantFactor = 1.0;

	@:from public static extern inline function fromFloat(value: Float): FloatExpression
		return FloatLikeExpressionEnum.Constant(value);

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
	): AngleExpression {
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

	/**
		Creates an `AssemblyCode` that assigns `this` value to the current volatile float.
	**/
	public function loadToVolatileFloat(): AssemblyCode
		return this.loadToVolatileFloat(constantFactor);

	/**
		Creates an `AssemblyCode` that runs either `constantOpcode` or `volatileOpcode`
		receiving `this` value as argument.
	**/
	public function use(constantOpcode: Opcode, volatileOpcode: Opcode): AssemblyCode
		return this.use(constantOpcode, volatileOpcode, constantFactor);

	public extern inline function toEnum(): FloatLikeExpressionEnum
		return this;
}
