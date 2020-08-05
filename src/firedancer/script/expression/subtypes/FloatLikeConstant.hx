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

	@:op(-A) function unaryMinus(): FloatLikeConstant {
		return switch this {
			case Float(value): Float(-value);
			case Angle(value): Angle(-value);
		}
	}

	@:op(A + B) static function add(
		a: FloatLikeConstant,
		b: FloatLikeConstant
	): FloatLikeConstant {
		return switch a.toEnum() {
			case Float(valueA):
				switch b.toEnum() {
					case Float(valueB): fromFloat(valueA + valueB);
					case Angle(valueB): fromFloat(valueA + valueB.toDegrees());
				}
			case Angle(valueA):
				switch b.toEnum() {
					case Float(valueB): fromAngle(valueA + valueB);
					case Angle(valueB): fromAngle(valueA + valueB);
				}
		}
	}

	@:op(A - B) static function subtract(
		a: FloatLikeConstant,
		b: FloatLikeConstant
	): FloatLikeConstant {
		return switch a.toEnum() {
			case Float(valueA):
				switch b.toEnum() {
					case Float(valueB): fromFloat(valueA - valueB);
					case Angle(valueB): fromFloat(valueA - valueB.toDegrees());
				}
			case Angle(valueA):
				switch b.toEnum() {
					case Float(valueB): fromAngle(valueA - valueB);
					case Angle(valueB): fromAngle(valueA - valueB);
				}
		}
	}

	@:op(A * B) static function multiply(
		a: FloatLikeConstant,
		b: FloatLikeConstant
	): FloatLikeConstant {
		return switch a.toEnum() {
			case Float(valueA):
				switch b.toEnum() {
					case Float(valueB): fromFloat(valueA * valueB);
					case Angle(valueB): fromAngle(valueA * valueB.toDegrees());
				}
			case Angle(valueA):
				switch b.toEnum() {
					case Float(valueB): fromAngle(valueA * valueB);
					case Angle(valueB): fromFloat(valueA.toDegrees() * valueB.toDegrees());
				}
		}
	}

	@:op(A / B) static function divide(
		a: FloatLikeConstant,
		b: FloatLikeConstant
	): FloatLikeConstant {
		return switch a.toEnum() {
			case Float(valueA):
				switch b.toEnum() {
					case Float(valueB): fromFloat(valueA / valueB);
					case Angle(valueB): fromAngle(valueA / valueB.toDegrees());
				}
			case Angle(valueA):
				switch b.toEnum() {
					case Float(valueB): fromAngle(valueA / valueB);
					case Angle(valueB): fromFloat(valueA.toDegrees() / valueB.toDegrees());
				}
		}
	}

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
