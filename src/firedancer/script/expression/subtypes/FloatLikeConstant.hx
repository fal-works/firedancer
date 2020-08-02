package firedancer.script.expression.subtypes;

import firedancer.assembly.ConstantOperand;
import firedancer.types.Azimuth;
import firedancer.types.Angle;

/**
	Abstract over `FloatLikeConstantEnum` with some casting methods and operator overloads.
**/
@:notNull @:forward
abstract FloatLikeConstant(
	FloatLikeConstantEnum
) from FloatLikeConstantEnum to FloatLikeConstantEnum {
	/**
		Casts `Float` to `FloatLikeConstant`.
	**/
	public static extern inline function fromFloat(value: Float): FloatLikeConstant
		return FloatLikeConstantEnum.Float(value);

	/**
		Casts `Angle` to `FloatLikeConstant`.
	**/
	public static extern inline function fromAngle(value: Angle): FloatLikeConstant
		return FloatLikeConstantEnum.Angle(value);

	@:to public extern inline function toOperand(): ConstantOperand
		return Float(toFloat());

	@:op(A + B) function add(other: FloatLikeConstant): FloatLikeConstant {
		return switch this {
			case Float(valueA):
				switch other.toEnum() {
					case Float(valueB): fromFloat(valueA + valueB);
					case Angle(valueB): fromFloat(valueA + valueB.toDegrees());
				}
			case Angle(valueA):
				switch other.toEnum() {
					case Float(valueB): fromAngle(valueA + valueB);
					case Angle(valueB): fromAngle(valueA + valueB);
				}
		}
	}

	@:op(A * B) @:commutative static function multiply(
		constant: FloatLikeConstant,
		factor: Float
	): FloatLikeConstant {
		return switch constant {
			case Float(value): FloatLikeConstantEnum.Float(factor * value);
			case Angle(value): FloatLikeConstantEnum.Angle(factor * value);
		}
	}

	@:op(A * B) @:commutative static extern inline function multiplyInt(
		constant: FloatLikeConstant,
		factor: Int
	): FloatLikeConstant
		return multiply(constant, factor);

	@:op(A / B) function divide(divisor: Float): FloatLikeConstant {
		return switch this {
			case Float(value): FloatLikeConstantEnum.Float(value / divisor);
			case Angle(value): FloatLikeConstantEnum.Angle(value / divisor);
		}
	}

	@:op(A / B) extern inline function divideInt(divisor: Int): FloatLikeConstant
		return divide(divisor);

	/**
		Converts this `FloatLikeConstant` to `Float`.

		If the input value was `Angle`, the result is converted to radians.
	**/
	public function toFloat(): Float {
		return switch this {
			case Float(value): value;
			case Angle(value): value.toRadians();
		}
	}

	public function toAngle(): Angle {
		return switch this {
			case Float(value): Angle.fromDegrees(value);
			case Angle(value): value;
		}
	}

	public function toAzimuth(): Azimuth {
		return switch this {
			case Float(value): value;
			case Angle(value): Azimuth.zero + value;
		}
	}

	public extern inline function toEnum(): FloatLikeConstantEnum
		return this;
}
