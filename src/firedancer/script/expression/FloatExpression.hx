package firedancer.script.expression;

/**
	Abstract over `FloatLikeExpressionEnum` that can be implicitly cast from `Float`.
**/
@:notNull @:forward
abstract FloatExpression(
	FloatLikeExpressionEnum
) from FloatLikeExpressionEnum to FloatLikeExpressionEnum {
	@:from public static extern inline function fromConstant(value: Float): FloatExpression
		return FloatLikeExpressionEnum.Constant(constantFloat(value));

	@:from static extern inline function fromConstantInt(value: Int): FloatExpression
		return fromConstant(value);

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

	@:op(A / B) extern inline function divide(divisor: FloatExpression): FloatExpression
		return this.divide(divisor);

	public extern inline function toEnum(): FloatLikeExpressionEnum
		return this;
}
