package firedancer.bytecode;

import haxe.Int32;
import banker.binary.ByteStackData;
import banker.vector.WritableVector as Vec;
import sneaker.print.Printer.println;
import firedancer.assembly.Opcode;
import firedancer.bytecode.internal.Constants.*;

/**
	(WIP)

	Virtual machine for executing bytecode.
**/
class Vm {
	static extern inline final infiniteLoopCheckThreshold = 4096;

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
			println('${Opcode.from(opcode).toString()} (pos: $codePos)');
			codePos += LEN32;
			return opcode;
		}

		inline function readCodeI32(): Int32 {
			intValue = code.getI32(codePos);
			codePos += LEN32;
			println('  read_int ... $intValue');
			return intValue;
		}

		inline function readCodeF64(): Float {
			floatValue = code.getF64(codePos);
			codePos += LEN64;
			println('  read_float ... $floatValue');
			return floatValue;
		}

		inline function pushInt(v: Int32): Void {
			stackSize = stack.pushI32(stackSize, v);
			println('  push_int -> ${stack.toHex(stackSize, true)}');
		}

		inline function pushFloat(v: Float): Void {
			stackSize = stack.pushF64(stackSize, v);
			println('  push_float -> ${stack.toHex(stackSize, true)}');
		}

		inline function popInt(): Int32 {
			final ret = stack.popI32(stackSize);
			stackSize = ret.size;
			// print('\n  pop_int ... $intValue');
			return ret.value;
		}

		inline function popFloat(): Float {
			final ret = stack.popF64(stackSize);
			stackSize = ret.size;
			// print('\n  pop_float ... $floatValue');
			return ret.value;
		}

		inline function peekI32(): Int32 {
			intValue = stack.peekI32(stackSize);
			// print('\n  peek_int ... $intValue');
			return intValue;
		}

		inline function peekF64(): Float {
			floatValue = stack.peekF64(stackSize);
			// print('\n  peek_float ... $floatValue');
			return floatValue;
		}

		inline function dropInt(): Void {
			stackSize = stack.drop(stackSize, Bit32);
			println('  drop_int -> ${stack.toHex(stackSize, true)}');
		}

		inline function decrement(): Void {
			stack.decrement32(stackSize);
			println('  decrement ... ${stack.toHex(stackSize, true)}');
		}

		#if debug
		var cnt = 0;
		#end

		do {
			#if debug
			if (infiniteLoopCheckThreshold < ++cnt) throw "Detected infinite loop.";
			#end

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
				case Jump:
					final jumpLength = readCodeI32();
					codePos += jumpLength;
				case CountDownJump:
					if (0 != peekI32()) {
						decrement();
						codePos += LEN32; // skip the operand
						break;
					} else {
						dropInt();
						final jumpLength = readCodeI32();
						codePos += jumpLength;
					}
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

		println("");
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
			if (infiniteLoopCheckThreshold < frame)
				throw 'Exceeded $infiniteLoopCheckThreshold frames.';

			println('[frame $frame]');
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
