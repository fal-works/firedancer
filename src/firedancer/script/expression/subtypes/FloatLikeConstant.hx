package firedancer.script.expression.subtypes;

import firedancer.assembly.ConstantOperand;
import firedancer.types.Azimuth;
import firedancer.types.Angle;

/**
	Abstract over `FloatLikeConstantEnum` that can be implicitly cast from/to other types.
**/
@:notNull @:forward
abstract FloatLikeConstant(
	FloatLikeConstantEnum
) from FloatLikeConstantEnum to FloatLikeConstantEnum {
	@:from public static extern inline function fromConstant(value: Float): FloatLikeConstant
		return FloatLikeConstantEnum.Float(value);

	@:from static extern inline function fromConstantInt(value: Int): FloatLikeConstant
		return fromConstant(value);

	@:from public static extern inline function fromAngle(value: Angle): FloatLikeConstant
		return FloatLikeConstantEnum.Angle(value);

	public function toFloat(): Float {
		return switch this {
			case Float(value): value;
			case Angle(value): value.toRadians();
		}
	}

	public function toAzimuth(): Azimuth {
		return switch this {
			case Float(value): value;
			case Angle(value): Azimuth.zero + value;
		}
	}

	@:to public extern inline function toOperand(): ConstantOperand
		return Float(toFloat());

	@:op(A + B) function add(other: FloatLikeConstant): FloatLikeConstant {
		return switch this {
			case Float(valueA):
				switch other.toEnum() {
					case Float(valueB): valueA + valueB;
					case Angle(valueB): valueA + valueB.toDegrees();
				}
			case Angle(valueA):
				switch other.toEnum() {
					case Float(valueB): valueA + valueB;
					case Angle(valueB): valueA + valueB;
				}
		}
	}

	@:op(A / B) function divide(divisor: Float): FloatLikeConstant {
		return switch this {
			case Float(value): FloatLikeConstantEnum.Float(value / divisor);
			case Angle(value): FloatLikeConstantEnum.Angle(value / divisor);
		}
	}

	@:op(A / B) extern inline function divideInt(divisor: Int): FloatLikeConstant
		return divide(divisor);

	public extern inline function toEnum(): FloatLikeConstantEnum
		return this;
}
