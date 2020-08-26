package firedancer.bytecode;

import banker.vector.WritableVector as Vec;
import firedancer.types.PositionRef;

/**
	Holds actor's position (relative from the origin) temporarily in the `Vm`.
**/
class TmpPosition {
	/**
		The x-component of the origin point position.
	**/
	public final originX: Float;

	/**
		The y-component of the origin point position.
	**/
	public final originY: Float;

	/**
		The x-component of the position relative from the origin.
	**/
	public var x: Float;

	/**
		The y-component of the position relative from the origin.
	**/
	public var y: Float;

	/**
		Sets position values according to `x`, `y` and `originPositionRef`.

		If `originPositionRef` is no more valid, also unlinks it from `originPositionRefVec`.

		@param x The x-coordinate of the current absolute position.
		@param y The y-coordinate of the current absolute position.
		@param originPositionRef The reference to the origin point.
		@param originPositionRefVec The vector that contains `originPositionRef`.
		@param vecIndex The index of `originPositionRef` in `originPositionRefVec`.
	**/
	public extern inline function new(
		x: Float,
		y: Float,
		originPositionRef: Maybe<PositionRef>,
		originPositionRefVec: Vec<Maybe<PositionRef>>,
		vecIndex: UInt
	) {
		if (originPositionRef.isNone()) {
			this.originX = this.originY = 0.0;
			this.x = x;
			this.y = y;
		} else {
			final origin = originPositionRef.unwrap();
			if (origin.isValid()) {
				this.originX = origin.x;
				this.originY = origin.y;
				this.x = x - this.originX;
				this.y = y - this.originY;
			} else {
				originPositionRefVec[vecIndex] = Maybe.none();
				this.originX = this.originY = 0.0;
				this.x = x;
				this.y = y;
			}
		}
	}

	/**
		Sets the position to `(x, y)`.
	**/
	public extern inline function set(x: Float, y: Float): Void {
		this.x = x;
		this.y = y;
	}

	/**
		Adds `(x, y)` to the position.
	**/
	public extern inline function add(x: Float, y: Float): Void {
		this.x += x;
		this.y += y;
	}

	/**
		@return The length component of the position.
	**/
	public extern inline function getDistance(): Float
		return Geometry.getLength(this.x, this.y);

	/**
		@return The angle component of the position.
	**/
	public extern inline function getBearing(): Float
		return Geometry.getAngle(this.x, this.y);

	/**
		Sets the length component of the position to `value`.
	**/
	public extern inline function setDistance(value: Float): Void {
		final newPosition = Geometry.setLength(this.x, this.y, value);
		this.set(newPosition.x, newPosition.y);
	}

	/**
		Sets the angle component of the position to `value`.
	**/
	public extern inline function setBearing(value: Float): Void {
		final newPosition = Geometry.setAngle(this.x, this.y, value);
		this.set(newPosition.x, newPosition.y);
	}

	/**
		Adds `value` to the length component of the position.
	**/
	public extern inline function addDistance(value: Float): Void {
		final newPosition = Geometry.addLength(this.x, this.y, value);
		this.set(newPosition.x, newPosition.y);
	}

	/**
		Adds `value` to the angle component of the position.
	**/
	public extern inline function addBearing(value: Float): Void {
		final newPosition = Geometry.addAngle(this.x, this.y, value);
		this.set(newPosition.x, newPosition.y);
	}

	/**
		@return The x-component of the absolute position.
	**/
	public extern inline function getAbsoluteX(): Float
		return this.originX + this.x;

	/**
		@return The y-component of the absolute position.
	**/
	public extern inline function getAbsoluteY(): Float
		return this.originY + this.y;
}
