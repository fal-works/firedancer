package firedancer.types;

import firedancer.common.MathStatics;

/**
	Displacement of `Azimuth`.
	Implicit cast from degrees. The internal representation is in radians.
**/
abstract AzimuthDisplacement(Float) {
	/**
		Creates an `AzimuthDisplacement` value from degrees (clockwise, 360 for a full rotation).
	**/
	@:from public static extern inline function fromDegrees(
		degrees: Float
	): AzimuthDisplacement {
		return new AzimuthDisplacement(MathStatics.DEG_TO_RAD * degrees);
	}

	@:op(A + B) extern inline function plus(
		other: AzimuthDisplacement
	): AzimuthDisplacement {
		return new AzimuthDisplacement(this + other.toRadians());
	}

	@:op(A - B) extern inline function minus(
		other: AzimuthDisplacement
	): AzimuthDisplacement {
		return new AzimuthDisplacement(this - other.toRadians());
	}

	@:op(A * B) extern inline function multiply(
		factor: Float
	): AzimuthDisplacement {
		return new AzimuthDisplacement(factor * this);
	}

	@:op(A / B) extern inline function divide(
		divisor: Float
	): AzimuthDisplacement {
		return new AzimuthDisplacement(this / divisor);
	}

	/**
		Casts `this` to `Float` in radians.
	**/
	public extern inline function toRadians(): Float
		return this;

	extern inline function new(radians: Float)
		this = radians;
}
