package firedancer.script.expression;

import firedancer.types.Angle;

/**
	Abstract over `FloatLikeExpressionEnum` that can be implicitly converted from `Angle`.
**/
@:notNull @:forward
abstract AngleExpression(
	FloatLikeExpressionEnum
) from FloatLikeExpressionEnum to FloatLikeExpressionEnum {
	@:from public static extern inline function fromConstant(value: Angle): AngleExpression
		return FloatLikeExpressionEnum.Constant(value);

	@:from static extern inline function fromConstantFloat(value: Float): AngleExpression
		return fromConstant(value);

	@:from static extern inline function fromConstantInt(value: Int): AngleExpression
		return fromConstant(value);

	@:to public extern inline function toAzimuthExpression(): AzimuthExpression
		return this.toAzimuthExpression();

	@:op(A / B)
	extern inline function divide(divisor: Float): AngleExpression
		return this.divide(divisor);

	@:op(A / B)
	extern inline function divideInt(divisor: Int): AngleExpression
		return divide(divisor);

	public extern inline function toEnum(): FloatLikeExpressionEnum
		return this;
}
