package firedancer.common;

import reckoner.TmpVec2D;
import reckoner.Geometry.hypot;
import reckoner.Geometry.atan2;
import reckoner.Geometry.cos as rCos;
import reckoner.Geometry.sin as rSin;
import reckoner.Geometry.normalizeAngle;

/**
	Static functions for 2D vector with north-based angle values.
**/
class Geometry {
	/**
		@param angle Angle in radians.
		@return Trigonometric cosine of `angle`.
	**/
	public static extern inline function cos(angle: Float): Float
		return rCos(angle);

	/**
		@param angle Angle in radians.
		@return Trigonometric sine of `angle`.
	**/
	public static extern inline function sin(angle: Float): Float
		return rSin(angle);

	/**
		@return The north-based angle in radians from the origin to the point `(x, y)`.
	**/
	public static extern inline function getAngle(x: Float, y: Float): Float
		return atan2(x, -y);

	/**
		@return The length of vector `(x, y)`.
	**/
	public static extern inline function getLength(x: Float, y: Float): Float
		return hypot(x, y);

	/**
		@param angle The north-based azimuth angle in radians.
		@return Cartesian vector with `length` and `angle`.
		The return value must be directly assigned to a local variable.
	**/
	public static extern inline function toVec(length: Float, angle: Float): TmpVec2D {
		return new TmpVec2D(length * sin(angle), length * -cos(angle));
	}

	/**
		@param angle The north-based azimuth angle in radians.
		@return Cartesian unit vector with `angle`.
		The return value must be directly assigned to a local variable.
	**/
	public static extern inline function toUnitVec(angle: Float): TmpVec2D {
		return new TmpVec2D(sin(angle), -cos(angle));
	}

	/**
		Sets the length of vector `(x, y)` to `length`.
		The return value must be directly assigned to a local variable.
	**/
	public static extern inline function setLength(
		x: Float,
		y: Float,
		length: Float
	): TmpVec2D {
		return toVec(length, getAngle(x, y));
	}

	/**
		Adds `lengthToAdd` to the length of vector `(x, y)`.
		The return value must be directly assigned to a local variable.
	**/
	public static extern inline function addLength(
		x: Float,
		y: Float,
		lengthToAdd: Float
	): TmpVec2D {
		final curLen = getLength(x, y);
		final curAngle = getAngle(x, y);
		return toVec(curLen + lengthToAdd, curAngle);
	}

	/**
		Sets the angle of vector `(x, y)` to `angle`.
		The return value must be directly assigned to a local variable.
		@param angle The north-based azimuth angle in radians.
	**/
	public static extern inline function setAngle(
		x: Float,
		y: Float,
		angle: Float
	): TmpVec2D {
		return toVec(getLength(x, y), angle);
	}

	/**
		Adds `angleToAdd` to the angle of vector `(x, y)`.
		The return value must be directly assigned to a local variable.
	**/
	public static extern inline function addAngle(
		x: Float,
		y: Float,
		angleToAdd: Float
	): TmpVec2D {
		final curLen = getLength(x, y);
		final curAngle = getAngle(x, y);
		return toVec(curLen, curAngle + angleToAdd);
	}

	/**
		@return Difference of `angleB` from `angleA` (i.e. `B - A`),
		normalized in range between `-PI` and `PI`.
	**/
	public static extern inline function getAngleDifference(
		angleA: Float,
		angleB: Float
	): Float
		return normalizeAngle(angleB - angleA);
}
