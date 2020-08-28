package firedancer.assembly;

import firedancer.vm.Opcode;
import firedancer.vm.operation.GeneralOperation;
import firedancer.vm.operation.CalcOperation;
import firedancer.vm.operation.ReadOperation;
import firedancer.assembly.Word;

class InstructionAssembler {
	public static function toWordArray(
		inst: Instruction,
		labelAddressMap: Map<UInt, UInt>
	): WordArray {
		inline function op(opcode: Opcode): Word
			return OpcodeWord(opcode);

		return switch inst {
		case Break:
			op(Break);
		case CountDownBreak:
			op(CountDownBreak);
		case Label(_):
			throw 'Labels must be consumed before converting to WordArray.';
		case GotoLabel(labelId):
			final address = labelAddressMap.get(labelId);
			if (address == null) throw 'Unknown label ID: $labelId';
			[op(Goto), address];
		case CountDownGotoLabel(labelId):
			final address = labelAddressMap.get(labelId);
			if (address == null) throw 'Unknown label ID: $labelId';
			[op(CountDownGoto), address];
		case UseThread(programId, output):
			switch output {
			case Null: [op(UseThread), programId];
			case Int(operand):
				switch operand {
				case Stack: [op(UseThreadS), programId];
				default: throw unsupported();
				}
			default: throw unsupported();
			}
		case AwaitThread:
			op(AwaitThread);
		case End(endCode):
			[op(End), endCode];

			// ---- load values ------------------------------------------------

		case Load(input):
			switch input {
			case Int(operand):
				switch operand {
				case Imm(value): [op(LoadIntCR), value];
				case Reg: [];
				case RegBuf: op(LoadIntBR);
				case Var(address): [op(LoadIntVR), address];
				default: throw unsupported();
				}
			case Float(operand):
				switch operand {
				case Imm(value): [op(LoadFloatCR), value];
				case Reg: [];
				case RegBuf: op(LoadFloatBR);
				case Var(address): [op(LoadFloatVR), address];
				default: throw unsupported();
				}
			case Vec(operand):
				switch operand {
				case Imm(x, y): [
						op(LoadVecCR),
						x,
						y
					];
				case Reg: [];
				default: throw unsupported();
				}
			default: throw unsupported();
			}

		case Save(input):
			switch input {
			case Int(operand):
				switch operand {
				case Imm(value): [op(SaveIntC), value];
				case Reg: op(SaveIntR);
				default: throw unsupported();
				}
			case Float(operand):
				switch operand {
				case Imm(value): [op(SaveFloatC), value];
				case Reg: op(SaveFloatR);
				default: throw unsupported();
				}
			default: throw unsupported();
			}
		case Store(input, address):
			switch input {
			case Int(operand):
				switch operand {
				case Imm(value): [
						op(StoreIntCV),
						address,
						value
					];
				case Reg: [op(StoreIntRV), address];
				default: throw unsupported();
				}
			case Float(operand):
				switch operand {
				case Imm(value): [
						op(StoreFloatCV),
						address,
						value
					];
				case Reg: [op(StoreFloatRV), address];
				default: throw unsupported();
				}

			default: throw unsupported();
			}

			// ---- read/write stack ---------------------------------------------

		case Push(input):
			switch input {
			case Int(operand):
				switch operand {
				case Imm(value): [op(PushIntC), value];
				case Reg: op(PushIntR);
				default: throw unsupported();
				}
			case Float(operand):
				switch operand {
				case Imm(value): [op(PushFloatC), value];
				case Reg: op(PushFloatR);
				default: throw unsupported();
				}
			case Vec(operand):
				switch operand {
				case Reg: op(PushVecR);
				default: throw unsupported();
				}
			default: throw unsupported();
			}

		case Pop(type):
			op(switch type {
			case Int: PopInt;
			case Float: PopFloat;
			default: throw unsupported();
			});
		case Peek(type, bytesToSkip):
			[op(switch type {
			case Float: PeekFloat;
			case Vec: PeekVec;
			default: throw unsupported();
			}), bytesToSkip];
		case Drop(type):
			op(switch type {
			case Float: DropFloat;
			case Vec: DropVec;
			default: throw unsupported();
			});

			// ---- fire ---------------------------------------------------

		case Fire(fireType):
			switch fireType {
			case Simple: op(FireSimple);
			case Complex(fireArgument): [op(FireComplex), fireArgument.int()];
			case SimpleWithCode(fireCode): [op(FireSimpleWithCode), fireCode];
			case ComplexWithCode(fireArgument, fireCode): [
					op(FireComplexWithCode),
					fireArgument.int(),
					fireCode
				];
			}

			// ---- other ---------------------------------------------------

		case Event(eventType):
			switch eventType {
			case Global: op(GlobalEventR);
			case Local: op(LocalEventR);
			}

		case Debug(debugCode):
			[op(Debug), debugCode];

			// ---- calc values ---------------------------------------------

		case Add(input):
			switch input {
			case Int(a, b):
				switch a {
				case Imm(aVal):
					switch b {
					case Reg: [op(AddIntRCR), aVal]; // commutative
					default: throw unsupported();
					}
				case Reg:
					switch b {
					case Imm(bVal): [op(AddIntRCR), bVal];
					default: throw unsupported();
					}
				case RegBuf:
					switch b {
					case Reg: op(AddIntRRR);
					default: throw unsupported();
					}
				case Var(address):
					switch b {
					case Imm(bVal): [
							op(AddIntVCV),
							address,
							bVal
						];
					case Reg: [op(AddIntVRV), address];
					default: throw unsupported();
					}
				default: throw unsupported();
				}
			case Float(a, b):
				switch a {
				case Imm(aVal):
					switch b {
					case Reg: [op(AddFloatRCR), aVal]; // commutative
					default: throw unsupported();
					}
				case Reg:
					switch b {
					case Imm(bVal): [op(AddFloatRCR), bVal];
					default: throw unsupported();
					}
				case RegBuf:
					switch b {
					case Reg: op(AddFloatRRR);
					default: throw unsupported();
					}
				case Var(address):
					switch b {
					case Imm(bVal): [
							op(AddFloatVCV),
							address,
							bVal
						];
					case Reg: [op(AddFloatVRV), address];
					default: throw unsupported();
					}
				default: throw unsupported();
				}
			default: throw unsupported();
			}
		case Sub(input):
			switch input {
			case Int(a, b):
				switch a {
				case Imm(aVal):
					switch b {
					case Reg: [op(SubIntCRR), aVal];
					default: throw unsupported();
					}
				case Reg:
					switch b {
					case Imm(bVal): [op(SubIntRCR), bVal];
					default: throw unsupported();
					}
				case RegBuf:
					switch b {
					case Reg: op(SubIntRRR);
					default: throw unsupported();
					}
				default: throw unsupported();
				}
			case Float(a, b):
				switch a {
				case Imm(aVal):
					switch b {
					case Reg: [op(SubFloatCRR), aVal];
					default: throw unsupported();
					}
				case Reg:
					switch b {
					case Imm(bVal): [op(SubFloatRCR), bVal];
					default: throw unsupported();
					}
				case RegBuf:
					switch b {
					case Reg: op(SubFloatRRR);
					default: throw unsupported();
					}
				default: throw unsupported();
				}
			default: throw unsupported();
			}
		case Minus(input):
			switch input {
			case Int(operand):
				switch operand {
				case Reg: op(MinusIntRR);
				default: throw unsupported();
				}
			case Float(operand):
				switch operand {
				case Reg: op(MinusFloatRR);
				default: throw unsupported();
				}
			case Vec(operand):
				switch operand {
				case Reg: op(MinusVecRR);
				default: throw unsupported();
				}
			default: throw unsupported();
			}

		case Mult(inputA, inputB):
			switch inputA {
			case Int(operandA):
				switch operandA {
				case Imm(aVal):
					switch inputB {
					case Int(operandB):
						switch operandB {
						case Reg: [op(MultIntRCR), aVal]; // commutative
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				case Reg:
					switch inputB {
					case Int(operandB):
						switch operandB {
						case Imm(bVal): [op(MultIntRCR), bVal];
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				case RegBuf:
					switch inputB {
					case Int(operandB):
						switch operandB {
						case Reg: op(MultIntRRR);
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				default: throw unsupported();
				}
			case Float(operandA):
				switch operandA {
				case Imm(aVal):
					switch inputB {
					case Float(operandB):
						switch operandB {
						case Reg: [op(MultFloatRCR), aVal]; // commutative
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				case Reg:
					switch inputB {
					case Float(operandB):
						switch operandB {
						case Imm(bVal): [op(MultFloatRCR), bVal];
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				case RegBuf:
					switch inputB {
					case Float(operandB):
						switch operandB {
						case Reg: op(MultFloatRRR);
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				default: throw unsupported();
				}
			case Vec(operandA):
				switch operandA {
				case Reg:
					switch inputB {
					case Float(operandB):
						switch operandB {
						case Imm(bVal): [op(MultVecRCR), bVal];
						case Reg: op(MultVecRRR);
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				default: throw unsupported();
				}
			default: throw unsupported();
			}

		case Div(inputA, inputB):
			switch inputA {
			case Int(operandA):
				switch operandA {
				case Imm(aVal):
					switch inputB {
					case Int(operandB):
						switch operandB {
						case Reg: [op(DivIntCRR), aVal];
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				case Reg:
					switch inputB {
					case Int(operandB):
						switch operandB {
						case Imm(bVal): [op(DivIntRCR), bVal];
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				case RegBuf:
					switch inputB {
					case Int(operandB):
						switch operandB {
						case Reg: op(DivIntRRR);
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				default: throw unsupported();
				}
			case Float(operandA):
				switch operandA {
				case Imm(aVal):
					switch inputB {
					case Float(operandB):
						switch operandB {
						case Reg: [op(DivFloatCRR), aVal];
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				case Reg:
					switch inputB {
					case Float(operandB):
						switch operandB {
						case Imm(bVal): [op(DivFloatRCR), bVal];
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				case RegBuf:
					switch inputB {
					case Float(operandB):
						switch operandB {
						case Reg: op(DivFloatRRR);
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				default: throw unsupported();
				}
			case Vec(operandA):
				switch operandA {
				case Reg:
					switch inputB {
					case Float(operandB):
						switch operandB {
						case Reg: op(DivVecRRR);
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				default: throw unsupported();
				}
			default: throw unsupported();
			}

		case Mod(inputA, inputB):
			switch inputA {
			case Int(operandA):
				switch operandA {
				case Imm(aVal):
					switch inputB {
					case Int(operandB):
						switch operandB {
						case Reg: [op(ModIntCRR), aVal];
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				case Reg:
					switch inputB {
					case Int(operandB):
						switch operandB {
						case Imm(bVal): [op(ModIntRCR), bVal];
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				case RegBuf:
					switch inputB {
					case Int(operandB):
						switch operandB {
						case Reg: op(ModIntRRR);
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				default: throw unsupported();
				}
			case Float(operandA):
				switch operandA {
				case Imm(aVal):
					switch inputB {
					case Float(operandB):
						switch operandB {
						case Reg: [op(ModFloatCRR), aVal];
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				case Reg:
					switch inputB {
					case Float(operandB):
						switch operandB {
						case Imm(bVal): [op(ModFloatRCR), bVal];
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				case RegBuf:
					switch inputB {
					case Float(operandB):
						switch operandB {
						case Reg: op(ModFloatRRR);
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				default: throw unsupported();
				}
			default: throw unsupported();
			}

		case Cast(type):
			switch type {
			case IntToFloat: op(CastIntToFloatRR);
			case CartesianToVec: op(CastCartesianRR);
			case PolarToVec: op(CastPolarRR);
			}

		case RandomRatio:
			op(RandomRatioR);
		case Random(max):
			switch max {
			case Int(operand):
				switch operand {
				case Imm(value): [op(RandomIntCR), value];
				case Reg: op(RandomIntRR);
				default: throw unsupported();
				}
			case Float(operand):
				switch operand {
				case Imm(value): [op(RandomFloatCR), value];
				case Reg: op(RandomFloatRR);
				default: throw unsupported();
				}
			default: throw unsupported();
			}
		case RandomSigned(maxMagnitude):
			switch maxMagnitude {
			case Int(operand):
				switch operand {
				case Imm(value): [op(RandomIntSignedCR), value];
				case Reg: op(RandomIntSignedRR);
				default: throw unsupported();
				}
			case Float(operand):
				switch operand {
				case Imm(value): [op(RandomFloatSignedCR), value];
				case Reg: op(RandomFloatSignedRR);
				default: throw unsupported();
				}
			default: throw unsupported();
			}

		case Sin:
			op(SinRR);
		case Cos:
			op(CosRR);

		case Increment(address):
			[op(IncrementVV), address];
		case Decrement(address):
			[op(DecrementVV), address];

			// ---- read actor data

		case Get(prop):
			[op(prop.getReadOpcode())];

		case GetDiff(input, prop):
			switch input {
			case Vec(operand):
				if (prop.component != Vector) throw unsupported();
				switch operand {
				case Imm(x, y):
					[
						op(prop.getDiffOpcode(Imm)),
						x,
						y
					];
				case Reg: op(prop.getDiffOpcode(Reg));
				default: throw unsupported();
				}
			case Float(operand):
				switch operand {
				case Imm(value): [op(prop.getDiffOpcode(Imm)), value];
				case Reg: op(prop.getDiffOpcode(Reg));
				default: throw unsupported();
				}
			default: throw unsupported();
			}

		case GetTarget(prop):
			switch prop {
			case Position: op(LoadTargetPositionR);
			case X: op(LoadTargetXR);
			case Y: op(LoadTargetYR);
			case AngleFromShotPosition: op(LoadAngleToTargetR);
			}

			// ---- write actor data -----------------------------------------

		case Set(input, prop):
			switch input {
			case Vec(operand):
				if (prop.component != Vector) throw unsupported();
				switch operand {
				case Imm(x, y):
					[
						op(prop.getWriteOpcode(Set, Imm)),
						x,
						y
					];
				case Reg: op(prop.getWriteOpcode(Set, Reg));
				default: throw unsupported();
				}
			case Float(operand):
				switch operand {
				case Imm(value): [op(prop.getWriteOpcode(Set, Imm)), value];
				case Reg: op(prop.getWriteOpcode(Set, Reg));
				default: throw unsupported();
				}
			default: throw unsupported();
			}

		case Increase(input, prop):
			switch input {
			case Vec(operand):
				if (prop.component != Vector) throw unsupported();
				switch operand {
				case Imm(x, y):
					[
						op(prop.getWriteOpcode(Add, Imm)),
						x,
						y
					];
				case Reg: op(prop.getWriteOpcode(Add, Reg));
				case Stack: op(prop.getWriteOpcode(Add, Stack));
				default: throw unsupported();
				}
			case Float(operand):
				switch operand {
				case Imm(value): [op(prop.getWriteOpcode(Add, Imm)), value];
				case Reg: op(prop.getWriteOpcode(Add, Reg));
				case Stack: op(prop.getWriteOpcode(Add, Stack));
				default: throw unsupported();
				}
			default: throw unsupported();
			}

		case Comment(_) | None:
			op(NoOperation);
		}
	}

	static function unsupported(): String
		return "Unsupported operation.";
}
