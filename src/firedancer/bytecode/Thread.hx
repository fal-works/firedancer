package firedancer.bytecode;

import banker.binary.ByteStackData;
import firedancer.common.MathStatics.hypot;
import firedancer.common.MathStatics.atan2;
import firedancer.common.Vec2DStatics.*;

/**
	Virtual thread for running `firedancer` bytecode.
**/
class Thread {
	/**
		`true` if `this` thread is currently in use.
	**/
	public var active: Bool;

	/**
		Bytecode to be run.
	**/
	public var code: Maybe<BytecodeData>;

	/**
		Thre length of `code` in bytes.
	**/
	public var codeLength: UInt;

	/**
		Current position in `code`.
	**/
	public var codePos: UInt;

	/**
		The stack for `this` this.
	**/
	public var stack: ByteStackData;

	/**
		The size of data in bytes currently stored in `stack`.
	**/
	public var stackSize: UInt;

	/**
		X-component of the current shot position.
	**/
	public var shotX: Float;

	/**
		Y-component of the current shot position.
	**/
	public var shotY: Float;

	/**
		X-component of the current shot velocity.
	**/
	public var shotVx: Float;

	/**
		Y-component of the current shot velocity.
	**/
	public var shotVy: Float;

	/**
		@param stackCapacity The capacity of the stack in bytes.
	**/
	public function new(stackCapacity: UInt) {
		this.active = false;
		this.code = Maybe.none();
		this.codeLength = UInt.zero;
		this.codePos = UInt.zero;
		this.stack = ByteStackData.alloc(stackCapacity);
		this.stackSize = UInt.zero;
		this.shotX = 0.0;
		this.shotY = 0.0;
		this.shotVx = 0.0;
		this.shotVy = 0.0;
	}

	/**
		Sets bytecode and initial shot position/velocity.
	**/
	public extern inline function set(
		code: Bytecode,
		shotX: Float,
		shotY: Float,
		shotVx: Float,
		shotVy: Float
	): Void {
		this.active = true;
		this.code = Maybe.from(code.data);
		this.codeLength = code.length;
		this.codePos = UInt.zero;
		this.stackSize = UInt.zero;
		this.shotX = shotX;
		this.shotY = shotY;
		this.shotVx = shotVx;
		this.shotVy = shotVy;
	}

	/**
		Updates values of `this` this.
		Called in `Vm.run()`.
	**/
	public extern inline function update(codePos: UInt, stackSize: UInt): Void {
		this.codePos = codePos;
		this.stackSize = stackSize;
	}

	/**
		Deactivates `this` thread and removes the bytecode attached.
	**/
	public extern inline function deactivate(): Void {
		this.active = false;
		this.code = Maybe.none();
	}

	/**
		Resets shot position/velocity.
	**/
	public extern inline function resetShot(): Void {
		this.shotX = 0.0;
		this.shotY = 0.0;
		this.shotVx = 0.0;
		this.shotVy = 0.0;
	}

	/**
		Resets all properties of `this` thread.
	**/
	public extern inline function reset(): Void {
		this.deactivate();
		this.codeLength = UInt.zero;
		this.codePos = UInt.zero;
		this.stackSize = UInt.zero;
		this.resetShot();
	}

	/**
		@return The length of current shot position vector.
	**/
	public extern inline function getShotDistance(): Float
		return hypot(this.shotX, this.shotY);

	/**
		@return The angle of current shot position vector.
	**/
	public extern inline function getShotBearing(): Float
		return atan2(this.shotY, this.shotX);

	/**
		@return The length of current shot velocity vector.
	**/
	public extern inline function getShotSpeed(): Float
		return hypot(this.shotVx, this.shotVy);

	/**
		@return The angle of current shot velocity vector.
	**/
	public extern inline function getShotDirection(): Float
		return atan2(this.shotVy, this.shotVx);


	public extern inline function setShotPosition(x: Float, y: Float): Void {
		this.shotX = x;
		this.shotY = y;
	}

	public extern inline function addShotPosition(x: Float, y: Float): Void {
		this.shotX += x;
		this.shotY += y;
	}

	public extern inline function setShotVelocity(vx: Float, vy: Float): Void {
		this.shotVx = vx;
		this.shotVy = vy;
	}

	public extern inline function addShotVelocity(vx: Float, vy: Float): Void {
		this.shotVx += vx;
		this.shotVy += vy;
	}

	public extern inline function setShotDistance(value: Float): Void {
		final newPosition = setLength(this.shotX, this.shotY, value);
		setShotPosition(newPosition.x, newPosition.y);
	}

	public extern inline function addShotDistance(value: Float): Void {
		final newPosition = addLength(this.shotX, this.shotY, value);
		setShotPosition(newPosition.x, newPosition.y);
	}

	public extern inline function setShotBearing(value: Float): Void {
		final newPosition = setAngle(this.shotX, this.shotY, value);
		setShotPosition(newPosition.x, newPosition.y);
	}

	public extern inline function addShotBearing(value: Float): Void {
		final newPosition = addAngle(this.shotX, this.shotY, value);
		setShotPosition(newPosition.x, newPosition.y);
	}

	public extern inline function setShotSpeed(value: Float): Void {
		final newVelocity = setLength(this.shotVx, this.shotVy, value);
		setShotVelocity(newVelocity.x, newVelocity.y);
	}

	public extern inline function addShotSpeed(value: Float): Void {
		final newVelocity = addLength(this.shotVx, this.shotVy, value);
		setShotVelocity(newVelocity.x, newVelocity.y);
	}

	public extern inline function setShotDirection(value: Float): Void {
		final newVelocity = setAngle(this.shotVx, this.shotVy, value);
		setShotVelocity(newVelocity.x, newVelocity.y);
	}

	public extern inline function addShotDirection(value: Float): Void {
		final newVelocity = addAngle(this.shotVx, this.shotVy, value);
		setShotVelocity(newVelocity.x, newVelocity.y);
	}
}
