package firedancer.assembly;

import firedancer.types.Azimuth;
import firedancer.assembly.OperandKind;

class InstructionOptimizer {
	public static function tryReplaceRegWithImm(
		inst: Instruction,
		maybeImm: Operand
	): Maybe<Instruction> {
		final newInst: Null<Instruction> = switch inst {
		case Load(input):
			final newInput = input.tryReplaceRegWithImm(maybeImm);
			if (newInput.isSome()) Load(newInput.unwrap()) else null;

		case Store(input, address):
			final newInput = input.tryReplaceRegWithImm(maybeImm);
			if (newInput.isSome()) Store(newInput.unwrap(), address) else null;

		case Save(input):
			final newInput = input.tryReplaceRegWithImm(maybeImm);
			if (newInput.isSome()) Save(newInput.unwrap()) else null;

		case Push(input):
			final newInput = input.tryReplaceRegWithImm(maybeImm);
			if (newInput.isSome()) Push(newInput.unwrap()) else null;

		case Minus(input):
			final newInput = input.tryReplaceRegWithImm(maybeImm);
			if (newInput.isSome()) Minus(newInput.unwrap()) else null;

		case Add(nextOperands):
			final newNextOperands = nextOperands.tryReplaceRegWithImm(maybeImm);
			if (newNextOperands.isSome()) Add(newNextOperands.unwrap()) else null;

		case Sub(nextOperands):
			final newNextOperands = nextOperands.tryReplaceRegWithImm(maybeImm);
			if (newNextOperands.isSome()) Sub(newNextOperands.unwrap()) else null;

		case Mult(inputA, inputB):
			final newInputA = inputA.tryReplaceRegWithImm(maybeImm);
			if (newInputA.isSome()) {
				Instruction.Mult(newInputA.unwrap(), inputB);
			} else if (!inputA.isRegBuf()) {
				final newInputB = inputB.tryReplaceRegWithImm(maybeImm);
				if (newInputB.isSome()) Instruction.Mult(inputA, newInputB.unwrap());
				else null;
			} else null;

		case Div(inputA, inputB):
			final newInputA = inputA.tryReplaceRegWithImm(maybeImm);
			if (newInputA.isSome()) {
				Instruction.Div(newInputA.unwrap(), inputB);
			} else if (!inputA.isRegBuf()) {
				final newInputB = inputB.tryReplaceRegWithImm(maybeImm);
				if (newInputB.isSome()) Instruction.Div(inputA, newInputB.unwrap())
				else null;
			} else null;

		case Mod(inputA, inputB):
			final newInputA = inputA.tryReplaceRegWithImm(maybeImm);
			if (newInputA.isSome()) {
				Instruction.Mod(newInputA.unwrap(), inputB);
			} else {
				final newInputB = inputB.tryReplaceRegWithImm(maybeImm);
				if (newInputB.isSome()) Instruction.Mod(inputA, newInputB.unwrap())
				else null;
			}

		case Cast(type):
			switch type {
			case IntToFloat:
				switch maybeImm {
				case Int(operand):
					switch operand {
					case Imm(value):
						Load(Float(Imm((value : Float))));
					default: null;
					}
				default: null;
				}
			default: null;
			}

		case GetDiff(input, prop):
			final newInput = input.tryReplaceRegWithImm(maybeImm);
			if (newInput.isSome()) {
				GetDiff(newInput.unwrap(), prop);
			} else null;

		case Set(input, prop):
			final newInput = input.tryReplaceRegWithImm(maybeImm);
			if (newInput.isSome()) {
				Set(newInput.unwrap(), prop);
			} else null;

		case Increase(input, prop):
			final newInput = input.tryReplaceRegWithImm(maybeImm);
			if (newInput.isSome()) {
				Increase(newInput.unwrap(), prop);
			} else null;

		default: null;
		}

		return Maybe.from(newInst);
	}

