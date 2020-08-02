package firedancer.types;

import reckoner.Geometry;

/**
	Angle in degrees (clockwise, 360 for a full rotation).
**/
abstract AzimuthDisplacement(Float) from Float {
	public static extern inline final zero: AzimuthDisplacement = 0.0;

	public static extern inline function fromDegrees(v: Float): AzimuthDisplacement
		return v;

	@:op(A + B) function plus(other: AzimuthDisplacement): AzimuthDisplacement;

	@:op(A - B) function minus(other: AzimuthDisplacement): AzimuthDisplacement;

	@:op(A * B) function multiply(factor: Float): AzimuthDisplacement;

	@:op(A / B) function divide(divisor: Float): AzimuthDisplacement;

	/**
		Casts `this` to `Float` in radians.
	**/
	public extern inline function toRadians(): Float
		return Geometry.degreesToRadians(this);

	/**
		Converts `this` to `Float` in degrees.
	**/
	public inline function toDegrees(): Float
		return this;
}
