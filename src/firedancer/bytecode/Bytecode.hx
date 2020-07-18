package firedancer.bytecode;

import banker.binary.Bytes;

/**
	Bytecode that represents a bullet pattern.
	You can also use `BytecodeData` directly if you store the entire `length` externally.
**/
@:notNull @:forward(length)
abstract Bytecode(Bytes) from Bytes to Bytes {
	public static final empty = Bytes.alloc(UInt.zero);

	/**
		Provides access to the bytecode.
	**/
	public var data(get, never): BytecodeData;

	extern inline function get_data()
		return this.data;
}