	public static function tryReplaceRegBufWithImm(
		inst: Instruction,
		maybeImm: Operand
	): Maybe<Instruction> {
		final newInst: Null<Instruction> = switch inst {
		case Load(input):
			final newInput = input.tryReplaceRegBufWithImm(maybeImm);
			if (newInput.isSome()) Load(newInput.unwrap()) else null;

		case Add(nextOperands):
			final newNextOperands = nextOperands.tryReplaceRegBufWithImm(maybeImm);
			if (newNextOperands.isSome()) Add(newNextOperands.unwrap()) else null;

		case Sub(nextOperands):
			final newNextOperands = nextOperands.tryReplaceRegBufWithImm(maybeImm);
			if (newNextOperands.isSome()) Sub(newNextOperands.unwrap()) else null;

		case Mult(inputA, inputB):
			final newInputA = inputA.tryReplaceRegBufWithImm(maybeImm);
			if (newInputA.isSome()) {
				Instruction.Mult(newInputA.unwrap(), inputB);
			} else if (!inputA.isRegBuf()) {
				final newInputB = inputB.tryReplaceRegBufWithImm(maybeImm);
				if (newInputB.isSome()) Instruction.Mult(inputA, newInputB.unwrap());
				else null;
			} else null;

		case Div(inputA, inputB):
			final newInputA = inputA.tryReplaceRegBufWithImm(maybeImm);
			if (newInputA.isSome()) {
				Instruction.Div(newInputA.unwrap(), inputB);
			} else if (!inputA.isRegBuf()) {
				final newInputB = inputB.tryReplaceRegBufWithImm(maybeImm);
				if (newInputB.isSome()) Instruction.Div(inputA, newInputB.unwrap())
				else null;
			} else null;

		case Mod(inputA, inputB):
			final newInputA = inputA.tryReplaceRegBufWithImm(maybeImm);
			if (newInputA.isSome()) {
				Instruction.Mod(newInputA.unwrap(), inputB);
			} else {
				final newInputB = inputB.tryReplaceRegBufWithImm(maybeImm);
				if (newInputB.isSome()) Instruction.Mod(inputA, newInputB.unwrap())
				else null;
			}

		default: null;
		}

		return Maybe.from(newInst);
	}

