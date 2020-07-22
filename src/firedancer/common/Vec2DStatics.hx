package firedancer.common;

import firedancer.types.TmpVec2DPolar;
import firedancer.types.TmpVec2D;
import firedancer.common.MathStatics.hypot;
import firedancer.common.MathStatics.atan2;

/**
	Static functions for 2D vector.
**/
class Vec2DStatics {
	/**
		Sets the length of vector `(x, y)` to `length`.
		The return value must be directly assigned to a local variable.
	**/
	public static extern inline function setLength(
		x: Float,
		y: Float,
		length: Float
	): TmpVec2D {
		return TmpVec2D.fromPolar(length, atan2(y, x));
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
		final cur = TmpVec2DPolar.fromCartesian(x, y);
		return TmpVec2D.fromPolar(cur.length + lengthToAdd, cur.angle);
	}

	/**
		Sets the angle of vector `(x, y)` to `angle`.
		The return value must be directly assigned to a local variable.
	**/
	public static extern inline function setAngle(
		x: Float,
		y: Float,
		angle: Float
	): TmpVec2D {
		return TmpVec2D.fromPolar(hypot(x, y), angle);
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
		final cur = TmpVec2DPolar.fromCartesian(x, y);
		return TmpVec2D.fromPolar(cur.length, cur.angle + angleToAdd);
	}
}
