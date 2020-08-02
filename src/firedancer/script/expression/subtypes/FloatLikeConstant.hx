package firedancer.script.expression.subtypes;

import firedancer.assembly.Operand;
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
			case AzimuthDisplacement(value): throw "Cannot convert to Azimuth.";
		}
	}

	@:to public extern inline function toOperand(): Operand
		return Float(toFloat());

	@:op(A / B) function divide(divisor: Float): FloatLikeConstant {
		return switch this {
			case Float(value): FloatLikeConstantEnum.Float(value / divisor);
			case Azimuth(_): throw "Cannot divide Azimuth value.";
			case AzimuthDisplacement(value): FloatLikeConstantEnum.AzimuthDisplacement(value / divisor);
		}
	}

	@:op(A / B) extern inline function divideInt(divisor: Int): FloatLikeConstant
		return divide(divisor);

	public extern inline function toEnum(): FloatLikeConstant
		return this;
}