	public static function tryReplaceRegBufAndRegWithImm(
		inst: Instruction,
		maybeImmA: Operand,
		maybeImmB: Operand
	): Maybe<Instruction> {
		final newInst: Null<Instruction> = switch inst {
		case Add(nextOperands):
			switch nextOperands {
			case Int(a, b):
				if (a.isRegBuf() && b.isReg()) {
					final immA = maybeImmA.tryGetIntImm();
					final immB = maybeImmB.tryGetIntImm();
					if (immA.isSome() && immB.isSome()) {
						Load(Int(Imm(immA.unwrap() + immB.unwrap())));
					} else null;
				} else null;
			case Float(a, b):
				if (a.isRegBuf() && b.isReg()) {
					final immA = maybeImmA.tryGetFloatImm();
					final immB = maybeImmB.tryGetFloatImm();
					if (immA.isSome() && immB.isSome()) {
						Load(Float(Imm(immA.unwrap() + immB.unwrap())));
					} else null;
				} else null;
			default: null;
			}

		case Sub(nextOperands):
			switch nextOperands {
			case Int(a, b):
				if (a.isRegBuf() && b.isReg()) {
					final immA = maybeImmA.tryGetIntImm();
					final immB = maybeImmB.tryGetIntImm();
					if (immA.isSome() && immB.isSome()) {
						Load(Int(Imm(immA.unwrap() - immB.unwrap())));
					} else null;
				} else null;
			case Float(a, b):
				if (a.isRegBuf() && b.isReg()) {
					final immA = maybeImmA.tryGetFloatImm();
					final immB = maybeImmB.tryGetFloatImm();
					if (immA.isSome() && immB.isSome()) {
						Load(Float(Imm(immA.unwrap() - immB.unwrap())));
					} else null;
				} else null;
			default: null;
			}

		case Mult(inputA, inputB):
			switch inputA {
			case Int(operandA):
				if (operandA.isRegBuf()) {
					switch inputB {
					case Int(operandB):
						if (operandB.isReg()) {
							final immA = maybeImmA.tryGetIntImm();
							final immB = maybeImmB.tryGetIntImm();
							if (immA.isSome() && immB.isSome()) {
								Load(Int(Imm(immA.unwrap() * immB.unwrap())));
							} else null;
						} else null;
					default: null;
					}
				} else null;
			case Float(operandA):
				if (operandA.isRegBuf()) {
					switch inputB {
					case Float(operandB):
						if (operandB.isReg()) {
							final immA = maybeImmA.tryGetFloatImm();
							final immB = maybeImmB.tryGetFloatImm();
							if (immA.isSome() && immB.isSome()) {
								Load(Float(Imm(immA.unwrap() * immB.unwrap())));
							} else null;
						} else null;
					default: null;
					}
				} else null;
			case Vec(operandA):
				if (operandA.isReg()) {
					switch inputB {
					case Float(operandB):
						if (operandB.isReg()) {
							final immA = maybeImmA.tryGetVecImm();
							final immB = maybeImmB.tryGetFloatImm();
							if (immA.isSome() && immB.isSome()) {
								final vecA = immA.unwrap();
								final b = immB.unwrap();
								Load(Vec(Imm(vecA.x * b, vecA.y * b)));
							} else null;
						} else null;
					default: null;
					}
				} else null;
			default: null;
			}

		case Div(inputA, inputB):
			switch inputA {
			case Int(operandA):
				if (operandA.isRegBuf()) {
					switch inputB {
					case Int(operandB):
						if (operandB.isReg()) {
							final immA = maybeImmA.tryGetIntImm();
							final immB = maybeImmB.tryGetIntImm();
							if (immA.isSome() && immB.isSome()) {
								Load(Int(Imm(Ints.divide(immA.unwrap(), immB.unwrap()))));
							} else null;
						} else null;
					default: null;
					}
				} else null;
			case Float(operandA):
				if (operandA.isRegBuf()) {
					switch inputB {
					case Float(operandB):
						if (operandB.isReg()) {
							final immA = maybeImmA.tryGetFloatImm();
							final immB = maybeImmB.tryGetFloatImm();
							if (immA.isSome() && immB.isSome()) {
								Load(Float(Imm(immA.unwrap() / immB.unwrap())));
							} else null;
						} else null;
					default: null;
					}
				} else null;
			case Vec(operandA):
				if (operandA.isReg()) {
					switch inputB {
					case Float(operandB):
						if (operandB.isReg()) {
							final immA = maybeImmA.tryGetVecImm();
							final immB = maybeImmB.tryGetFloatImm();
							if (immA.isSome() && immB.isSome()) {
								final vecA = immA.unwrap();
								final b = immB.unwrap();
								Load(Vec(Imm(vecA.x / b, vecA.y / b)));
							} else null;
						} else null;
					default: null;
					}
				} else null;
			default: null;
			}

		case Mod(inputA, inputB):
			switch inputA {
			case Int(operandA):
				if (operandA.isRegBuf()) {
					switch inputB {
					case Int(operandB):
						if (operandB.isReg()) {
							final immA = maybeImmA.tryGetIntImm();
							final immB = maybeImmB.tryGetIntImm();
							if (immA.isSome() && immB.isSome()) {
								Load(Int(Imm(immA.unwrap() % immB.unwrap())));
							} else null;
						} else null;
					default: null;
					}
				} else null;
			case Float(operandA):
				if (operandA.isRegBuf()) {
					switch inputB {
					case Float(operandB):
						if (operandB.isReg()) {
							final immA = maybeImmA.tryGetFloatImm();
							final immB = maybeImmB.tryGetFloatImm();
							if (immA.isSome() && immB.isSome()) {
								Load(Float(Imm(immA.unwrap() % immB.unwrap())));
							} else null;
						} else null;
					default: null;
					}
				} else null;
			default: null;
			}

		case Cast(type):
			switch type {
			case CartesianToVec:
				switch maybeImmA {
				case Float(operandA):
					switch operandA {
					case Imm(x):
						switch maybeImmB {
						case Float(operandB):
							switch operandB {
							case Imm(y):
								Load(Vec(Imm(x, y)));
							default: null;
							}
						default: null;
						}
					default: null;
					}
				default: null;
				}
			case PolarToVec:
				switch maybeImmA {
				case Float(operandA):
					switch operandA {
					case Imm(length):
						switch maybeImmB {
						case Float(operandB):
							switch operandB {
							case Imm(angle):
								final vec = Azimuth.fromRadians(angle).toVec2D(length);
								Load(Vec(Imm(vec.x, vec.y)));
							default: null;
							}
						default: null;
						}
					default: null;
					}
				default: null;
				}
			default: null;
			}

		default: null;
		}

		return Maybe.from(newInst);
	}

