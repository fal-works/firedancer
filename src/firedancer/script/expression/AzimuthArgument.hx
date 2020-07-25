package firedancer.script.expression;

import firedancer.types.Azimuth;

/**
	Abstract over `AzimuthExpression` that can be implicitly cast from other types.
**/
@:notNull @:forward
abstract AzimuthArgument(AzimuthExpression) from AzimuthExpression to AzimuthExpression {
	@:from static extern inline function fromConstant(value: Azimuth): AzimuthArgument
		return AzimuthExpression.Constant(value);

	public extern inline function toExpression(): AzimuthExpression
		return this;
}
