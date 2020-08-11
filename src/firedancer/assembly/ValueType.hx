package firedancer.assembly;

import firedancer.bytecode.internal.Constants.*;

enum abstract ValueType(UInt) {
	final Int = LEN32;
	final Float = LEN64;
	final Vec = LEN64 + LEN64;

	/**
		The size in bytes of a single value of `this` type.
	**/
	public var size(get, never): UInt;

	extern inline function get_size()
		return this;
}
