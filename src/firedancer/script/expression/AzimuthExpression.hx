package firedancer.script.expression;

import firedancer.types.Azimuth;

/**
	Abstract over `FloatLikeExpressionEnum` that can be implicitly converted from `Azimuth`.
**/
@:notNull @:forward
abstract AzimuthExpression(
	FloatLikeExpressionEnum
) from FloatLikeExpressionEnum to FloatLikeExpressionEnum {
	@:from public static extern inline function fromConstant(
		value: Azimuth
	): AzimuthExpression
		return FloatLikeExpressionEnum.Constant(constantAngle(value.toAngle()));

	@:from static extern inline function fromConstantFloat(value: Float): AzimuthExpression
		return fromConstant(value);

	@:from static extern inline function fromConstantInt(value: Int): AzimuthExpression
		return fromConstant(value);

	public extern inline function toEnum(): FloatLikeExpressionEnum
		return this;
}
