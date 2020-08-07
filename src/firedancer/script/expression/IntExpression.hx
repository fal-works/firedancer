package firedancer.script.expression;

/**
	Abstract over `IntLikeExpressionData` that can be implicitly cast from `UInt`.
**/
@:notNull @:forward
abstract IntExpression(
	IntLikeExpressionData
) from IntLikeExpressionData to IntLikeExpressionData {
	@:from public static extern inline function fromInt(value: Int): IntExpression
		return IntLikeExpressionData.create(IntLikeExpressionEnum.Constant(value));

	@:op(-A)
	extern inline function unaryMinus(): IntExpression
		return this.unaryMinus();

	@:op(A + B)
	static extern inline function add(a: IntExpression, b: IntExpression): IntExpression {
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
}