	public static function tryReplaceStackWithImm(
		inst: Instruction,
		maybeImm: Operand
	): Maybe<Instruction> {
		final newInst: Null<Instruction> = switch inst {
		case Peek(type, bytesToSkip):
			if (bytesToSkip != 0) null else {
				switch maybeImm {
				case Null: null;
				case Int(operand):
					if (type == Int) switch operand {
					case Imm(_): Load(maybeImm);
					default: null;
					} else null;
				case Float(operand):
					if (type == Float) switch operand {
					case Imm(_): Load(maybeImm);
					default: null;
					} else null;
				case Vec(operand):
					if (type == Vec) switch operand {
					case Imm(_): Load(maybeImm);
					default: null;
					} else null;
				}
			}

		case Increase(input, prop):
			switch input {
			case Vec(operand):
				switch operand {
				case Stack:
					switch maybeImm {
					case Vec(maybeImmOperand):
						switch maybeImmOperand {
						case Imm(_, _): Increase(maybeImm, prop);
						default: null;
						}
					default: null;
					}
				default: null;
				}
			case Float(operand):
				switch operand {
				case Stack:
					switch maybeImm {
					case Float(maybeImmOperand):
						switch maybeImmOperand {
						case Imm(_): Increase(maybeImm, prop);
						default: null;
						}
					default: null;
					}
				default: null;
				}
			default: null;
			}

		default: null;
		}

		return Maybe.from(newInst);
	}

