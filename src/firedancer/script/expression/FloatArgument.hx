package firedancer.script.expression;

/**
	Abstract over `FloatExpression` that can be implicitly cast from other types.
**/
@:notNull @:forward
abstract FloatArgument(FloatExpression) from FloatExpression to FloatExpression {
	@:from static extern inline function fromConstant(value: Float): FloatArgument
		return FloatExpression.Constant(value);

	@:from static extern inline function fromIntConstant(value: Int): FloatArgument
		return FloatExpression.Constant(value);

	@:op(A / B) extern inline function divide(divisor: Float): FloatArgument {
		return switch this {
			case Constant(value): value / divisor;
		}
	}

	@:op(A / B) extern inline function divideInt(divisor: Int): FloatArgument
		return divide(divisor);

	public extern inline function toExpression(): FloatExpression
		return this;
}
