package firedancer.types;

import firedancer.common.MathStatics.cos;
import firedancer.common.MathStatics.sin;

/**
	2D vector of float values.

	For temporal use only.
	The instance must be directly assigned to a local variable
	as this class has an `inline` constructor.
**/
@:structInit
class TmpVec2D {
	/**
		Creates a `TmpVec2D` instance from polar coordinates.
		@param length Length of vector.
		@param angle Angle of vector in radians.
	**/
	public static extern inline function fromPolar(length: Float, angle: Float): TmpVec2D {
		return new TmpVec2D(length * cos(angle), length * sin(angle));
	}

	public final x: Float;
	public final y: Float;

	public extern inline function new(x: Float, y: Float) {
		this.x = x;
		this.y = y;
	}
}
