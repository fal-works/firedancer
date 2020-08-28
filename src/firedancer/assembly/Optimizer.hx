package firedancer.assembly;

import firedancer.assembly.OperandKind;

class Optimizer {
	/**
		The maximum wait count that can be unrolled.
	**/
	static extern inline final waitUnrollThreshold = 32;

	public static function optimize(code: AssemblyCode): AssemblyCode {
		var cnt = 0;

		code = code.copy();

		while (true) {
			var optimized = false;
			optimized = tryOptimizeCalc(code) || optimized;
			optimized = tryOptimizeStack(code) || optimized;
			optimized = tryOptimizeWait(code) || optimized;
			if (!optimized) break;

			if (1024 < ++cnt) throw "Detected infinite loop in the optimization process.";
		}

		return code;
	}

	/**
		- Try constant folding and propagating.
		- Eliminate or pre-calculate unnecessary calculations (e.g. eliminate `+ 0`, replace `* 0` with loading `0`).
		- Eliminate instructions that load/save any values that are never read.
	**/
	public static function tryOptimizeCalc(code: AssemblyCode): Bool {
		if (code.length <= UInt.one) return false;

		var optimizedAny = false;

		var curIntReg = RegContent.createNull();
		var curFloatReg = RegContent.createNull();
		var curVecReg = RegContent.createNull();
		var curIntRegBuf = RegContent.createNull();
		var curFloatRegBuf = RegContent.createNull();
		var justSyncedIntReg = false;
		var justSyncedFloatReg = false;

		var i = UInt.zero;
		while (i < code.length) {
			var curInst = code[i];
			var optimizedCur = false;

			inline function replaceCurInst(newInst: Instruction): Void {
				curInst = code[i] = newInst;
			}

			switch curInst {
			case Load(input):
				switch input {
				case Int(operand):
					switch operand {
					case Reg: replaceCurInst(None);
					case RegBuf: if (justSyncedIntReg) replaceCurInst(None);
					default:
					}
				case Float(operand):
					switch operand {
					case Reg: replaceCurInst(None);
					case RegBuf: if (justSyncedFloatReg) replaceCurInst(None);
					default:
					}
				default:
				}

			case Save(input):
				switch input {
				case Int(operand):
					switch operand {
					case Reg: if (justSyncedIntReg) replaceCurInst(None);
					case RegBuf: replaceCurInst(None);
					default:
					}
				case Float(operand):
					switch operand {
					case Reg: if (justSyncedFloatReg) replaceCurInst(None);
					case RegBuf: replaceCurInst(None);
					default:
					}
				default:
				}

			default:
			}

			inline function tryPropagateConstant(
				mightBeImm: Maybe<Operand>,
				kindToBeReplaced: OperandKind
			): Bool {
				var result = false;
				if (mightBeImm.isSome()) {
					final maybeImm = mightBeImm.unwrap();
					final optimizedInst = switch kindToBeReplaced {
					case Reg: curInst.tryReplaceRegWithImm(maybeImm);
					case RegBuf: curInst.tryReplaceRegBufWithImm(maybeImm);
					case Stack: curInst.tryReplaceStackWithImm(maybeImm);
					default: Maybe.none();
					}
					if (optimizedInst.isSome()) {
						replaceCurInst(optimizedInst.unwrap());
						result = optimizedCur = true;
					}
				}
				return result;
			}

			inline function tryPropagateConstantBinop(
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
						replaceCurInst(optimizedInst.unwrap());
						result = optimizedCur = true;
					}
				}
				return result;
			}

			inline function tryPropagateConstantAll(): Bool {
				return if (tryPropagateConstant(curIntReg.getMaybeImm(), Reg)) {
					true;
				} else if (tryPropagateConstant(curFloatReg.getMaybeImm(), Reg)) {
					true;
				} else if (tryPropagateConstant(curVecReg.getMaybeImm(), Reg)) {
					true;
				} else if (tryPropagateConstant(curIntRegBuf.getMaybeImm(), RegBuf)) {
					true;
				} else if (tryPropagateConstant(curFloatRegBuf.getMaybeImm(), RegBuf)) {
					true;
				} else if (tryPropagateConstantBinop(
					curIntRegBuf.getMaybeImm(),
					curIntReg.getMaybeImm()
				)) {
					true;
				} else if (tryPropagateConstantBinop(
					curFloatRegBuf.getMaybeImm(),
					curFloatReg.getMaybeImm()
				)) {
					true;
				} else {
					false;
				}
			}

