package firedancer.assembly;

import sneaker.string_buffer.StringBuffer;
import firedancer.bytecode.WordArray;
import firedancer.bytecode.internal.Constants.*;

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
		?operands: Array<ConstantOperand>
	): AssemblyStatement {
		return new AssemblyStatement(opcode, operands.orNew());
	}

	/**
		Implicitly converts `opcode` to `AssemblyStatement`.
	**/
	@:from static extern inline function fromOpcode(opcode: Opcode): AssemblyStatement {
		return new AssemblyStatement(opcode, []);
	}

	public extern inline function new(opcode: Opcode, operands: Array<ConstantOperand>) {
		#if debug
		// validate operands
		final operandTypes = opcode.toStatementType().operandTypes();
		if (operands.length != operandTypes.length)
			throw 'Invalid number of operands.\nHave: ${operands.length}\nWant: ${operandTypes.length}';
		for (i in 0...operands.length) {
			final operandType = operandTypes[i];
			final valid = switch operands[i] {
				case Int(_): operandType == Int;
				case Float(_): operandType == Float;
				case Vec(_, _): operandType == Vec;
			}
			if (!valid) throw "Invalid operands.";
		}
		#end

		this = new Data(opcode, operands);
	}
}

@:ripper_verified
private class Data implements ripper.Data {
	public final opcode: Opcode;
	public final operands: Array<ConstantOperand>;

	public function bytecodeLength(): UInt {
		var len = Opcode.size;

		for (i in 0...operands.length) {
			len += switch operands[i] {
				case Int(_): LEN32;
				case Float(_): LEN64;
				case Vec(_, _): LEN64 + LEN64;
			}
		}

		return len;
	}

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

		inline function ftoa(v: Float): String
			return if (Floats.toInt(v) == v) '$v.0' else Std.string(v);

		final operands = this.operands;
		for (i in 0...operands.length) {
			buf.addChar(' '.code);
			buf.add(switch operands[i] {
				case Int(value): Std.string(value);
				case Float(value): ftoa(value);
				case Vec(x, y): '(${ftoa(x)}, ${ftoa(y)})';
			});
		}

		return buf.toString();
	}
}
