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

	@:op(A + B) @:commutative
	static extern inline function addFloat(a: FloatExpression, b: Float): FloatExpression {
		return add(a, b);
	}

	@:op(A + B) @:commutative
	static extern inline function addInt(a: FloatExpression, b: Int): FloatExpression {
		return add(a, b);
	}

	@:op(A - B)
	static extern inline function subtract(
		a: FloatExpression,
		b: FloatExpression
	): FloatExpression {
		return a.subtract(b);
	}

	@:op(A / B) extern inline function divide(divisor: FloatExpression): FloatExpression
		return this.divide(divisor);

	@:op(A / B) extern inline function divideFloat(divisor: Float): FloatExpression
		return divide(divisor);

	@:op(A / B) extern inline function divideInt(divisor: Int): FloatExpression
		return divide(divisor);

	public extern inline function toEnum(): FloatLikeExpressionEnum
		return this;
}
