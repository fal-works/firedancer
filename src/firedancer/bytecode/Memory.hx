package firedancer.bytecode;

import haxe.Int32;
import sneaker.string_buffer.StringBuffer;
import banker.binary.ByteStackData;
import firedancer.bytecode.internal.Constants.*;

/**
	Virtual memory.
	Includes the stack and local variables.
**/
@:nullSafety(Off)
class Memory {
	/**
		The stack pointer.
		Indicates the current position in the stack.
	**/
	public var sp: UInt;

	/**
		The end address of `this` memory, i.e. the capacity of `stack` (which should be always the same).
	**/
	final capacity: UInt;

	/**
		The stack data. Also used for storing local variables.
	**/
	var stack: ByteStackData;

	public extern inline function new(stackCapacity: UInt) {
		this.capacity = stackCapacity;
	}

	public extern inline function reset(thread: Thread): Void {
		this.stack = thread.stack;
		this.sp = thread.stackPointer;
	}

	public extern inline function pushInt(v: Int32): Void
		sp = stack.pushI32(sp, v);

	public extern inline function pushFloat(v: Float): Void
		sp = stack.pushF64(sp, v);

	public extern inline function pushVec(x: Float, y: Float): Void {
		sp = stack.pushF64(sp, x);
		sp = stack.pushF64(sp, y);
	}

	public extern inline function popInt(): Int32 {
		final ret = stack.popI32(sp);
		sp = ret.size;
		return ret.value;
	}

	public extern inline function popFloat(): Float {
		final ret = stack.popF64(sp);
		sp = ret.size;
		return ret.value;
	}

	public extern inline function peekInt(): Int32
		return stack.peekI32(sp);

	public extern inline function peekFloat(): Float
		return stack.peekF64(sp);

	public extern inline function peekFloatSkipped(bytesToSkip: Int): Float
		return stack.peekF64(sp - bytesToSkip);

	public extern inline function peekVecSkipped(bytesToSkip: Int)
		return stack.peekVec2D64(sp - bytesToSkip);

	public extern inline function dropInt(): Void
		sp = stack.drop(sp, Bit32);

	public extern inline function dropFloat(): Void
		sp = stack.drop(sp, Bit64);

	public extern inline function dropVec(): Void
		sp = stack.drop2D(sp, Bit64);

	public extern inline function decrement(): Void
		stack.decrement32(sp);

	public extern inline function getLocalInt(address: Int): Int
		return stack.bytesData.getI32(capacity - address - LEN32);

	public extern inline function getLocalFloat(address: Int): Float
		return stack.bytesData.getF64(capacity - address - LEN64);

	public extern inline function setLocalInt(address: Int, value: Int): Void {
		stack.bytesData.setI32(capacity - address - LEN32, value);
	}

	public extern inline function setLocalFloat(address: Int, value: Float): Void {
		stack.bytesData.setF64(capacity - address - LEN64, value);
	}

	public extern inline function addLocalInt(address: Int, value: Int): Void {
		final pos = capacity - address - LEN32;
		stack.bytesData.setI32(pos, stack.bytesData.getI32(pos) + value);
	}

	public extern inline function addLocalFloat(address: Int, value: Float): Void {
		final pos = capacity - address - LEN64;
		stack.bytesData.setF64(pos, stack.bytesData.getF64(pos) + value);
	}
}
