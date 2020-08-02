package firedancer.script.expression;

/**
	Abstract over `FloatLikeExpressionEnum` that can be implicitly cast from `Float`.
**/
@:notNull @:forward
abstract FloatExpression(
	FloatLikeExpressionEnum
) from FloatLikeExpressionEnum to FloatLikeExpressionEnum {
	@:from public static extern inline function fromConstant(value: Float): FloatExpression
		return FloatLikeExpressionEnum.Constant(value);

	@:from static extern inline function fromConstantInt(value: Int): FloatExpression
		return fromConstant(value);

	@:op(A / B) extern inline function divide(divisor: Float): FloatExpression
		return this.divide(divisor);

	@:op(A / B) extern inline function divideInt(divisor: Int): FloatExpression
		return divide(divisor);

	public extern inline function toEnum(): FloatLikeExpressionEnum
		return this;
}
