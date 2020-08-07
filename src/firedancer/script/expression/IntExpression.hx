package firedancer.script.expression;

import firedancer.assembly.AssemblyCode;
import firedancer.assembly.Opcode;

/**
	Abstract over `IntLikeExpressionEnum` that can be implicitly cast from `UInt`.
**/
@:notNull @:forward
abstract IntExpression(
	IntLikeExpressionEnum
) from IntLikeExpressionEnum to IntLikeExpressionEnum {
	@:from public static extern inline function fromInt(value: Int): IntExpression
		return IntLikeExpressionEnum.Constant(value);

	@:op(-A)
	extern inline function unaryMinus(): IntExpression
		return this.unaryMinus();

	@:op(A + B)
	static extern inline function add(
		a: IntExpression,
		b: IntExpression
	): IntExpression {
		return a.add(b);
	}

	@:op(A - B)
	static extern inline function subtract(
		a: IntExpression,
		b: IntExpression
	): IntExpression {
		return a.subtract(b);
	}

	@:op(A * B)
	static extern inline function multiply(
		a: IntExpression,
		b: IntExpression
	): IntExpression {
		return a.multiply(b);
	}

	@:op(A / B)
	static extern inline function divide(
		a: IntExpression,
		b: IntExpression
	): IntExpression {
		return a.divide(b);
	}

	@:op(A % B)
	static extern inline function modulo(
		a: IntExpression,
		b: IntExpression
	): IntExpression {
		return a.modulo(b);
	}

	/**
		Creates an `AssemblyCode` that assigns `this` value to the current volatile float.
	**/
	public function loadToVolatile(): AssemblyCode
		return this.loadToVolatile();

	/**
		Creates an `AssemblyCode` that runs either `constantOpcode` or `volatileOpcode`
		receiving `this` value as argument.
	**/
	public function use(constantOpcode: Opcode, volatileOpcode: Opcode): AssemblyCode
		return this.use(constantOpcode, volatileOpcode);

	public extern inline function toEnum(): IntLikeExpressionEnum
		return this;
}
