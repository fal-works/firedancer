package firedancer.bytecode;

/**
	Holds actor's velocity temporarily in the `Vm`.
**/
class TmpVelocity {
	/**
		The x-component of the velocity.
	**/
	public var x: Float;

	/**
		The y-component of the velocity.
	**/
	public var y: Float;

	/**
		Sets velocity values.

		@param vx The x-coordinate of the current velocity.
		@param vy The y-coordinate of the current velocity.
	**/
	public extern inline function new(vx: Float, vy: Float) {
		this.x = vx;
		this.y = vy;
	}

	/**
		Sets the velocity to `(x, y)`.
	**/
	public extern inline function set(x: Float, y: Float): Void {
		this.x = x;
		this.y = y;
	}

	/**
		Adds `(x, y)` to the velocity.
	**/
	public extern inline function add(x: Float, y: Float): Void {
		this.x += x;
		this.y += y;
	}

	/**
		@return The length component of the velocity.
	**/
	public extern inline function getSpeed(): Float
		return Geometry.getLength(this.x, this.y);

	/**
		@return The angle component of the velocity.
	**/
	public extern inline function getDirection(): Float
		return Geometry.getAngle(this.x, this.y);

	/**
		Sets the length component of the velocity to `value`.
	**/
	public extern inline function setSpeed(value: Float): Void {
		final newVelocity = Geometry.setLength(this.x, this.y, value);
		this.set(newVelocity.x, newVelocity.y);
	}

	/**
		Sets the angle component of the velocity to `value`.
	**/
	public extern inline function setDirection(value: Float): Void {
		final newVelocity = Geometry.setAngle(this.x, this.y, value);
		this.set(newVelocity.x, newVelocity.y);
	}

	/**
		Adds `value` to the length component of the velocity.
	**/
	public extern inline function addSpeed(value: Float): Void {
		final newVelocity = Geometry.addLength(this.x, this.y, value);
		this.set(newVelocity.x, newVelocity.y);
	}

	/**
		Adds `value` to the angle component of the velocity.
	**/
	public extern inline function addDirection(value: Float): Void {
		final newVelocity = Geometry.addAngle(this.x, this.y, value);
		this.set(newVelocity.x, newVelocity.y);
	}
}
