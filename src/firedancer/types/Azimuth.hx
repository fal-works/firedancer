package firedancer.types;

import firedancer.common.MathStatics;

/**
	Azimuth in radians.
	Implicit cast from degrees. The internal representation is in radians.
**/
abstract Azimuth(Float) {
	static extern inline final DEG_TO_RAD = MathStatics.TWO_PI / 360.0;
	static extern inline final RAD_TO_DEG = 360.0 / MathStatics.TWO_PI;

	/**
		Creates an `Azimuth` value from degrees (north-based and clockwise, 360 for a full rotation).
	**/
	@:from public static extern inline function fromDegrees(degrees: Float): Azimuth {
		return new Azimuth((degrees - 90.0) * DEG_TO_RAD);
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
