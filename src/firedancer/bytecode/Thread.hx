package firedancer.bytecode;

import banker.binary.ByteStackData;

/**
	Virtual thread for running `firedancer` bytecode.
**/
class Thread {
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
		The stack for `this` thread.
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
		code: Maybe<Bytecode>,
		shotX: Float,
		shotY: Float,
		shotVx: Float,
		shotVy: Float
	): Void {
		if (code.isSome()) {
			this.code = Maybe.from(code.unwrap().data);
			this.codeLength = code.unwrap().length;
		} else {
			this.code = Maybe.none();
			this.codeLength = UInt.zero;
		}
		this.codePos = UInt.zero;
		this.stackSize = UInt.zero;
		this.shotX = shotX;
		this.shotY = shotY;
		this.shotVx = shotVx;
		this.shotVy = shotVy;
	}

	/**
		Resets `this` thread.
	**/
	public extern inline function reset(): Void {
		this.code = Maybe.none();
		this.codeLength = UInt.zero;
		this.codePos = UInt.zero;
		this.stackSize = UInt.zero;
		this.shotX = 0.0;
		this.shotY = 0.0;
		this.shotVx = 0.0;
		this.shotVy = 0.0;
	}
}
