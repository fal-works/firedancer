package firedancer.types;

import reckoner.ArcDegrees;

/**
	Angle in degrees (clockwise, 360 for a full rotation).
**/
@:notNull @:forward(toRadians)
abstract Angle(ArcDegrees) from ArcDegrees from Float {
	/**
		Explicitly casts `Float` (in degrees) to `Angle`.
	**/
	public static extern inline function fromDegrees(degrees: Float): Angle
		return ArcDegrees.from(degrees);

	@:op(A + B) function plus(other: Angle): Angle;

	@:op(A - B) function minus(other: Angle): Angle;

	@:op(A * B) @:commutative static function multiply(angle: Angle, factor: Float): Angle;

	@:op(A * B) @:commutative static function multiplyInt(angle: Angle, factor: Int): Angle;

	@:op(A / B) function divide(divisor: Float): Angle;

	@:op(A / B) function divideInt(divisor: Int): Angle;

	/**
		Casts `this` to `Float` in degrees.
	**/
	public inline function toDegrees(): Float
		return this;
}