	public static function tryFoldConstants(inst: Instruction): Maybe<Instruction> {
		inline function loadZero(type: ValueType): Instruction {
			return Load(switch type {
			case Int: Int(Imm(0));
			case Float: Float(Imm(0.0));
			case Vec: Vec(Imm(0.0, 0.0));
			});
		}

		final newInst: Null<Instruction> = switch inst {
		case Minus(input):
			switch input {
			case Int(operand):
				switch operand {
				case Imm(value): Load(Int(Imm(-value)));
				default: null;
				}
			case Float(operand):
				switch operand {
				case Imm(value): Load(Float(Imm(-value)));
				default: null;
				}
			case Vec(operand):
				switch operand {
				case Imm(x, y): Load(Vec(Imm(-x, -y)));
				default: null;
				}
			default: null;
			}

		case Add(nextOperands):
			switch nextOperands {
			case Int(a, b):
				switch a {
				case Imm(aVal):
					switch b {
					case Imm(bVal): Load(Int(Imm(aVal + bVal)));
					default: if (aVal == 0) Load(Int(b)) else null;
					}
				default:
					switch b {
					case Imm(bVal): if (bVal == 0) Load(Int(a)) else null;
					default: null;
					}
				};
			case Float(a, b):
				switch a {
				case Imm(aVal):
					switch b {
					case Imm(bVal): Load(Float(Imm(aVal + bVal)));
					default: if (aVal == 0.0) Load(Float(b)) else null;
					}
				default:
					switch b {
					case Imm(bVal): if (bVal == 0.0) Load(Float(a)) else null;
					default: null;
					}
				};
			case Vec(a, b):
				switch a {
				case Imm(ax, ay):
					switch b {
					case Imm(bx, by): Load(Vec(Imm(ax + bx, ay + by)));
					default: if (ax == 0.0 && ay == 0.0) Load(Vec(b)) else null;
					}
				default:
					switch b {
					case Imm(bx, by):
						if (bx == 0.0 && by == 0.0) Load(Vec(a)) else null;
					default: null;
					}
				};
			}

		case Sub(nextOperands):
			switch nextOperands {
			case Int(a, b):
				switch a {
				case Imm(aVal):
					switch b {
					case Imm(bVal): Load(Int(Imm(aVal - bVal)));
					default: if (aVal == 0) Minus(Int(b)) else null;
					}
				default:
					switch b {
					case Imm(bVal): if (bVal == 0) Load(Int(a)) else null;
					default: null;
					}
				};
			case Float(a, b):
				switch a {
				case Imm(aVal):
					switch b {
					case Imm(bVal): Load(Float(Imm(aVal - bVal)));
					default: if (aVal == 0.0) Minus(Float(b)) else null;
					}
				default:
					switch b {
					case Imm(bVal): if (bVal == 0) Load(Float(a)) else null;
					default: null;
					}
				};
			case Vec(a, b):
				switch a {
				case Imm(ax, ay):
					switch b {
					case Imm(bx, by): Load(Vec(Imm(ax - bx, ay - by)));
					default: if (ax == 0.0 && ay == 0.0) Minus(Vec(b)) else null;
					}
				default:
					switch b {
					case Imm(bx, by):
						if (bx == 0.0 && by == 0.0) Load(Vec(a)) else null;
					default: null;
					}
				};
			}

		case Mult(inputA, inputB):
			switch inputA {
			case Int(operandA):
				switch operandA {
				case Imm(aVal):
					switch inputB {
					case Int(operandB):
						switch operandB {
						case Imm(bVal): Load(Int(Imm(aVal * bVal)));
						default:
							if (aVal == 0) {
								loadZero(Int);
							} else if (aVal == 1) {
								Load(Int(operandB));
							} else null;
						}
					default: null;
					}
				default:
					switch inputB {
					case Int(operandB):
						switch operandB {
						case Imm(bVal):
							if (bVal == 0) {
								loadZero(Int);
							} else if (bVal == 1) {
								Load(Int(operandA));
							} else null;
						default: null;
						}
					default: null;
					}
				}
			case Float(operandA):
				switch operandA {
				case Imm(aVal):
					switch inputB {
					case Float(operandB):
						switch operandB {
						case Imm(bVal): Load(Float(Imm(aVal * bVal)));
						default:
							if (aVal == 0.0) {
								loadZero(Float);
							} else if (aVal == 1.0) {
								Load(Float(operandB));
							} else null;
						}
					default: null;
					}
				default:
					switch inputB {
					case Float(operandB):
						switch operandB {
						case Imm(bVal):
							if (bVal == 0.0) {
								loadZero(Float);
							} else if (bVal == 1.0) {
								Load(Float(operandA));
							} else null;
						default: null;
						}
					default: null;
					}
				}
			case Vec(operandA):
				switch operandA {
				case Imm(ax, ay):
					switch inputB {
					case Float(operandB):
						switch operandB {
						case Imm(bVal): Load(Vec(Imm(ax * bVal, ay * bVal)));
						default: if (ax == 0.0 && ay == 0.0) loadZero(Vec) else null;
						}
					default: null;
					}
				default:
					switch inputB {
					case Float(operandB):
						switch operandB {
						case Imm(bVal):
							if (bVal == 0.0) {
								loadZero(Float);
							} else if (bVal == 1.0) {
								Load(Vec(operandA));
							} else null;
						default: null;
						}
					default: null;
					}
				}
			default: null;
			}

		case Div(inputA, inputB):
			switch inputA {
			case Int(operandA):
				switch operandA {
				case Imm(aVal):
					switch inputB {
					case Int(operandB):
						switch operandB {
						case Imm(bVal): Load(Int(Imm(Ints.divide(aVal, bVal))));
						default: if (aVal == 0) loadZero(Int) else null;
						}
					default: null;
					}
				default:
					switch inputB {
					case Int(operandB):
						switch operandB {
						case Imm(bVal): if (bVal == 1) Load(Int(operandA)) else null;
						default: null;
						}
					default: null;
					}
				}
			case Float(operandA):
				switch operandA {
				case Imm(aVal):
					switch inputB {
					case Float(operandB):
						switch operandB {
						case Imm(bVal): Load(Float(Imm(aVal / bVal)));
						default: if (aVal == 0.0) loadZero(Float) else null;
						}
					default: null;
					}
				default:
					switch inputB {
					case Float(operandB):
						switch operandB {
						case Imm(bVal): if (bVal == 1.0) Load(Float(operandA)) else null;
						default: null;
						}
					default: null;
					}
				}
			case Vec(operandA):
				switch operandA {
				case Imm(ax, ay):
					switch inputB {
					case Float(operandB):
						switch operandB {
						case Imm(bVal): Load(Vec(Imm(ax / bVal, ay / bVal)));
						default: if (ax == 0.0 && ay == 0.0) loadZero(Vec) else null;
						}
					default: null;
					}
				default:
					switch inputB {
					case Float(operandB):
						switch operandB {
						case Imm(bVal): if (bVal == 1.0) Load(Vec(operandA)) else null;
						default: null;
						}
					default: null;
					}
				}
			default: null;
			}

		case Mod(inputA, inputB):
			switch inputA {
			case Int(operandA):
				switch operandA {
				case Imm(aVal):
					switch inputB {
					case Int(operandB):
						switch operandB {
						case Imm(bVal): Load(Int(Imm(aVal % bVal)));
						default: if (aVal == 0) loadZero(Int) else null;
						}
					default: null;
					}
				default: null;
				}
			case Float(operandA):
				switch operandA {
				case Imm(aVal):
					switch inputB {
					case Float(operandB):
						switch operandB {
						case Imm(bVal): Load(Float(Imm(aVal % bVal)));
						default: if (aVal == 0.0) loadZero(Float) else null;
						}
					default: null;
					}
				default: null;
				}
			default: null;
			}

		case Increase(input, _):
			if (input.isZero()) None else null;

		default: null;
		}
		return Maybe.from(newInst);
	}

