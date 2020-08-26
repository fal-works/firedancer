package firedancer.bytecode;

import haxe.Int32;
import banker.binary.Bytes;
import firedancer.assembly.Opcode;
import firedancer.bytecode.Constants.*;
import firedancer.bytecode.Word.WordEnum;

private typedef Data = Array<Word>;

/**
	Array of `Word` values.
**/
@:notNull @:forward
abstract WordArray(Data) from Data to Data {
	@:from static inline function fromWords<T: Word>(words: std.Array<T>): WordArray
		return cast words;

	@:from static inline function fromWord(word: Word): WordArray
		return [word];

	@:from static inline function fromOpcode(opcode: Opcode): WordArray
		return [OpcodeWord(opcode)];

	/**
		@return The total length in bytes.
	**/
	public inline function getLengthInBytes(): UInt {
		var length = UInt.zero;

		for (i in 0...this.length) {
			final unit = this[i];
			length += switch unit.toEnum() {
			case OpcodeWord(_): Opcode.size;
			case IntWord(_): IntSize;
			case FloatWord(_): FloatSize;
			}
		}

		return length;
	}

	public function toString(): String
		return this.map(word -> word.toString()).join(" ");

	/**
		Compiles `this` words to `Program`.
	**/
	public inline function toProgram(): Program {
		final bytes = Bytes.alloc(getLengthInBytes());
		final data = bytes.data;
		var pos = UInt.zero;

		inline function addOpcode(code: Opcode): Void {
			data.setUI8(pos, code.int());
			pos += Opcode.size;
		}

		inline function addInt(v: Int32): Void {
			data.setI32(pos, v);
			pos += IntSize;
		}

		inline function addFloat(v: Float): Void {
			data.setF64(pos, v);
			pos += FloatSize;
		}

		for (i in 0...this.length) {
			final unit = this[i];
			switch unit.toEnum() {
			case OpcodeWord(byte): addOpcode(byte);
			case IntWord(v): addInt(v);
			case FloatWord(v): addFloat(v);
			}
		}

		return bytes;
	}
}
