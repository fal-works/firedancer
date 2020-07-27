package firedancer.script.expression;

import firedancer.types.AzimuthDisplacement;

/**
	Abstract over `AzimuthDisplacementExpression` that can be implicitly cast from other types.
**/
@:notNull @:forward
abstract AzimuthDisplacementArgument(
	AzimuthDisplacementExpression
) from AzimuthDisplacementExpression to AzimuthDisplacementExpression {
	@:from static extern inline function fromConstant(
		value: AzimuthDisplacement
	): AzimuthDisplacementArgument
		return AzimuthDisplacementExpression.Constant(value);

	@:from static extern inline function fromConstantFloat(value: Float): AzimuthDisplacementArgument
		return AzimuthDisplacementExpression.Constant(value);

	@:from static extern inline function fromConstantInt(value: Int): AzimuthDisplacementArgument
		return AzimuthDisplacementExpression.Constant(value);

	@:op(A / B) public extern inline function divide(divisor: Float): AzimuthDisplacementArgument {
		return switch this {
			case Constant(value): value / divisor;
			case Variable(_): throw "Not yet implemented.";
		}
	}

	@:op(A / B) extern inline function divideInt(divisor: Int): AzimuthDisplacementArgument
		return divide(divisor);

	public extern inline function toExpression(): AzimuthDisplacementExpression
		return this;
}
