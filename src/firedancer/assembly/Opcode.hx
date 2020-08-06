package firedancer.assembly;

import firedancer.assembly.operation.*;

/**
	Value that specifies an operation to be performed.
	Consists of a "category part" and an "operation part".
**/
abstract Opcode(Int) {
	/**
		The size in bytes of a single `Opcode` value in `Bytecode`.
	**/
	public static extern inline final size = UInt.one;

	/**
		The number of bits of the operation part in an `Opcode` value.
	**/
	static extern inline final opBitCount = 6;

	static extern inline final b00000011 = 0x03;
	static extern inline final b00111111 = 0x3f;

	public static inline function from(category: OperationCategory, operation: Int): Opcode {
		return new Opcode(category.int() << opBitCount | operation);
	}

	/**
		Converts `GeneralOperation` to `Opcode`.
	**/
	public static inline function general(code: GeneralOperation): Opcode
		return from(General, code);

	/**
		Converts `ReadOperation` to `Opcode`.
	**/
	public static inline function read(code: ReadOperation): Opcode
		return from(Read, code);

	/**
		Converts `WriteOperation` to `Opcode`.
	**/
	public static inline function write(code: WriteOperation): Opcode
		return from(Write, code);

	/**
		The category part of this `Opcode`.
	**/
	public var category(get, never): OperationCategory;

	/**
		Value of the operation part of this `Opcode`.
	**/
	public var op(get, never): Int;

	/**
		Casts `this` to `Int`.
	**/
	public inline function int(): Int
		return this;

	extern inline function new(v: Int)
		this = v;

	extern inline function get_category() {
		#if debug
		final code = this >>> opBitCount;
		if (code & ~b00000011 != 0) throw 'Invalid opcode: $this';
		return cast code;
		#else
		return cast this >>> opBitCount;
		#end
	}

	extern inline function get_op()
		return this & b00111111;
}
