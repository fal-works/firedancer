package firedancer.bytecode;

import haxe.Int32;
import banker.binary.Bytes;
import firedancer.assembly.Opcode;
import firedancer.bytecode.internal.Constants.*;

private typedef Data = Array<Word>;

/**
	Array of `Word` values.
**/
@:notNull @:forward
abstract WordArray(Data) from Data to Data {
	/**
		@return The total length in bytes.
	**/
	public inline function getLengthInBytes(): UInt {
		var length = UInt.zero;

		for (i in 0...this.length) {
			final unit = this[i];
			length += switch unit {
				case Opcode(_): Opcode.size;
				case Int(_): LEN32;
				case Float(_): LEN64;
			}
		}

		return length;
	}

	/**
		Compiles `this` words to `Program`.
	**/
	public inline function toProgram(): Program {
		final bytes = Bytes.alloc(getLengthInBytes());
		final data = bytes.data;
		var pos = UInt.zero;

		inline function instruction(code: Opcode): Void {
			data.setUI8(pos, code.int());
			pos += Opcode.size;
		}

		inline function int32(v: Int32): Void {
			data.setI32(pos, v);
			pos += LEN32;
		}

		inline function float64(v: Float): Void {
			data.setF64(pos, v);
			pos += LEN64;
		}

		for (i in 0...this.length) {
			final unit = this[i];
			switch unit {
				case Opcode(byte): instruction(byte);
				case Int(v): int32(v);
				case Float(v): float64(v);
			}
		}

		return bytes;
	}
}
