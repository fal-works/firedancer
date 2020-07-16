package firedancer.types;

/**
	Natural number, i.e. integer that is greater than zero.
**/
@:notNull
abstract NInt(Int) to Int to UInt {
	@:from static extern inline function from(v: Int): NInt {
		#if debug
		if (v <= 0) throw 'Invalid value: $v';
		#end
		return new NInt(v);
	}

	extern inline function new(v:Int)
		this = v;
}
