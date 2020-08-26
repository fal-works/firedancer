package firedancer.assembly;

import haxe.Int32;
import firedancer.bytecode.Opcode;
import firedancer.bytecode.OpcodeExtension;

/**
	Data unit in firedancer `Program`.
**/
abstract Word(WordEnum) from WordEnum {
	@:from public static inline function fromOpcode(opcode: Opcode): Word
		return OpcodeWord(opcode);

	@:from public static inline function fromInt(value: Int): Word
		return IntWord(value);

	@:from public static inline function fromInt32(value: Int32): Word
		return IntWord(value);

	@:from public static inline function fromFloat(value: Float): Word
		return FloatWord(value);

	@:to public inline function toEnum(): WordEnum
		return this;

	@:to public function toString(): String {
		inline function ftoa(v: Float): String
			return if (Floats.toInt(v) == v) '$v.0' else Std.string(v);

		return switch this {
		case OpcodeWord(code): OpcodeExtension.toString(code);
		case IntWord(value): Std.string(value);
		case FloatWord(value): ftoa(value);
		}
	}
}

enum WordEnum {
	/**
		Operation code i.e. a value that specifies an operation to be performed.
	**/
	OpcodeWord(code: Opcode);

	/**
		Integer operand.
	**/
	IntWord(value: Int32);

	/**
		Float operand.
	**/
	FloatWord(value: Float);
}
