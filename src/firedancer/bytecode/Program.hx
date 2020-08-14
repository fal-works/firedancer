package firedancer.bytecode;

import banker.binary.Bytes;

/**
	A firedancer program that represents a bullet pattern.

	You can also use `Bytecode` directly if you store the entire `length` externally.
**/
@:notNull @:forward(length, toHex)
abstract Program(Bytes) from Bytes to Bytes {
	/**
		@return Null object for `Program`.
	**/
	public static function createEmpty()
		return Bytes.alloc(UInt.zero);

	/**
		Provides access to the bytecode.
	**/
	public var data(get, never): Bytecode;

	/**
		@return Hexadecimal representation of `this` with each byte separated.
	**/
	public inline function toString(): String
		return this.toHex();

	extern inline function get_data()
		return this.data;
}
