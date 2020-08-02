package firedancer.script.expression;

import firedancer.types.AzimuthDisplacement;

/**
	Abstract over `FloatLikeExpressionEnum` that can be implicitly converted from `AzimuthDisplacement`.
**/
@:notNull @:forward
abstract AzimuthDisplacementExpression(
	FloatLikeExpressionEnum
) from FloatLikeExpressionEnum to FloatLikeExpressionEnum {
	@:from public static extern inline function fromConstant(
		value: AzimuthDisplacement
	): AzimuthDisplacementExpression
		return FloatLikeExpressionEnum.Constant(value);

	@:from static extern inline function fromConstantFloat(value: Float): AzimuthDisplacementExpression
		return fromConstant(value);

	@:from static extern inline function fromConstantInt(value: Int): AzimuthDisplacementExpression
		return fromConstant(value);

	@:to public extern inline function toAzimuthExpression(): AzimuthExpression
		return this.toAzimuthExpression();

	@:op(A / B)
	extern inline function divide(divisor: Float): AzimuthDisplacementExpression
		return this.divide(divisor);

	@:op(A / B)
	extern inline function divideInt(divisor: Int): AzimuthDisplacementExpression
		return divide(divisor);

	public extern inline function toEnum(): FloatLikeExpressionEnum
		return this;
}