			inline function tryReplaceUnnecessaryCalc(
				mightBeImm: Maybe<Operand>,
				regOrRegBuf: OperandKind
			): Bool {
				var result = false;
				if (mightBeImm.isSome()) {
					final maybeImm = mightBeImm.unwrap();
					final optimizedInst = curInst.tryReplaceUnnecessaryCalculation(
						maybeImm,
						regOrRegBuf
					);
					if (optimizedInst.isSome()) {
						replaceCurInst(optimizedInst.unwrap());
						result = optimizedCur = true;
					}
				}
				return result;
			}

			inline function tryReplaceUnnecessaryCalcAll(): Bool {
				return if (tryReplaceUnnecessaryCalc(curIntReg.getMaybeImm(), Reg)) {
					true;
				} else if (tryReplaceUnnecessaryCalc(curFloatReg.getMaybeImm(), Reg)) {
					true;
				} else if (tryReplaceUnnecessaryCalc(curVecReg.getMaybeImm(), Reg)) {
					true;
				} else if (tryReplaceUnnecessaryCalc(
					curIntRegBuf.getMaybeImm(),
					RegBuf
				)) {
					true;
				} else if (tryReplaceUnnecessaryCalc(
					curFloatRegBuf.getMaybeImm(),
					RegBuf
				)) {
					true;
				} else {
					false;
				}
			}

			if (!tryPropagateConstantAll()) tryReplaceUnnecessaryCalcAll();

			final folded = curInst.tryFoldConstants();
			if (folded.isSome()) {
				replaceCurInst(folded.unwrap());
				optimizedCur = true;
			}

			// update current registers
			if (curInst.readsReg(Int)) curIntReg.maybeRead = true;
			if (curInst.readsReg(Float)) curFloatReg.maybeRead = true;
			if (curInst.readsReg(Vec)) curVecReg.maybeRead = true;
			if (curInst.readsRegBuf(Int)) curIntRegBuf.maybeRead = true;
			if (curInst.readsRegBuf(Float)) curFloatRegBuf.maybeRead = true;
			final writeRegType = curInst.tryGetWriteRegType();
			if (writeRegType.isSome()) {
				switch writeRegType.unwrap() {
				case Int:
					curIntReg.tryEliminateFrom(code, i);
					switch curInst {
					case Load(loaded):
						curIntReg = { loadedIndex: i, operand: loaded };
						justSyncedIntReg = loaded.isRegBuf();
					default:
						curIntReg = { loadedIndex: i };
						justSyncedIntReg = false;
					}
				case Float:
					curFloatReg.tryEliminateFrom(code, i);
					switch curInst {
					case Load(loaded):
						curFloatReg = { loadedIndex: i, operand: loaded };
						justSyncedFloatReg = loaded.isRegBuf();
					default:
						curFloatReg = { loadedIndex: i };
						justSyncedFloatReg = false;
					}
				case Vec:
					curVecReg.tryEliminateFrom(code, i);
					switch curInst {
					case Load(loaded):
						curVecReg = { loadedIndex: i, operand: loaded };
					default:
						curVecReg = { loadedIndex: i };
					}
				}
			}
			final writeRegBufType = curInst.tryGetWriteRegBufType();
			if (writeRegBufType.isSome()) {
				switch writeRegBufType.unwrap() {
				case Int:
					curIntRegBuf.tryEliminateFrom(code, i);
					switch curInst {
					case Save(saved):
						curIntRegBuf = { loadedIndex: i, operand: saved };
						justSyncedIntReg = saved.isReg();
					default:
						curIntRegBuf = { loadedIndex: i };
						justSyncedIntReg = false;
					}
				case Float:
					curFloatRegBuf.tryEliminateFrom(code, i);
					switch curInst {
					case Save(saved):
						curFloatRegBuf = { loadedIndex: i, operand: saved };
						justSyncedFloatReg = saved.isReg();
					default:
						curFloatRegBuf = { loadedIndex: i };
						justSyncedFloatReg = false;
					}
				default:
				}
			}

