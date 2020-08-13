package firedancer.bytecode;

/**
	Set of virtual registers used in the `Vm`.
**/
@:nullSafety(Off)
class RegisterFile {
	/**
		The program counter.
		Indicates the current position in the bytecode.
	**/
	public var pc: UInt;

	/**
		The upper bound of the value of `pc` i.e. the length of the bytecode.
	**/
	public var pcMax(default, null): UInt;

	/**
		The stack pointer.
		Indicates the current position in the stack.
	**/
	public var sp: UInt;

	/**
		The main integer data register.
	**/
	public var int: Int;

	/**
		The integer data register used for temporarily saving the value of `int`.
	**/
	public var intBuf: Int;

	/**
		The main floating-point data register.
	**/
	public var float: Float;

	/**
		The floating-point data regsiter for temporarily saving the value of `float`.
	**/
	public var floatBuf: Float;

	/**
		The data register for holding the x-component of a 2D vector.
	**/
	public var vecX: Float;

	/**
		The data register for holding the y-component of a 2D vector.
	**/
	public var vecY: Float;

	#if debug
	/**
		Number of instructions that have been executed in the current frame.
		Used for detecting infinite loop in debug mode.
	**/
	public var cnt: UInt;
	#end

	public extern inline function new() {}

	/**
		Resets all address registers according to the status of `thread` and
		initializes all data registers with zero value.
	**/
	public extern inline function reset(thread: Thread): Void {
		this.pc = thread.programCounter;
		this.pcMax = thread.codeLength;
		this.sp = thread.stackPointer;

		this.int = 0;
		this.intBuf = 0;
		this.float = 0.0;
		this.floatBuf = 0.0;
		this.vecX = 0.0;
		this.vecY = 0.0;

		#if debug
		this.cnt = UInt.zero;
		#end
	}

	/**
		Short hand for assigning values to `vecX` and `vecY`.
	**/
	public extern inline function setVec(x: Float, y: Float): Void {
		this.vecX = x;
		this.vecY = y;
	}

	/**
		Copies the value of `int` to `intBuf`.
	**/
	public extern inline function saveInt(): Void
		this.intBuf = this.int;

	/**
		Copies the value of `float` to `floatBuf`.
	**/
	public extern inline function saveFloat(): Void
		this.floatBuf = this.float;
}
