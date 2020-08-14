package firedancer.bytecode;

import haxe.Int32;

/**
	Virtual memory for use in the `Vm`.
**/
@:nullSafety(Off)
class Memory {
	/**
		The stack pointer.
		Indicates the current position in `data`.
	**/
	public var sp: UInt;

	/**
		The end address of `this` memory, i.e. the capacity of `data` (which should be always the same).
	**/
	final capacity: UInt;

	/**
		The memory data.
	**/
	var data: MemoryData;

	public extern inline function new(capacity: UInt) {
		this.capacity = capacity;
	}

	public extern inline function reset(thread: Thread): Void {
		this.data = thread.memoryData;
		this.sp = thread.stackPointer;
	}

	public extern inline function pushInt(v: Int32): Void
		sp = data.stack.pushI32(sp, v);

	public extern inline function pushFloat(v: Float): Void
		sp = data.stack.pushF64(sp, v);

	public extern inline function pushVec(x: Float, y: Float): Void {
		sp = data.stack.pushF64(sp, x);
		sp = data.stack.pushF64(sp, y);
	}

	public extern inline function popInt(): Int32 {
		final ret = data.stack.popI32(sp);
		sp = ret.size;
		return ret.value;
	}

	public extern inline function popFloat(): Float {
		final ret = data.stack.popF64(sp);
		sp = ret.size;
		return ret.value;
	}

	public extern inline function peekInt(): Int32
		return data.stack.peekI32(sp);

	public extern inline function peekFloat(): Float
		return data.stack.peekF64(sp);

	public extern inline function peekFloatSkipped(bytesToSkip: Int): Float
		return data.stack.peekF64(sp - bytesToSkip);

	public extern inline function peekVecSkipped(bytesToSkip: Int)
		return data.stack.peekVec2D64(sp - bytesToSkip);

	public extern inline function dropInt(): Void
		sp = data.stack.drop(sp, Bit32);

	public extern inline function dropFloat(): Void
		sp = data.stack.drop(sp, Bit64);

	public extern inline function dropVec(): Void
		sp = data.stack.drop2D(sp, Bit64);

	public extern inline function decrement(): Void
		data.stack.decrement32(sp);

	public extern inline function getLocalInt(address: Int): Int
		return data.variables.getInt(capacity, address);

	public extern inline function getLocalFloat(address: Int): Float
		return data.variables.getFloat(capacity, address);

	public extern inline function setLocalInt(address: Int, value: Int): Void
		data.variables.setInt(capacity, address, value);

	public extern inline function setLocalFloat(address: Int, value: Float): Void
		data.variables.setFloat(capacity, address, value);

	public extern inline function addLocalInt(address: Int, value: Int): Void
		data.variables.addInt(capacity, address, value);

	public extern inline function addLocalFloat(address: Int, value: Float): Void
		data.variables.addFloat(capacity, address, value);
}