			if (!optimizedCur) ++i;
			optimizedAny = optimizedAny || optimizedCur;
		}

		curIntReg.tryEliminateFrom(code, code.length);
		curFloatReg.tryEliminateFrom(code, code.length);
		curVecReg.tryEliminateFrom(code, code.length);
		curIntRegBuf.tryEliminateFrom(code, code.length);
		curFloatRegBuf.tryEliminateFrom(code, code.length);

		optimizedAny = code.removeAll(inst -> inst == None) || optimizedAny;

		return optimizedAny;
	}

	/**
		- Replaces unnecessary `Push`/`Pop` with `None`/`Load`.
		- Replaces instructions that peeks from the stack if the last pushed value is an immediate.
	**/
	public static function tryOptimizeStack(code: AssemblyCode): Bool {
		if (code.length <= UInt.one) return false;

		var optimizedAny = false;

		final curStacked: Array<StackElement> = [];

		inline function peeksStack() {
			final stackTop = curStacked.getLastSafe();
			if (stackTop.isSome()) stackTop.unwrap().maybeRead = true;
		}

		var i = UInt.zero;
		while (i < code.length) {
			var curInst = code[i];

			inline function replaceInst(index: UInt, newInst: Instruction): Void {
				code[i] = newInst;
				if (i == index) curInst = newInst;
			}

			switch curInst {
			case Push(input):
				curStacked.push({ operand: input, pushedIndex: i });
			case Pop(_):
				final stackTop = curStacked.pop().unwrap();
				if (!stackTop.maybeRead) {
					// replace if the pushed value is never read before `Pop` ...
					if (stackTop.operand.getKind() == Imm || stackTop.pushedIndex == i - 1) {
						// ... and is either an immediate or pushed just before the current `Pop` (which means that the value is not changed).
						replaceInst(i, Load(stackTop.operand)); // Pop => Load
						replaceInst(stackTop.pushedIndex, None); // Push => None
						optimizedAny = true;
					}
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
					case Stack: curStacked.push({ operand: output, pushedIndex: i });
					default:
					}
				default:
				}
			case AwaitThread:
				curStacked.pop();
			case Increase(input, _):
				if (input.isStack()) peeksStack();

			default:
			}

			final stackTop = curStacked.getLastSafe();
			if (stackTop.isSome())
				curInst.tryReplaceStackWithImm(stackTop.unwrap().operand);

			++i;
		}

		optimizedAny = code.removeAll(inst -> inst == None) || optimizedAny;

		return optimizedAny;
	}

	/**
		Unrolls the consecutive pair of `Push`/`CountDownBreak`.
	**/
	public static function tryOptimizeWait(code: AssemblyCode): Bool {
		var optimizedAny = false;

		var i = UInt.one;
		inline function replaceInst(index: UInt, newInst: Instruction): Void {
			code[index] = newInst;
		}
		while (i < code.length) {
			switch code[i] {
			case CountDownBreak:
				switch code[i - 1] {
				case Push(input):
					final constWaitCount = input.tryGetIntImm();
					if (constWaitCount.isSome()) {
						final waitCount = constWaitCount.unwrap();
						if (waitCount <= waitUnrollThreshold) {
							replaceInst(i - 1, None); // Push => None
							replaceInst(i, None); // CountDownBreak => None
							for (k in 0...waitCount) code.insert(i, Break);
							optimizedAny = true;
							i += waitCount;
						}
					}
				default:
				}
			default:
			}
			++i;
		}

		return optimizedAny;
	}
}

@:structInit
private class RegContent {
	public static function createNull(): RegContent
		return { loadedIndex: MaybeUInt.none };

	public final operand: Maybe<Operand> = Maybe.none();
	public final loadedIndex: MaybeUInt;
	public var maybeRead: Bool = false;

	public function new(?operand: Operand, loadedIndex: MaybeUInt) {
		this.operand = Maybe.from(operand);
		this.loadedIndex = loadedIndex;
	}

	public function getMaybeImm(): Maybe<Operand> {
		final operand = this.operand;
		return if (operand.isSome()) switch operand.unwrap().getKind() {
		case Imm: operand;
		default: Maybe.none();
		} else Maybe.none();
	}

	public function tryEliminateFrom(code: AssemblyCode, currentIndex: UInt): Bool {
		if (this.maybeRead) return false;

		final loadedIndex = this.loadedIndex;
		if (loadedIndex.isNone()) return false;
		if (loadedIndex.unwrap() == currentIndex) return false;

		code[loadedIndex.unwrap()] = None;
		return true;
	}
}

@:structInit
private class StackElement {
	public final operand: Operand;
	public final pushedIndex: UInt;
	public var maybeRead: Bool = false;
}
