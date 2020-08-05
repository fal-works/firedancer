package firedancer.script.expression;

import firedancer.assembly.ConstantOperand;
import reckoner.TmpVec2D;
import firedancer.script.expression.subtypes.FloatLikeConstant;
import firedancer.types.Azimuth;
import firedancer.assembly.Opcode;
import firedancer.assembly.AssemblyCode;
import firedancer.assembly.Opcode;
import firedancer.assembly.Opcode.*;
import firedancer.assembly.AssemblyStatement;
import firedancer.assembly.AssemblyCode;

/**
	Abstract over `VecExpressionEnum` that can be implicitly cast from vector objects.
**/
@:notNull @:forward
abstract VecExpression(VecExpressionEnum) from VecExpressionEnum to VecExpressionEnum {
	@:from public static function fromCartesianConstants(
		args: { x: Float, y: Float }
	): VecExpression {
		return VecExpression.fromCartesianExpressions({ x: args.x, y: args.y });
	}

	@:from public static function fromCartesianExpressions(
		args: { x: FloatExpression, y: FloatExpression }
	): VecExpression {
		final x = args.x.toEnum();
		final y = args.y.toEnum();
		return VecExpressionEnum.Cartesian(x, y);
	}

	@:from public static function fromPolarConstants(
		args: { length: Float, angle: Azimuth }
	): VecExpression {
		return VecExpression.fromPolarExpressionss({
			length: args.length,
			angle: args.angle.toAngle()
		});
	}

	@:from public static function fromPolarExpressionss(
		args: { length: FloatExpression, angle: AngleExpression }
	): VecExpression {
		final length = args.length.toEnum();
		final angle = args.angle.toEnum();
		return VecExpressionEnum.Polar(length, angle);
	}

	static function tryGetConstantsFromCartesian(
		x: FloatExpression,
		y: FloatExpression
	): Maybe<ConstantOperand> {
		return switch x.toEnum() {
			case Constant(valX):
				switch y.toEnum() {
					case Constant(valY):
						return Maybe.from(Vec(valX.toFloat(), valY.toFloat()));
					default:
						Maybe.none();
				}
			default:
				Maybe.none();
		}
	}

	static function tryGetConstantsFromPolar(
		length: FloatExpression,
		angle: AngleExpression
	): Maybe<ConstantOperand> {
		return switch length.toEnum() {
			case Constant(valLen):
				switch angle.toEnum() {
					case Constant(valAng):
						final vec = valAng.toAzimuth().toVec2D(valLen.toFloat());
						return Maybe.from(Vec(vec.x, vec.y));
					default:
						Maybe.none();
				}
			default:
				Maybe.none();
		}
	}

	@:op(A / B) function divideByFloat(divisor: Float): VecExpression {
		final expression: VecExpressionEnum = switch this {
			case Cartesian(x, y):
				VecExpressionEnum.Cartesian(x / divisor, y / divisor);
			case Polar(length, angle):
				VecExpressionEnum.Polar(length / divisor, angle);
		}
		return expression;
	}

	@:op(A / B) extern inline function dividebyInt(divisor: Int): VecExpression
		return divideByFloat(divisor);

	public function toConstantOperand(): Maybe<ConstantOperand> {
		return switch this {
			case Cartesian(x, y):
				switch x.toEnum() {
					case Constant(xVal):
						switch y.toEnum() {
							case Constant(yVal): Maybe.from(Vec(
									xVal.toFloat(),
									yVal.toFloat()
								));
							default: Maybe.none();
						}
					default: Maybe.none();
				}
			case Polar(length, angle):
				switch length.toEnum() {
					case Constant(lenVal):
						switch angle.toEnum() {
							case Constant(angVal):
								final vec = angVal.toAzimuth().toVec2D(lenVal.toFloat());
								Maybe.from(Vec(vec.x, vec.y));
							default: Maybe.none();
						}
					default: Maybe.none();
				}
		}
	}

	public function loadToVolatileVector(): AssemblyCode {
		final code = switch this {
			case Cartesian(x, y):
				[
					x.loadToVolatileFloat(),
					[new AssemblyStatement(general(SaveFloatV), [])],
					y.loadToVolatileFloat(),
					[new AssemblyStatement(general(CastCartesianVV), [])]
				].flatten();
			case Polar(length, angle):
				[
					length.loadToVolatileFloat(),
					[new AssemblyStatement(general(SaveFloatV), [])],
					angle.loadToVolatileFloat(),
					[new AssemblyStatement(general(CastPolarVV), [])]
				].flatten();
		};
		return code;
	}

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
		final code = switch this {
			case Cartesian(x, y):
				final const = tryGetConstantsFromCartesian(x, y);
				if (const.isSome()) {
					[new AssemblyStatement(general(LoadVecCV), [const.unwrap()])];
				} else {
					[
						x.loadToVolatileFloat(),
						[new AssemblyStatement(general(SaveFloatV), [])],
						y.loadToVolatileFloat(),
						[new AssemblyStatement(general(CastCartesianVV), [])]
					].flatten();
				}
			case Polar(length, angle):
				final const = tryGetConstantsFromPolar(length, angle);
				if (const.isSome()) {
					[new AssemblyStatement(general(LoadVecCV), [const.unwrap()])];
				} else {
					[
						length.loadToVolatileFloat(),
						[new AssemblyStatement(general(SaveFloatV), [])],
						angle.loadToVolatileFloat(),
						[new AssemblyStatement(general(CastPolarVV), [])]
					].flatten();
				};
		};
		code.push(new AssemblyStatement(processVolatileVector, []));
		return code;
	}

	public extern inline function toEnum(): VecExpressionEnum
		return this;
}