	/**
		@param maybeImm Operand that is currently assigned to `Reg` or `RegBuf`.
		@param regOrRegBuf The kind of the operand to be replaced with `maybeImm` if it is an immediate.
	**/
	public static function tryReplaceUnnecessaryCalculation(
		inst: Instruction,
		maybeImm: Operand,
		regOrRegBuf: OperandKind
	): Maybe<Instruction> {
		inline function loadZero(type: ValueType): Instruction {
			return Load(switch type {
			case Int: Int(Imm(0));
			case Float: Float(Imm(0.0));
			case Vec: Vec(Imm(0.0, 0.0));
			});
		}

		final maybeImmType = maybeImm.getType();

		final newInst: Null<Instruction> = switch inst {
		case Minus(input):
			inline function tryMinusImm(): Null<Instruction> {
				return switch maybeImm {
				case Int(operand):
					switch operand {
					case Imm(value): Load(Int(Imm(-value)));
					default: null;
					}
				case Float(operand):
					switch operand {
					case Imm(value): Load(Float(Imm(-value)));
					default: null;
					}
				case Vec(operand):
					switch operand {
					case Imm(x, y): Load(Vec(Imm(-x, -y)));
					default: null;
					}
				default: null;
				}
			}
			switch regOrRegBuf {
			case Reg: if (input.isReg()) tryMinusImm() else null;
			case RegBuf: if (input.isRegBuf()) tryMinusImm() else null;
			default: null;
			}

		case Add(nextOperands):
			switch nextOperands {
			case Int(a, b):
				if (maybeImmType == Int && maybeImm.isZero()) {
					switch regOrRegBuf {
					case Reg:
						if (a.isReg()) Load(Int(b)) else if (b.isReg()) Load(Int(a)) else null;
					case RegBuf:
						if (a.isRegBuf()) Load(Int(b)) else if (b.isRegBuf()) Load(Int(a)) else null;
					default: null;
					};
				} else {
					null;
				};
			case Float(a, b):
				if (maybeImmType == Float && maybeImm.isZero()) {
					switch regOrRegBuf {
					case Reg:
						if (a.isReg()) Load(Float(b)) else if (b.isReg()) Load(Float(a)) else null;
					case RegBuf:
						if (a.isRegBuf()) Load(Float(b)) else if (b.isRegBuf()) Load(Float(a)) else
							null;
					default: null;
					};
				} else {
					null;
				};
			case Vec(a, b):
				if (maybeImmType == Vec && maybeImm.isZero()) {
					switch regOrRegBuf {
					case Reg:
						if (a.isReg()) Load(Vec(b)) else if (b.isReg()) Load(Vec(a)) else null;
					case RegBuf: null;
					default: null;
					}
				} else {
					null;
				}
			}

		case Sub(nextOperands):
			switch nextOperands {
			case Int(a, b):
				if (maybeImmType == Int && maybeImm.isZero()) {
					switch regOrRegBuf {
					case Reg:
						if (a.isReg()) Minus(Int(b)) else if (b.isReg()) Load(Int(a)) else null;
					case RegBuf:
						if (a.isRegBuf()) Minus(Int(b)) else if (b.isRegBuf()) Load(Int(a)) else null;
					default: null;
					}
				} else {
					null;
				}
			case Float(a, b):
				if (maybeImmType == Float && maybeImm.isZero()) {
					switch regOrRegBuf {
					case Reg:
						if (a.isReg()) Minus(Float(b)) else if (b.isReg()) Load(Float(a)) else null;
					case RegBuf:
						if (a.isRegBuf()) Minus(Float(b)) else if (b.isRegBuf()) Load(Float(a)) else
							null;
					default: null;
					}
				} else {
					null;
				}
			case Vec(a, b):
				if (maybeImmType == Vec && maybeImm.isZero()) {
					switch regOrRegBuf {
					case Reg:
						if (a.isReg()) Minus(Vec(b)) else if (b.isReg()) Load(Vec(a)) else null;
					default: null;
					}
				} else {
					null;
				}
			}

		case Mult(inputA, inputB):
			final outputType = inputA.getType();
			if (maybeImm.isZero()) {
				switch regOrRegBuf {
				case Reg:
					if (inputA.tryGetRegType() == maybeImmType
						|| (inputA.isRegBuf() && inputB.tryGetRegType() == maybeImmType))
						loadZero(outputType) else null;
				case RegBuf:
					if (inputA.tryGetRegBufType() == maybeImmType
						|| (inputA.isReg() && inputB.tryGetRegBufType() == maybeImmType))
						loadZero(outputType) else null;
				default: null;
				}
			} else if (maybeImm.isOne()) {
				switch regOrRegBuf {
				case Reg:
					if (inputB.tryGetRegType() == maybeImmType) {
						if (inputA.isReg()) None else Load(inputA);
					} else null;
				case RegBuf:
					if (inputB.tryGetRegBufType() == maybeImmType) {
						if (inputA.isReg()) None else Load(inputA);
					} else null;
				default: null;
				}
			} else {
				null;
			}

		case Div(inputA, inputB):
			final outputType = inputA.getType();
			if (maybeImm.isZero()) {
				switch regOrRegBuf {
				case Reg:
					if (inputA.tryGetRegType() == maybeImmType) loadZero(outputType) else null;
				case RegBuf:
					if (inputA.tryGetRegBufType() == maybeImmType) loadZero(outputType) else null;
				default: null;
				}
			} else if (maybeImm.isOne()) {
				switch regOrRegBuf {
				case Reg:
					if (inputB.tryGetRegType() == maybeImmType) {
						if (inputA.isReg()) None else Load(inputA);
					} else null;
				case RegBuf:
					if (inputB.tryGetRegBufType() == maybeImmType) {
						if (inputA.isReg()) None else Load(inputA);
					} else null;
				default: null;
				}
			} else {
				null;
			}

		case Mod(inputA, inputB):
			final outputType = inputA.getType();
			if (maybeImm.isZero()) {
				switch regOrRegBuf {
				case Reg:
					if (inputA.tryGetRegType() == maybeImmType) loadZero(outputType) else null;
				case RegBuf:
					if (inputA.tryGetRegBufType() == maybeImmType) loadZero(outputType) else null;
				default: null;
				}
			} else {
				null;
			}

		case Increase(input, _):
			if (maybeImm.isZero()) switch regOrRegBuf {
			case Reg:
				if (input.tryGetRegType() == maybeImmType) None else null;
			case RegBuf:
				if (input.tryGetRegBufType() == maybeImmType) None else null;
			default: null;
			} else {
				null;
			}

		default: null;
		}
		return Maybe.from(newInst);
	}

