package firedancer.types;

import firedancer.common.MathStatics;

/**
	Azimuth value.
	Implicit cast from degrees. The internal representation is in radians.
**/
abstract Azimuth(Float) {
	/**
		The north `Azimuth`.
	**/
	public static extern inline final zero = fromDegrees(0.0);

	/**
		Creates an `Azimuth` value from degrees (north-based and clockwise, 360 for a full rotation).
	**/
	@:from public static extern inline function fromDegrees(degrees: Float): Azimuth {
		return new Azimuth(MathStatics.DEG_TO_RAD * (degrees - 90.0));
	}

	@:commutative @:op(A + B) static extern inline function plus(
		azimuth: Azimuth,
		displacement: AzimuthDisplacement
	): Azimuth {
		return new Azimuth(azimuth.toRadians() + displacement.toRadians());
	}

	@:op(A - B) extern inline function minus(
		displacement: AzimuthDisplacement
	): Azimuth {
		return new Azimuth(this - displacement.toRadians());
	}

	/**
		Casts `this` to `Float` in radians.
	**/
	public extern inline function toRadians(): Float
		return this;

	/**
		@return Trigonometric cosine of `this` azimuth.
	**/
	public extern inline function cos(): Float
		return MathStatics.cos(toRadians());

	/**
		@return Trigonometric sine of `this` azimuth.
	**/
	public extern inline function sin(): Float
		return MathStatics.sin(toRadians());

	extern inline function new(radians: Float)
		this = MathStatics.normalizeAngle(radians);
}
