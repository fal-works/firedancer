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
			optimized = tryOptimizeVar(code) || optimized;
			optimized = tryOptimizeWait(code) || optimized;
			if (!optimized) break;

			code.removeAll(inst -> inst == None);

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
		var curInst: Instruction;
		var gotoNext: Bool;

		inline function replaceInst(index: UInt, newInst: Instruction): Void {
			code[index] = newInst;
			if (index == i) {
				curInst = newInst;
				gotoNext = false;
			}
			optimizedAny = true;
		}

		while (i < code.length) {
			curInst = code[i];
			gotoNext = true;

			switch curInst {
			case Load(input):
				switch input {
				case Int(operand):
					switch operand {
					case Reg: replaceInst(i, None);
					case RegBuf: if (justSyncedIntReg) replaceInst(i, None);
					default:
					}
				case Float(operand):
					switch operand {
					case Reg: replaceInst(i, None);
					case RegBuf: if (justSyncedFloatReg) replaceInst(i, None);
					default:
					}
				default:
				}

			case Save(input):
				switch input {
				case Int(operand):
					switch operand {
					case Reg: if (justSyncedIntReg) replaceInst(i, None);
					case RegBuf: replaceInst(i, None);
					default:
					}
				case Float(operand):
					switch operand {
					case Reg: if (justSyncedFloatReg) replaceInst(i, None);
					case RegBuf: replaceInst(i, None);
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
						replaceInst(i, optimizedInst.unwrap());
						result = true;
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
						replaceInst(i, optimizedInst.unwrap());
						result = true;
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
						replaceInst(i, optimizedInst.unwrap());
						result = true;
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
			if (folded.isSome()) replaceInst(i, folded.unwrap());

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
					if (curIntReg.isEliminatable(i))
						replaceInst(curIntReg.loadedIndex.unwrap(), None);
					switch curInst {
					case Load(loaded):
						curIntReg = { loadedIndex: i, operand: loaded };
						justSyncedIntReg = loaded.isRegBuf();
					case Pop(_):
						curIntReg = { loadedIndex: i, eliminatable: false };
						justSyncedIntReg = false;
					default:
						curIntReg = { loadedIndex: i };
						justSyncedIntReg = false;
					}
				case Float:
					if (curFloatReg.isEliminatable(i))
						replaceInst(curFloatReg.loadedIndex.unwrap(), None);
					switch curInst {
					case Load(loaded):
						curFloatReg = { loadedIndex: i, operand: loaded };
						justSyncedFloatReg = loaded.isRegBuf();
					case Pop(_):
						curFloatReg = { loadedIndex: i, eliminatable: false };
						justSyncedIntReg = false;
					default:
						curFloatReg = { loadedIndex: i };
						justSyncedFloatReg = false;
					}
				case Vec:
					if (curVecReg.isEliminatable(i))
						replaceInst(curVecReg.loadedIndex.unwrap(), None);
					switch curInst {
					case Load(loaded):
						curVecReg = { loadedIndex: i, operand: loaded };
					case Pop(_):
						curIntReg = { loadedIndex: i, eliminatable: false };
					default:
						curVecReg = { loadedIndex: i };
					}
				}
			}
			final writeRegBufType = curInst.tryGetWriteRegBufType();
			if (writeRegBufType.isSome()) {
				switch writeRegBufType.unwrap() {
				case Int:
					if (curIntRegBuf.isEliminatable(i))
						replaceInst(curIntRegBuf.loadedIndex.unwrap(), None);
					switch curInst {
					case Save(saved):
						curIntRegBuf = { loadedIndex: i, operand: saved };
						justSyncedIntReg = saved.isReg();
					default:
						curIntRegBuf = { loadedIndex: i };
						justSyncedIntReg = false;
					}
				case Float:
					if (curFloatRegBuf.isEliminatable(i))
						replaceInst(curFloatRegBuf.loadedIndex.unwrap(), None);
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

			if (gotoNext) ++i;
		}

		if (curIntReg.isEliminatable(code.length))
			replaceInst(curIntReg.loadedIndex.unwrap(), None);
		if (curFloatReg.isEliminatable(code.length))
			replaceInst(curFloatReg.loadedIndex.unwrap(), None);
		if (curVecReg.isEliminatable(code.length))
			replaceInst(curVecReg.loadedIndex.unwrap(), None);
		if (curIntRegBuf.isEliminatable(code.length))
			replaceInst(curIntRegBuf.loadedIndex.unwrap(), None);
		if (curFloatRegBuf.isEliminatable(code.length))
			replaceInst(curFloatRegBuf.loadedIndex.unwrap(), None);

		return optimizedAny;
	}

	/**
		- Replaces unnecessary `Push`/`Pop` with `None`/`Load`.
		- Replaces instructions that peek from the stack if the last pushed value is an immediate.
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
				code[index] = newInst;
				if (i == index) curInst = newInst;
				optimizedAny = true;
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
			if (stackTop.isSome()) {
				final optimizedInst = curInst.tryReplaceStackWithImm(stackTop.unwrap().operand);
				if (optimizedInst.isSome()) replaceInst(i, optimizedInst.unwrap());
			}

			++i;
		}

		return optimizedAny;
	}

	/**
		- Replaces instructions that read any variable of which the last assigned value is an immediate.
		- Removes instructions that assign values to any variable which is never read.
	**/
	public static function tryOptimizeVar(code: AssemblyCode): Bool {
		if (code.length <= UInt.one) return false;

		var optimizedAny = false;

		final variables = new Map<UInt, VariableElement>();

		var i = UInt.zero;
		var curInst: Instruction;

		inline function replaceInst(index: UInt, newInst: Instruction): Void {
			code[index] = newInst;
			if (i == index) curInst = newInst;
			optimizedAny = true;
		}

		while (i < code.length) {
			curInst = code[i];

			final newInst = curInst.tryReplaceVariable(variables);
			if (newInst.isSome()) replaceInst(i, newInst.unwrap());

			// Not sure if we have to analyze the control flow wih `Goto` etc.

			final readVarAddress = curInst.tryGetReadVarAddress();
			if (readVarAddress.isSome()) {
				final variable = variables.get(readVarAddress.unwrap());
				if (variable != null) variable.maybeRead = true;
			}

			final writeVarAddress = curInst.tryGetWriteVarAddress();
			if (writeVarAddress.isSome()) {
				final variable = variables.get(writeVarAddress.unwrap());
				if (variable != null && !variable.maybeRead)
					replaceInst(variable.lastWrittenIndex, None);

				final variableElement: VariableElement = switch curInst {
					case Store(input, _): { lastWrittenIndex: i, operand: input };
					default: { lastWrittenIndex: i };
				}
				variables.set(writeVarAddress.unwrap(), variableElement);
			}

			++i;
		}

		for (variable in variables) {
			if (!variable.maybeRead) replaceInst(variable.lastWrittenIndex, None);
		}

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
			optimizedAny = true;
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
		return { loadedIndex: MaybeUInt.none, eliminatable: false };

	public final operand: Maybe<Operand> = Maybe.none();
	public final loadedIndex: MaybeUInt;
	public var maybeRead: Bool = false;

	final eliminatable: Bool;

	public function new(
		?operand: Operand,
		loadedIndex: MaybeUInt,
		eliminatable: Bool = true
	) {
		this.operand = Maybe.from(operand);
		this.loadedIndex = loadedIndex;
		this.eliminatable = eliminatable;
	}

	public function getMaybeImm(): Maybe<Operand> {
		final operand = this.operand;
		return if (operand.isSome()) switch operand.unwrap().getKind() {
		case Imm: operand;
		default: Maybe.none();
		} else Maybe.none();
	}

	public function isEliminatable(currentIndex: UInt): Bool {
		if (!this.eliminatable) return false;
		if (this.maybeRead) return false;

		final loadedIndex = this.loadedIndex;
		if (loadedIndex.isNone()) return false;
		if (loadedIndex.unwrap() == currentIndex) return false;

		return true;
	}
}

@:structInit
class StackElement {
	public final operand: Operand;
	public final pushedIndex: UInt;
	public var maybeRead: Bool = false;
}

@:structInit
class VariableElement {
	public final lastWrittenIndex: UInt;
	public var operand: Maybe<Operand>;
	public var maybeRead: Bool = false;

	public function new(lastWrittenIndex: UInt, ?operand: Operand, maybeRead = false) {
		this.lastWrittenIndex = lastWrittenIndex;
		this.operand = Maybe.from(operand);
		this.maybeRead = maybeRead;
	}

	public function tryGetIntImm(): Maybe<Int> {
		return if (this.operand.isSome()) {
			switch this.operand.unwrap() {
				case Int(operand):
					switch operand {
						case Imm(value): Maybe.from(value);
						default: Maybe.none();
					}
				default: Maybe.none();
			}
		} else Maybe.none();
	}

	public function tryGetFloatImm(): Maybe<Float> {
		return if (this.operand.isSome()) {
			switch this.operand.unwrap() {
				case Float(operand):
					switch operand {
						case Imm(value): Maybe.from(value);
						default: Maybe.none();
					}
				default: Maybe.none();
			}
		} else Maybe.none();
	}
}