	/**
		If `inst` reads a variable and its content is an immediate (according to `variables`),
		returns a new `Instruction` with the input replaced with that immediate.
	**/
	public static function tryReplaceVariable(
		inst: Instruction,
		variables: Optimizer.Variables
	): Maybe<Instruction> {
		final newInst: Null<Instruction> = switch inst {
		case Load(input):
			final newInput = input.tryReplaceVarWithImm(variables);
			if (newInput.isSome()) Load(newInput.unwrap()) else null;

		case Store(input, address):
			final newInput = input.tryReplaceVarWithImm(variables);
			if (newInput.isSome()) Store(newInput.unwrap(), address) else null;

		case Save(input):
			final newInput = input.tryReplaceVarWithImm(variables);
			if (newInput.isSome()) Save(newInput.unwrap()) else null;

		case Push(input):
			final newInput = input.tryReplaceVarWithImm(variables);
			if (newInput.isSome()) Push(newInput.unwrap()) else null;

		case Minus(input):
			final newInput = input.tryReplaceVarWithImm(variables);
			if (newInput.isSome()) Minus(newInput.unwrap()) else null;

		case Add(nextOperands):
			switch nextOperands {
			case Int(a, b):
				switch a {
				case Var(key):
					final variable = variables.get(key);
					final imm = variable.tryGetIntImm();
					if (imm.isSome()) Add(Int(Imm(imm.unwrap()), b)) else null;
				default: null;
				}
			case Float(a, b):
				switch a {
				case Var(key):
					final variable = variables.get(key);
					final imm = variable.tryGetFloatImm();
					if (imm.isSome()) Add(Float(Imm(imm.unwrap()), b)) else null;
				default: null;
				}
			default: null;
			}

		case Sub(nextOperands):
			switch nextOperands {
			case Int(a, b):
				switch a {
				case Var(key):
					final variable = variables.get(key);
					final imm = variable.tryGetIntImm();
					if (imm.isSome()) Sub(Int(Imm(imm.unwrap()), b)) else null;
				default: null;
				}
			case Float(a, b):
				switch a {
				case Var(key):
					final variable = variables.get(key);
					final imm = variable.tryGetFloatImm();
					if (imm.isSome()) Sub(Float(Imm(imm.unwrap()), b)) else null;
				default: null;
				}
			default: null;
			}

		case Mult(inputA, inputB):
			final newInputA = inputA.tryReplaceVarWithImm(variables);
			if (newInputA.isSome()) {
				Instruction.Mult(newInputA.unwrap(), inputB);
			} else null;

		case Div(inputA, inputB):
			final newInputA = inputA.tryReplaceVarWithImm(variables);
			if (newInputA.isSome()) {
				Instruction.Div(newInputA.unwrap(), inputB);
			} else null;

		case Mod(inputA, inputB):
			final newInputA = inputA.tryReplaceVarWithImm(variables);
			if (newInputA.isSome()) {
				Instruction.Mod(newInputA.unwrap(), inputB);
			} else null;

		case GetDiff(input, prop):
			final newInput = input.tryReplaceVarWithImm(variables);
			if (newInput.isSome()) {
				GetDiff(newInput.unwrap(), prop);
			} else null;

		case Set(input, prop):
			final newInput = input.tryReplaceVarWithImm(variables);
			if (newInput.isSome()) {
				Set(newInput.unwrap(), prop);
			} else null;

		case Increase(input, prop):
			final newInput = input.tryReplaceVarWithImm(variables);
			if (newInput.isSome()) {
				Increase(newInput.unwrap(), prop);
			} else null;

		default: null;
		}
		return Maybe.from(newInst);
	}
}
