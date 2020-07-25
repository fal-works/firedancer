package firedancer.script.expression;

import firedancer.types.Azimuth;

/**
	Abstract over `VecExpression` that can be implicitly cast from other types.
**/
@:notNull @:forward
abstract VecArgument(VecExpression) from VecExpression to VecExpression {
	@:from static extern inline function fromCartesianConstants(
		args: { x: Float, y: Float }
	): VecArgument
		return VecExpression.CartesianConstant(args.x, args.y);

	@:from static extern inline function fromCartesianExpressions(
		args: { x: FloatArgument, y: FloatArgument }
	): VecArgument {
		final x: FloatExpression = args.x;
		final y: FloatExpression = args.y;
		return switch x {
			case Constant(constX):
				switch y {
					case Constant(constY):
						VecExpression.CartesianConstant(constX, constY);
				}
		}
	}

	@:from static extern inline function fromPolarConstants(
		args: { length: Float, angle: Azimuth }
	): VecArgument
		return VecExpression.PolarConstant(args.length, args.angle);

	@:from static extern inline function fromPolarExpressionss(
		args: { length: FloatArgument, angle: Azimuth }
	): VecArgument {
		final length: FloatExpression = args.length;
		final angle = args.angle;
		return switch length {
			case Constant(constLength):
				VecExpression.PolarConstant(constLength, angle);
		}
	}

	@:op(A / B) extern inline function divide(divisor: Float): VecArgument {
		final expression: VecExpression = switch this {
			case CartesianConstant(x, y): CartesianConstant(x / divisor, y / divisor);
			case PolarConstant(length, angle): PolarConstant(length / divisor, angle);
			case CartesianExpression(x, y): CartesianExpression(x / divisor, y / divisor);
			case PolarExpression(length, angle): PolarExpression(length / divisor, angle);
		}
		return expression;
	}

	@:op(A / B) extern inline function divideInt(divisor: Int): VecArgument
		return divide(divisor);

	public extern inline function toExpression(): VecExpression
		return this;
}
