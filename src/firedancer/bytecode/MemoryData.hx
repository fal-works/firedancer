package firedancer.bytecode;

import banker.binary.ByteStackData;
import banker.binary.BytesData;
import firedancer.bytecode.internal.Constants.*;

/**
	Virtual memory data.
	Includes the stack and local variables area.
**/
@:notNull @:forward(toHex)
abstract MemoryData(ByteStackData) from ByteStackData {
	/**
		Creates a `MemoryData` instance with `capacity`.
	**/
	public static extern inline function alloc(capacity: UInt): MemoryData
		return ByteStackData.alloc(capacity);

	/**
		Provides access to the stack.
	**/
	public var stack(get, never): ByteStackData;

	/**
		Provides access to the local variables area.
	**/
	public var variables(get, never): LocalVariableData;

	extern inline function get_stack(): ByteStackData
		return this;

	extern inline function get_variables(): LocalVariableData
		return this.bytesData;
}

@:notNull
abstract LocalVariableData(BytesData) from BytesData {
	public extern inline function getInt(capacity: UInt, address: UInt): Int
		return this.getI32(capacity - address - LEN32);

	public extern inline function getFloat(capacity: UInt, address: UInt): Float
		return this.getF64(capacity - address - LEN64);

	public extern inline function setInt(
		capacity: UInt,
		address: UInt,
		value: Int
	): Void {
		this.setI32(capacity - address - LEN32, value);
	}

	public extern inline function setFloat(
		capacity: UInt,
		address: UInt,
		value: Float
	): Void {
		this.setF64(capacity - address - LEN64, value);
	}

	public extern inline function addInt(
		capacity: UInt,
		address: UInt,
		value: Int
	): Void {
		final pos = capacity - address - LEN32;
		this.setI32(pos, this.getI32(pos) + value);
	}

	public extern inline function addFloat(
		capacity: UInt,
		address: UInt,
		value: Float
	): Void {
		final pos = capacity - address - LEN64;
		this.setF64(pos, this.getF64(pos) + value);
	}
}
