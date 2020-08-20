package firedancer.assembly;

import firedancer.bytecode.internal.Constants.*;

enum abstract ValueType(Int) {
	final Int;
	final Float;
	final Vec;

	/**
		The size in bytes of a single value of `this` type.
	**/
	public var size(get, never): UInt;

	public function toString(): String {
		return switch (cast this: ValueType) {
			case Int: "int";
			case Float: "float";
			case Vec: "vec";
		}
	}

	extern inline function get_size(): UInt {
		return switch (cast this: ValueType) {
			case Int: LEN32;
			case Float: LEN64;
			case Vec: LEN64 + LEN64;
		}
	}
}
