package firedancer.bytecode;

import haxe.Int32;
import banker.binary.ByteStackData;
import banker.vector.WritableVector as Vec;
import sneaker.print.Printer.print;
import firedancer.bytecode.internal.Constants.*;

/**
	(WIP)

	Virtual machine for executing `Bytecode`.
**/
class Vm {
	public static function run(
		bytecode: Bytecode,
		codePosVec: Vec<UInt>,
		stack: ByteStackData,
		stackSizeVec: Vec<UInt>,
		vecIndex: UInt
	): Void {
		var codePos = codePosVec[vecIndex];
		final endPos = bytecode.length;
		if (endPos <= codePos) return;

		var stackSize = stackSizeVec[vecIndex];

		final data = bytecode.data;
		var opcode: Opcode;
		var intValue: Int32;
		var floatValue: Float;

		inline function peekOp(): Opcode {
			opcode = Opcode.from(data.getI32(codePos));
			print("\n" + opcode.toString());
			return opcode;
		}

		inline function readOp(): Opcode {
			opcode = peekOp();
			codePos += LEN32;
			return opcode;
		}

		inline function readCodeI32(): Int32 {
			intValue = data.getI32(codePos);
			codePos += LEN32;
			print(' $intValue');
			return intValue;
		}

		inline function readCodeF64(): Float {
			floatValue = data.getF64(codePos);
			codePos += LEN64;
			print(' $floatValue');
			return floatValue;
		}

		inline function pushInt(v: Int32): Void {
			stackSize = stack.pushI32(stackSize, v);
		}

		inline function pushFloat(v: Float): Void {
			stackSize = stack.pushF64(stackSize, v);
		}

		inline function popInt(): Int32 {
			final ret = stack.popI32(stackSize);
			stackSize = ret.size;
			print('\n  POP INT ... $intValue');
			return ret.value;
		}

		inline function popFloat(): Float {
			final ret = stack.popF64(stackSize);
			stackSize = ret.size;
			print('\n  POP FLOAT ... $floatValue');
			return ret.value;
		}

		inline function peekI32(): Int32 {
			intValue = stack.peekI32(stackSize);
			print('\n  PEEK INT ... $intValue');
			return intValue;
		}

		inline function peekF64(): Float {
			floatValue = stack.peekF64(stackSize);
			print('\n  PEEK FLOAT ... $floatValue');
			return floatValue;
		}

		inline function dropInt(): Void {
			print('\n  DROP INT');
			stack.drop(stackSize, Bit32);
		}

		inline function decrement(): Void {
			stack.decrement32(stackSize);
			print('\n  DECREMENT ... ${stack.peekI32(stackSize)}');
		}

		do {
			switch readOp() {
				case PushInt:
					pushInt(readCodeI32());
				case CountDown:
					if (0 != peekI32()) {
						decrement();
						codePos -= LEN32;
						break;
					} else {
						dropInt();
					}
				case Break:
					break;
				case Decrement:
					decrement();
				case SetVelocity:
					final vx = readCodeF64();
					final vy = readCodeF64();
					// vx[vecIndex] = vx;
					// vy[vecIndex] = vy;
				}
		} while (codePos < endPos);

		codePosVec[vecIndex] = codePos;
		stackSizeVec[vecIndex] = stackSize;
		print('\n\n');
	}
}
