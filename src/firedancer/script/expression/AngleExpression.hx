package firedancer.script.expression;

import firedancer.types.Angle;

/**
	Abstract over `FloatLikeExpressionEnum` that can be implicitly converted from `Angle`.
**/
@:notNull @:forward
abstract AngleExpression(
	FloatLikeExpressionEnum
) from FloatLikeExpressionEnum to FloatLikeExpressionEnum {
	@:from public static extern inline function fromConstantAngle(value: Angle): AngleExpression
		return FloatLikeExpressionEnum.Constant(constantAngle(value));

	@:from static extern inline function fromConstantFloat(value: Float): AngleExpression
		return fromConstantAngle(value);

	@:from static extern inline function fromConstantInt(value: Int): AngleExpression
		return fromConstantAngle(value);

	@:op(A / B)
	extern inline function divide(divisor: Float): AngleExpression
		return this.divide(divisor);

	@:op(A / B)
	extern inline function divideInt(divisor: Int): AngleExpression
		return divide(divisor);

	public extern inline function toEnum(): FloatLikeExpressionEnum
		return this;
}
