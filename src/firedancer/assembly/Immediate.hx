package firedancer.assembly;

import haxe.Int32;
import firedancer.bytecode.internal.Constants.*;

/**
	Immediate value embedded in an `Instruction`.
**/
@:using(firedancer.assembly.Immediate.ImmediateExtension)
enum Immediate {
	/**
		A 32-bit integer value.
	**/
	Int(value: Int32);

	/**
		A 64-bit float value.
	**/
	Float(value: Float);

	/**
		A vector of two 64-bit float values.
	**/
	Vec(x: Float, y: Float);
}

class ImmediateExtension {
	public static inline function toString(_this: Immediate): String {
		inline function itoa(v: Int): String
			return Std.string(v);

		inline function ftoa(v: Float): String
			return if (Floats.toInt(v) == v) '$v.0' else Std.string(v);

		inline function vtoa(x: Float, y: Float): String
			return '(${ftoa(x)}, ${ftoa(y)})';

		return switch _this {
			case Int(value): itoa(value);
			case Float(value): ftoa(value);
			case Vec(x, y): vtoa(x, y);
		}
	}

	/**
		@return The bytecode length in bytes of `this`.
	**/
	public static function bytecodeLength(_this: Immediate): UInt {
		return switch _this {
			case Int(_): LEN32;
			case Float(_): LEN64;
			case Vec(_, _): LEN64 + LEN64;
		};
	}

	/**
		@return The corresponding `ValueType`.
	**/
	public static function getType(_this: Immediate): ValueType {
		return switch _this {
			case Int(_): Int;
			case Float(_): Float;
			case Vec(_, _): Vec;
		}
	}
}
