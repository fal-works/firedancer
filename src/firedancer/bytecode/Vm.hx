package firedancer.bytecode;

import haxe.Int32;
import banker.binary.ByteStackData;
import banker.vector.WritableVector as Vec;
import sneaker.print.Printer.print;
import firedancer.assembly.Opcode;
import firedancer.bytecode.internal.Constants.*;

/**
	(WIP)

	Virtual machine for executing bytecode.
**/
class Vm {
	public static function run(
		code: BytecodeData,
		codeLength: UInt,
		codePosVec: Vec<UInt>,
		stack: ByteStackData,
		stackSizeVec: Vec<UInt>,
		xVec: Vec<Float>,
		yVec: Vec<Float>,
		vxVec: Vec<Float>,
		vyVec: Vec<Float>,
		vecIndex: UInt
	): Void {
		var codePos = codePosVec[vecIndex];
		if (codeLength <= codePos) return;

		var stackSize = stackSizeVec[vecIndex];

		var intValue: Int32;
		var floatValue: Float;

		inline function readOp(): Int32 {
			final opcode = code.getI32(codePos);
			print("\n" + Opcode.from(opcode).toString());
			codePos += LEN32;
			return opcode;
		}

		inline function readCodeI32(): Int32 {
			intValue = code.getI32(codePos);
			codePos += LEN32;
			print(' $intValue');
			return intValue;
		}

		inline function readCodeF64(): Float {
			floatValue = code.getF64(codePos);
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
				case SetPositionConst:
					final x = readCodeF64();
					final y = readCodeF64();
					xVec[vecIndex] = x;
					yVec[vecIndex] = y;
				case SetVelocityConst:
					final vx = readCodeF64();
					final vy = readCodeF64();
					vxVec[vecIndex] = vx;
					vyVec[vecIndex] = vy;
				case other:
					#if debug
					throw 'Unknown opcode: $other';
					#end
			}
		} while (codePos < codeLength);

		codePosVec[vecIndex] = codePos;
		stackSizeVec[vecIndex] = stackSize;
		print('\n\n');
	}

	public static function dryRun(bytecode: Bytecode): Void {
		final code = bytecode.data;
		final codeLength = bytecode.length;
		final codePosVec = Vec.fromArrayCopy([UInt.zero]);
		final stack = ByteStackData.alloc(256);
		final stackSizeVec = Vec.fromArrayCopy([UInt.zero]);
		final xVec = Vec.fromArrayCopy([0.0]);
		final yVec = Vec.fromArrayCopy([0.0]);
		final vxVec = Vec.fromArrayCopy([0.0]);
		final vyVec = Vec.fromArrayCopy([0.0]);
		final vecIndex = UInt.zero;
		var frame = UInt.zero;

		while (codePosVec[UInt.zero] < bytecode.length) {
			if (600 < frame) throw "Exceeded 600 frames."; // infinite loop check

			print('[frame $frame]\n');
			Vm.run(
				code,
				codeLength,
				codePosVec,
				stack,
				stackSizeVec,
				xVec,
				yVec,
				vxVec,
				vyVec,
				vecIndex
			);
			++frame;
		}
	}
}
