package firedancer.types;

import firedancer.common.MathStatics.hypot;
import firedancer.common.MathStatics.atan2;

/**
	2D vector of float values.

	For temporal use only.
	The instance must be directly assigned to a local variable
	as this class has an `inline` constructor.
**/
@:structInit
class TmpVec2DPolar {
	/**
		Creates a `TmpVec2DPolar` instance from cartesian coordinates.
	**/
	public static extern inline function fromCartesian(x: Float, y: Float): TmpVec2DPolar {
		return new TmpVec2DPolar(hypot(x, y), atan2(y, x));
	}

	public final length: Float;
	public final angle: Float;

	public extern inline function new(length: Float, angle: Float) {
		this.length = length;
		this.angle = angle;
	}
}
