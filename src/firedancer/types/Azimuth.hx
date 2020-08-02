package firedancer.types;

import reckoner.Geometry;
import reckoner.Numeric.nearlyEqual;

/**
	Azimuth value in degrees (north-based and clockwise, 360 for a full rotation).
**/
@:notNull @:forward(toRadians, toDegrees)
abstract Azimuth(AzimuthDisplacement) from AzimuthDisplacement to AzimuthDisplacement {
	/**
		The north `Azimuth`.
	**/
	public static extern inline final zero = AzimuthDisplacement.zero;

	/**
		Creates an `Azimuth` value from degrees (north-based and clockwise, 360 for a full rotation).
	**/
	@:from public static extern inline function fromDegrees(degrees: Float): Azimuth
		return AzimuthDisplacement.fromDegrees(degrees);

	@:commutative @:op(A + B) static extern inline function plus(
		azimuth: Azimuth,
		displacement: AzimuthDisplacement
	): Azimuth {
		return (azimuth : AzimuthDisplacement) + displacement;
	}

	@:op(A - B) extern inline function minus(displacement: AzimuthDisplacement): Azimuth
		return this - displacement;

	/**
		Returns trigonometric cosine of `this` azimuth.

		Should not be used in runtime as this also does some error correction.
	**/
	public function cos(): Float {
		final value = Geometry.cos(this.toRadians() + Geometry.MINUS_HALF_PI);

		if (nearlyEqual(value, 0.0)) return 0.0;
		if (nearlyEqual(value, 1.0)) return 1.0;
		if (nearlyEqual(value, -1.0)) return -1.0;
		if (nearlyEqual(value, 0.5)) return 0.5;
		if (nearlyEqual(value, -0.5)) return -0.5;

		return value;
	}

	/**
		Returns trigonometric sine of `this` azimuth.

		Should not be used in runtime as this also does some error correction.
	**/
	public function sin(): Float {
		final value = Geometry.sin(this.toRadians() + Geometry.MINUS_HALF_PI);

		if (nearlyEqual(value, 0.0)) return 0.0;
		if (nearlyEqual(value, 1.0)) return 1.0;
		if (nearlyEqual(value, -1.0)) return -1.0;
		if (nearlyEqual(value, 0.5)) return 0.5;
		if (nearlyEqual(value, -0.5)) return -0.5;

		return value;
	}
}
