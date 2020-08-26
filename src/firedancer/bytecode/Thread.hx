package firedancer.bytecode;

import firedancer.bytecode.internal.MemoryData;

/**
	Virtual thread for running firedancer program.
**/
class Thread {
	/**
		`true` if `this` thread is currently in use.
	**/
	public var active: Bool;

	/**
		Bytecode to run in `this` thread.
	**/
	public var code: Maybe<Bytecode>;

	/**
		Thre length of `code` in bytes.
	**/
	public var codeLength: UInt;

	/**
		Current position in `code`.
	**/
	public var programCounter: UInt;

	/**
		The memory data for `this` thread.
	**/
	public var memoryData: MemoryData;

	/**
		The size of stack data in bytes currently stored in `memoryData`.
	**/
	public var stackPointer: UInt;

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
		@param memoryCapacity The capacity of the memory in bytes.
	**/
	public function new(memoryCapacity: UInt) {
		this.active = false;
		this.code = Maybe.none();
		this.codeLength = UInt.zero;
		this.programCounter = UInt.zero;
		this.memoryData = MemoryData.alloc(memoryCapacity);
		this.stackPointer = UInt.zero;
		this.shotX = 0.0;
		this.shotY = 0.0;
		this.shotVx = 0.0;
		this.shotVy = 0.0;
	}

	/**
		Sets program and initializes other properties
	**/
	public extern inline function set(
		code: Program,
		shotX: Float,
		shotY: Float,
		shotVx: Float,
		shotVy: Float
	): Void {
		this.active = true;
		this.code = Maybe.from(code.data);
		this.codeLength = code.length;
		this.programCounter = UInt.zero;
		this.stackPointer = UInt.zero;
		this.shotX = shotX;
		this.shotY = shotY;
		this.shotVx = shotVx;
		this.shotVy = shotVy;
	}

	/**
		Updates values of `this` thread.
		Called in the `Vm`.
	**/
	public extern inline function update(programCounter: UInt, stackPointer: UInt): Void {
		this.programCounter = programCounter;
		this.stackPointer = stackPointer;
	}

	/**
		Deactivates `this` thread and removes the program attached.
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
		this.programCounter = UInt.zero;
		this.stackPointer = UInt.zero;
		this.resetShot();
	}

	/**
		@return The length of current shot position vector.
	**/
	public extern inline function getShotDistance(): Float
		return Geometry.getLength(this.shotX, this.shotY);

	/**
		@return The angle of current shot position vector.
	**/
	public extern inline function getShotBearing(): Float
		return Geometry.getAngle(this.shotX, this.shotY);

	/**
		@return The length of current shot velocity vector.
	**/
	public extern inline function getShotSpeed(): Float
		return Geometry.getLength(this.shotVx, this.shotVy);

	/**
		@return The angle of current shot velocity vector.
	**/
	public extern inline function getShotDirection(): Float
		return Geometry.getAngle(this.shotVx, this.shotVy);

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
		final newPosition = Geometry.setLength(this.shotX, this.shotY, value);
		setShotPosition(newPosition.x, newPosition.y);
	}

	public extern inline function addShotDistance(value: Float): Void {
		final newPosition = Geometry.addLength(this.shotX, this.shotY, value);
		setShotPosition(newPosition.x, newPosition.y);
	}

	public extern inline function setShotBearing(value: Float): Void {
		final newPosition = Geometry.setAngle(this.shotX, this.shotY, value);
		setShotPosition(newPosition.x, newPosition.y);
	}

	public extern inline function addShotBearing(value: Float): Void {
		final newPosition = Geometry.addAngle(this.shotX, this.shotY, value);
		setShotPosition(newPosition.x, newPosition.y);
	}

	public extern inline function setShotSpeed(value: Float): Void {
		final newVelocity = Geometry.setLength(this.shotVx, this.shotVy, value);
		setShotVelocity(newVelocity.x, newVelocity.y);
	}

	public extern inline function addShotSpeed(value: Float): Void {
		final newVelocity = Geometry.addLength(this.shotVx, this.shotVy, value);
		setShotVelocity(newVelocity.x, newVelocity.y);
	}

	public extern inline function setShotDirection(value: Float): Void {
		final newVelocity = Geometry.setAngle(this.shotVx, this.shotVy, value);
		setShotVelocity(newVelocity.x, newVelocity.y);
	}

	public extern inline function addShotDirection(value: Float): Void {
		final newVelocity = Geometry.addAngle(this.shotVx, this.shotVy, value);
		setShotVelocity(newVelocity.x, newVelocity.y);
	}
}
