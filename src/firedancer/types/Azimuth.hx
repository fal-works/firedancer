package firedancer.types;

import reckoner.TmpVec2D;
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
		Creates a 2D vector from a given `length` and `this` azimuth.

		Should not be used in runtime as this also does some error correction.
	**/
	public extern inline function toVec2D(length: Float): TmpVec2D {
		var xFactor = Geometry.sin(this.toRadians());

		if (nearlyEqual(xFactor, 0.0)) xFactor = 0.0;
		if (nearlyEqual(xFactor, 1.0)) xFactor = 1.0;
		if (nearlyEqual(xFactor, -1.0)) xFactor = -1.0;
		if (nearlyEqual(xFactor, 0.5)) xFactor = 0.5;
		if (nearlyEqual(xFactor, -0.5)) xFactor = -0.5;

		var yFactor = -Geometry.cos(this.toRadians());

		if (nearlyEqual(yFactor, 0.0)) yFactor = 0.0;
		if (nearlyEqual(yFactor, 1.0)) yFactor = 1.0;
		if (nearlyEqual(yFactor, -1.0)) yFactor = -1.0;
		if (nearlyEqual(yFactor, 0.5)) yFactor = 0.5;
		if (nearlyEqual(yFactor, -0.5)) yFactor = -0.5;

		return { x: xFactor * length, y: yFactor * length };
	}
}
