package firedancer.script.expression.subtypes;

import firedancer.assembly.ConstantOperand;
import firedancer.types.Azimuth;
import firedancer.types.AzimuthDisplacement;

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

	@:from public static extern inline function fromAzimuth(
		value: Azimuth
	): FloatLikeConstant
		return FloatLikeConstantEnum.Azimuth(value);

	@:from public static extern inline function fromAzimuthDisplacement(
		value: AzimuthDisplacement
	): FloatLikeConstant
		return FloatLikeConstantEnum.AzimuthDisplacement(value);

	@:to public function toFloat(): Float {
		return switch this {
			case Float(value): value;
			case Azimuth(value): value.toRadians();
			case AzimuthDisplacement(value): value.toRadians();
		}
	}

	@:to public function toAzimuth(): Azimuth {
		return switch this {
			case Float(value): value;
			case Azimuth(value): value;
			case AzimuthDisplacement(value): Azimuth.zero + value;
		}
	}

	@:to public function toAzimuthDisplacement(): AzimuthDisplacement {
		return switch this {
			case Float(value): value;
			case Azimuth(value): throw "Cannot convert Azimuth to AzimuthDisplacement.";
			case AzimuthDisplacement(value): value;
		}
	}

	@:to public extern inline function toOperand(): ConstantOperand
		return Float(toFloat());

	@:op(A + B) function add(other: FloatLikeConstant): FloatLikeConstant {
		return switch this {
			case Float(valueA):
				switch other.toEnum() {
					case Float(valueB): valueA + valueB;
					case Azimuth(_): throw "Cannot add Float and Azimuth.";
					case AzimuthDisplacement(valueB): valueA + valueB.toDegrees();
				}
			case Azimuth(valueA):
				switch other.toEnum() {
					case Float(_): throw "Cannot add Azimuth and Float.";
					case Azimuth(_): throw "Cannot add Azimuth values.";
					case AzimuthDisplacement(valueB): valueA + valueB;
				}
			case AzimuthDisplacement(valueA):
				switch other.toEnum() {
					case Float(valueB): valueA + valueB;
					case Azimuth(valueB): valueA + valueB;
					case AzimuthDisplacement(valueB): valueA + valueB;
				}
		}
	}

	@:op(A / B) function divide(divisor: Float): FloatLikeConstant {
		return switch this {
			case Float(value): FloatLikeConstantEnum.Float(value / divisor);
			case Azimuth(_): throw "Cannot divide Azimuth value.";
			case AzimuthDisplacement(value): FloatLikeConstantEnum.AzimuthDisplacement(value / divisor);
		}
	}

	@:op(A / B) extern inline function divideInt(divisor: Int): FloatLikeConstant
		return divide(divisor);

	public extern inline function toEnum(): FloatLikeConstantEnum
		return this;
}
