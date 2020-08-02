package firedancer.types;

import reckoner.Geometry;
import reckoner.Numeric.nearlyEqual;

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
		return new Azimuth(Geometry.degreesToRadians(degrees - 90.0));
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
		Converts `this` to `Float` in degrees
		(north-based and clockwise, 360 for a full rotation).
	**/
	public inline function toDegrees(): Float
		return Geometry.radiansToDegrees(this) + 90.0;

	/**
		Returns trigonometric cosine of `this` azimuth.

		Should not be used in runtime as this also does some error correction.
	**/
	public function cos(): Float {
		final value = Geometry.cos(toRadians());

		return if (nearlyEqual(value, 0.0)) 0.0;
		else if (nearlyEqual(value, 1.0)) 1.0;
		else if (nearlyEqual(value, -1.0)) -1.0;
		else if (nearlyEqual(value, 0.5)) 0.5;
		else if (nearlyEqual(value, -0.5)) -0.5;
		else value;
	}

	/**
		Returns trigonometric sine of `this` azimuth.

		Should not be used in runtime as this also does some error correction.
	**/
	public function sin(): Float {
		final value = Geometry.sin(toRadians());

		return if (nearlyEqual(value, 0.0)) 0.0;
		else if (nearlyEqual(value, 1.0)) 1.0;
		else if (nearlyEqual(value, -1.0)) -1.0;
		else if (nearlyEqual(value, 0.5)) 0.5;
		else if (nearlyEqual(value, -0.5)) -0.5;
		else value;
	}

	extern inline function new(radians: Float)
		this = Geometry.normalizeAngle(radians);
}
