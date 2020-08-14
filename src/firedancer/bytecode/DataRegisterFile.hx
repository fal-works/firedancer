package firedancer.bytecode;

/**
	Set of virtual data registers used in the `Vm`.
**/
@:nullSafety(Off)
class DataRegisterFile {
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

	public extern inline function new() {}

	/**
		initializes all data registers with zero value.
	**/
	public extern inline function reset(thread: Thread): Void {
		this.int = 0;
		this.intBuf = 0;
		this.float = 0.0;
		this.floatBuf = 0.0;
		this.vecX = 0.0;
		this.vecY = 0.0;
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
