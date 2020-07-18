package firedancer.types;

import haxe.Int32;

/**
	Natural number, i.e. integer that is greater than zero.
**/
@:notNull
abstract NInt(Int) to Int32 to Int to UInt {
	@:from static extern inline function fromInt(v: Int): NInt {
		#if debug
		if (v <= 0) throw 'Invalid value: $v';
		#end
		return new NInt(v);
	}

	@:from static extern inline function fromInt32(v: Int32): NInt
		return fromInt(v);

	extern inline function new(v:Int)
		this = v;
}
