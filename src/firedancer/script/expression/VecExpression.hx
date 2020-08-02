package firedancer.script.expression;

import firedancer.types.Azimuth;
import firedancer.assembly.Opcode;
import firedancer.assembly.AssemblyCode;
import firedancer.script.expression.subtypes.VecConstant;

/**
	Abstract over `VecExpressionEnum` that can be implicitly cast from vector objects.
**/
@:notNull @:forward
abstract VecExpression(VecExpressionEnum) from VecExpressionEnum to VecExpressionEnum {
	@:from public static function fromCartesianConstants(
		args: { x: Float, y: Float }
	): VecExpression {
		return VecExpressionEnum.Constant(VecConstant.fromCartesian(args));
	}

	@:from public static function fromCartesianExpressions(
		args: { x: FloatExpression, y: FloatExpression }
	): VecExpression {
		final x = args.x.toEnum();
		final y = args.y.toEnum();
		return switch x {
			case Constant(constX):
				switch y {
					case Constant(constY):
						fromCartesianConstants({ x: constX.toFloat(), y: constY.toFloat() });
					default:
						VecExpressionEnum.Runtime(Cartesian(x, y));
				}
			default:
				VecExpressionEnum.Runtime(Cartesian(x, y));
		}
	}

	@:from public static function fromPolarConstants(
		args: { length: Float, angle: Azimuth }
	): VecExpression {
		return VecExpressionEnum.Constant(VecConstant.fromPolar(args));
	}

	@:from public static function fromPolarExpressionss(
		args: { length: FloatExpression, angle: AngleExpression }
	): VecExpression {
		final length = args.length.toEnum();
		final angle = args.angle.toEnum();
		return switch length {
			case Constant(constLength):
				switch angle {
					case Constant(constAngle):
						fromPolarConstants({ length: constLength.toFloat(), angle: constAngle.toAzimuth() });
					default:
						VecExpressionEnum.Runtime(Polar(length, angle));
				}
			default:
				VecExpressionEnum.Runtime(Polar(length, angle));
		}
	}

	@:op(A / B) public function divide(divisor: Float): VecExpression {
		final expression: VecExpressionEnum = switch this {
			case Constant(value):
				Constant(value.divide(divisor));
			case Runtime(expression):
				Runtime(expression / divisor);
		}
		return expression;
	}

	@:op(A / B) extern inline function divideInt(divisor: Int): VecExpression
		return divide(divisor);

	/**
		Creates an `AssemblyCode` that runs either `processConstantVector` or `processVolatileVector`
		receiving `this` value as argument.
		@param processConstantVector Any `Opcode` that uses a constant vector.
		@param processVolatileVector Any `Opcode` that uses the volatile vector.
	**/
	public function use(
		processConstantVector: Opcode,
		processVolatileVector: Opcode
	): AssemblyCode {
		return switch this {
			case Constant(value):
				value.use(processConstantVector);
			case Runtime(expression):
				expression.use(processVolatileVector);
		}
	}

	public extern inline function toEnum(): VecExpressionEnum
		return this;
}
