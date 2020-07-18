package firedancer.assembly;

import sneaker.string_buffer.StringBuffer;
import firedancer.bytecode.WordArray;

/**
	A single statement in bullet pattern code written in a virtual assembly language.
**/
@:notNull @:forward
abstract AssemblyStatement(Data) from Data {
	/**
		Creates a new `AssemblyStatement` instance.
	**/
	public static extern inline function create(
		opcode: Opcode,
		?operands: Array<Operand>
	): AssemblyStatement {
		return new Data(opcode, operands.orNew());
	}

	/**
		Implicitly converts `opcode` to `AssemblyStatement`.
	**/
	@:from static extern inline function fromOpcode(opcode: Opcode): AssemblyStatement {
		return new Data(opcode, []);
	}
}

private class Data implements ripper.Data {
	public final opcode: Opcode;
	public final operands: Array<Operand>;

	public function toWordArray(): WordArray {
		final opcode = this.opcode;
		final operands = this.operands;
		final words: WordArray = [Opcode(opcode)];

		for (i in 0...operands.length) switch operands[i] {
			case Int(value):
				words.push(Int(value));
			case Float(value):
				words.push(Float(value));
			case Vec(x, y):
				words.push(Float(x));
				words.push(Float(y));
		};

		return words;
	}

	public function toString(): String {
		final buf = new StringBuffer();
		buf.add(this.opcode.toString());

		final operands = this.operands;
		for (i in 0...operands.length) {
			buf.addChar(' '.code);
			buf.add(switch operands[i] {
				case Int(value): Std.string(value);
				case Float(value): Std.string(value);
				case Vec(x, y): '$x, $y';
			});
		}

		return buf.toString();
	}
}
