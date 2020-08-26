package firedancer.types;

import reckoner.TmpVec2D;
import reckoner.Numeric.nearlyEqual;
import firedancer.vm.Geometry;

/**
	Azimuth value in degrees (north-based and clockwise, 360 for a full rotation).
**/
@:notNull @:forward(toRadians, toDegrees)
abstract Azimuth(Angle) {
	/**
		The north `Azimuth`.
	**/
	public static extern inline final zero: Azimuth = cast 0.0;

	/**
		Creates an `Azimuth` value from degrees.
	**/
	@:from public static extern inline function fromDegrees(degrees: Float): Azimuth {
		return new Azimuth(Angle.fromDegrees(degrees));
	}

	/**
		Creates an `Azimuth` value from radians.
	**/
	@:from public static extern inline function fromRadians(radians: Float): Azimuth {
		return new Azimuth(Angle.fromRadians(radians));
	}

	@:op(A + B) @:commutative
	static extern inline function add(azimuth: Azimuth, displacement: Angle): Azimuth {
		return new Azimuth(azimuth.toAngle() + displacement);
	}

	@:op(A - B)
	static extern inline function subtract(
		azimuth: Azimuth,
		displacement: Angle
	): Azimuth {
		return new Azimuth(azimuth.toAngle() - displacement);
	}

	public extern inline function toAngle(): Angle
		return this;

	/**
		Creates a 2D vector from a given `length` and `this` azimuth.

		Should not be used in runtime as this also does some error correction.
	**/
	public extern inline function toVec2D(length: Float): TmpVec2D {
		final unitVec = Geometry.toUnitVec(this.toRadians());

		var xFactor = unitVec.x;

		if (nearlyEqual(xFactor, 0.0)) xFactor = 0.0;
		if (nearlyEqual(xFactor, 1.0)) xFactor = 1.0;
		if (nearlyEqual(xFactor, -1.0)) xFactor = -1.0;
		if (nearlyEqual(xFactor, 0.5)) xFactor = 0.5;
		if (nearlyEqual(xFactor, -0.5)) xFactor = -0.5;

		var yFactor = unitVec.y;

		if (nearlyEqual(yFactor, 0.0)) yFactor = 0.0;
		if (nearlyEqual(yFactor, 1.0)) yFactor = 1.0;
		if (nearlyEqual(yFactor, -1.0)) yFactor = -1.0;
		if (nearlyEqual(yFactor, 0.5)) yFactor = 0.5;
		if (nearlyEqual(yFactor, -0.5)) yFactor = -0.5;

		return { x: xFactor * length, y: yFactor * length };
	}

	extern inline function new(angle: Angle)
		this = angle;
}
