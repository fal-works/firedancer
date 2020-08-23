package firedancer.assembly;

import firedancer.assembly.OperandKind;

class Optimizer {
	public static function optimize(code: AssemblyCode): AssemblyCode {
		#if !firedancer_no_optimization
		var cnt = 0;

		while (true) {
			final optimized = tryOptimize(code);
			if (optimized.isSome()) code = optimized.unwrap();
			else break;

			if (1024 < ++cnt) throw "Detected infinite loop in the optimization process.";
		}
		#end

		return code;
	}

	/**
		- Try constant folding.
		- Replace `Pop` with `Load` if the stack top is an immediate and never read before `Pop`.
		- Eliminate or pre-calculate unnecessary calculations (e.g. eliminate `+ 0`, replace `* 0` with loading `0`)
	**/
	public static function tryOptimize(code: AssemblyCode): Maybe<AssemblyCode> {
		if (code.length <= UInt.one) return Maybe.none();

		code = code.copy();
		var optimizedAny = false;

		var curIntImmInReg: Maybe<Operand> = Maybe.none();
		var curFloatImmInReg: Maybe<Operand> = Maybe.none();
		var curVecImmInReg: Maybe<Operand> = Maybe.none();
		var curIntImmInRegBuf: Maybe<Operand> = Maybe.none();
		var curFloatImmInRegBuf: Maybe<Operand> = Maybe.none();
		final curStacked: Array<StackElement> = [];

		inline function peeksStack() {
			final stackTop = curStacked.getLastSafe();
			if (stackTop.isSome()) stackTop.unwrap().mayBeRead = true;
		}

		var i = UInt.zero;
		while (i < code.length) {
			var curInst = code[i];
			var optimizedCur = false;

			switch curInst {
			case Load(loaded):
				inline function findNextRegReader(startIndex: UInt): MaybeUInt {
					final nextWriter = code.indexOfFirstIn(
						inst -> inst.tryGetWriteRegType() == loaded.getType(),
						startIndex,
						code.length
					);
					final nextReader = code.indexOfFirstIn(
						inst -> inst.readsReg(loaded.getType()),
						startIndex,
						code.length
					);

					return if (nextReader.isNone()) {
						MaybeUInt.none;
					} else if (nextWriter.isNone() || nextReader.unwrap() <= nextWriter.unwrap()) {
						nextReader;
					} else {
						MaybeUInt.none;
					}
				}
				var nextRegReaderIndex = findNextRegReader(i + 1);
				if (nextRegReaderIndex.isNone()) {
					code[i] = None;
					optimizedCur = true;
				}

			case Save(saved):
				inline function findNextRegBufReader(startIndex: UInt): MaybeUInt {
					final nextWriter = code.indexOfFirstIn(
						inst -> inst.tryGetWriteRegBufType() == saved.getType(),
						startIndex,
						code.length
					);
					final nextReader = code.indexOfFirstIn(
						inst -> inst.readsRegBuf(saved.getType()),
						startIndex,
						code.length
					);

					return if (nextReader.isNone()) {
						MaybeUInt.none;
					} else if (nextWriter.isNone() || nextReader.unwrap() <= nextWriter.unwrap()) {
						nextReader;
					} else {
						MaybeUInt.none;
					}
				}
				var nextRegBufReaderIndex = findNextRegBufReader(i + 1);
				if (nextRegBufReaderIndex.isNone()) {
					code[i] = None;
					optimizedCur = true;
				}

			case Push(input):
				curStacked.push({ operand: input, pushInstIndex: i });
			case Pop(_):
				final stackTop = curStacked.pop().unwrap();
				if (!stackTop.mayBeRead && stackTop.operand.getKind() == Imm) {
					code[i] = Load(stackTop.operand);
					code[stackTop.pushInstIndex] = None;
					optimizedCur = true;
				}
			case Drop(_):
				curStacked.pop();
			case Peek(_, _):
				peeksStack();
			case CountDownBreak:
				curStacked.pop();
			case CountDownGotoLabel(_):
				curStacked.pop();
			case UseThread(_, output):
				switch output {
				case Int(operand):
					switch operand {
					case Stack: curStacked.push({ operand: output, pushInstIndex: i });
					default:
					}
				default:
				}
			case AwaitThread:
				curStacked.pop();
			case AddVector(_, _, input):
				if (input.isStack()) peeksStack();

			default:
			}

			// Sys.println('inst: ${code[i].toString()}');

			inline function tryFoldConstant(
				mightBeImm: Maybe<Operand>,
				regOrStack: RegOrStack
			): Bool {
				var result = false;
				if (mightBeImm.isSome()) {
					final maybeImm = mightBeImm.unwrap();
					final optimizedInst = switch regOrStack {
					case Reg: curInst.tryReplaceRegWithImm(maybeImm);
					case Stack: curInst.tryReplaceStackWithImm(maybeImm);
					}
					if (optimizedInst.isSome()) {
						code[i] = optimizedInst.unwrap();
						result = optimizedCur = true;
					}
				}
				return result;
			}

			inline function tryFoldConstantBinop(
				mightBeImmA: Maybe<Operand>,
				mightBeImmB: Maybe<Operand>
			): Bool {
				var result = false;
				if (mightBeImmA.isSome() && mightBeImmB.isSome()) {
					final maybeImmA = mightBeImmA.unwrap();
					final maybeImmB = mightBeImmB.unwrap();
					final optimizedInst = curInst.tryReplaceRegBufAndRegWithImm(
						maybeImmA,
						maybeImmB
					);
					if (optimizedInst.isSome()) {
						code[i] = optimizedInst.unwrap();
						result = optimizedCur = true;
					}
				}
				return result;
			}

			inline function tryFoldConstantAll(): Bool {
				return if (tryFoldConstant(curIntImmInReg, Reg)) {
					true;
				} else if (tryFoldConstant(curFloatImmInReg, Reg)) {
					true;
				} else if (tryFoldConstant(curVecImmInReg, Reg)) {
					true;
				} else if (tryFoldConstantBinop(curIntImmInRegBuf, curIntImmInReg)) {
					true;
				} else if (tryFoldConstantBinop(
					curFloatImmInRegBuf,
					curFloatImmInReg
				)) {
					true;
				} else {
					final stackTop = curStacked.getLastSafe();
					if (stackTop.isSome()) {
						tryFoldConstant(Maybe.from(stackTop.unwrap().operand), Stack);
					} else {
						false;
					}
				}
			}

			inline function tryEliminate(
				mightBeImm: Maybe<Operand>,
				regOrRegBuf: RegOrRegBuf
			): Bool {
				var result = false;
				if (mightBeImm.isSome()) {
					final maybeImm = mightBeImm.unwrap();
					final optimizedInst = curInst.tryReplaceUnnecessaryCalculation(maybeImm, regOrRegBuf);
					if (optimizedInst.isSome()) {
						code[i] = optimizedInst.unwrap();
						result = optimizedCur = true;
					}
				}
				return result;
			}

			inline function tryEliminateAll(): Bool {
				return if (tryEliminate(curIntImmInReg, Reg)) {
					true;
				} else if (tryEliminate(curFloatImmInReg, Reg)) {
					true;
				} else if (tryEliminate(curVecImmInReg, Reg)) {
					true;
				} else if (tryEliminate(curIntImmInRegBuf, RegBuf)) {
					true;
				} else if (tryEliminate(curFloatImmInRegBuf, RegBuf)) {
					true;
				} else {
					false;
				}
			}

			curInst = code[i];
			if (!tryFoldConstantAll()) tryEliminateAll();

			// update current registers
			curInst = code[i];
			final writeRegType = curInst.tryGetWriteRegType();
			if (writeRegType.isSome()) {
				switch curInst {
				case Load(loaded):
					switch loaded {
						case Int(operand):
							curIntImmInReg = Maybe.from(switch operand {
								case Imm(_): loaded;
								default: null;
							});
						case Float(operand):
							curFloatImmInReg = Maybe.from(switch operand {
								case Imm(_): loaded;
								default: null;
							});
						case Vec(operand):
							curVecImmInReg = Maybe.from(switch operand {
								case Imm(_): loaded;
								default: null;
							});
						default:
					}
				default:
					switch writeRegType.unwrap() {
					case Int: curIntImmInReg = Maybe.none();
					case Float: curFloatImmInReg = Maybe.none();
					case Vec: curVecImmInReg = Maybe.none();
					}
				}
			}
			final writeRegBufType = curInst.tryGetWriteRegBufType();
			if (writeRegBufType.isSome()) {
				switch curInst {
				case Save(saved):
					switch saved {
						case Int(operand):
							curIntImmInRegBuf = Maybe.from(switch operand {
								case Imm(_): saved;
								default: null;
							});
						case Float(operand):
							curFloatImmInRegBuf = Maybe.from(switch operand {
								case Imm(_): saved;
								default: null;
							});
						default:
					}
				default:
					switch writeRegBufType.unwrap() {
					case Int: curIntImmInRegBuf = Maybe.none();
					case Float: curFloatImmInRegBuf = Maybe.none();
					default:
					}
				}
			}

			++i;
			optimizedAny = optimizedAny || optimizedCur;
		}

		optimizedAny = code.removeAll(inst -> inst == None) || optimizedAny;

		return optimizedAny ? Maybe.from(code) : Maybe.none();
	}
}

private enum abstract RegOrStack(Int) {
	final Reg;
	final Stack;
}

@:structInit
private class StackElement {
	public final operand: Operand;
	public final pushInstIndex: UInt;
	public var mayBeRead: Bool = false;
}
