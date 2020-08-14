package firedancer.bytecode.types;

import haxe.Int32;
import firedancer.assembly.Immediate;

/**
	Argument value for firing opcodes.
**/
abstract FireArgument(Int32) from Int32 {

	/**
		10000000 00000000 00000000 00000000
	**/
	static extern inline final bindPositionBitMask: Int32 = 0x80000000;

	/**
		01111111 11111111 11111111 11111111
	**/
	static extern inline final programIdBitMask: Int32 = 0x7fffffff;

	/**
		Creates a `FireArgument` value from `programId` and `bindPosition`.
	**/
	public static function from(programId: UInt, bindPosition: Bool): FireArgument {
		if (programId & ~programIdBitMask != 0) throw 'Invalid program ID: $programId';

		return (bindPosition ? bindPositionBitMask : 0) | programId;
	}

	/**
		`true` if the position of the actor being fired should be bound
		to the position of the actor that fires it.
	**/
	public var bindPosition(get, never): Bool;

	/**
		The ID number of the `Program` to be run by the actor being fired.
	**/
	public var programId(get, never): UInt;

	@:to extern inline function toImmediate(): Immediate
		return Int(this);

	extern inline function get_bindPosition(): Bool {
		return (this & bindPositionBitMask) != 0;
	}

	@:access(sinker.UInt)
	extern inline function get_programId(): UInt {
		return new UInt(this & programIdBitMask);
	}
}
