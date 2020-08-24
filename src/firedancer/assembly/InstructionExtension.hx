package firedancer.assembly;

import firedancer.types.Azimuth;
import firedancer.bytecode.Word;
import firedancer.bytecode.WordArray;
import firedancer.bytecode.internal.Constants.*;
import firedancer.assembly.operation.GeneralOperation;
import firedancer.assembly.operation.CalcOperation;
import firedancer.assembly.operation.ReadOperation;
import firedancer.assembly.operation.WriteOperation;
import firedancer.assembly.types.ActorProperty;
import firedancer.assembly.OperandTools.*;
import firedancer.assembly.OperandKind;

class InstructionExtension {
	static function unsupported(): String
		return "Unsupported operation.";

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

		case FireSimple:
			op(FireSimple);
		case FireComplex(fireArgument):
			[op(FireComplex), fireArgument.int()];
		case FireSimpleWithCode(fireCode):
			[op(FireSimpleWithCode), fireCode];
		case FireComplexWithCode(fireArgument, fireCode):
			[
				op(FireComplexWithCode),
				fireArgument.int(),
				fireCode
			];

			// ---- other ---------------------------------------------------

		case GlobalEvent:
			op(GlobalEventR);
		case LocalEvent:
			op(LocalEventR);
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
					case Int(operandB):
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
					case Int(operandB):
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

		case CastIntToFloat:
			op(CastIntToFloatRR);
		case CastCartesian:
			op(CastCartesianRR);
		case CastPolar:
			op(CastPolarRR);

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

		case LoadTargetPosition:
			op(LoadTargetPositionR);
		case LoadTargetX:
			op(LoadTargetXR);
		case LoadTargetY:
			op(LoadTargetYR);
		case LoadBearingToTarget:
			op(LoadBearingToTargetR);

		case GetDiff(input, prop):
			switch input {
			case Vec(operand):
				if (prop.component != Vector) throw unsupported();
				switch operand {
				case Imm(x, y):
					final opcode:Opcode = switch prop.type {
					case Position: GetDiffPositionCR;
					case Velocity: GetDiffVelocityCR;
					case ShotPosition: GetDiffShotPositionCR;
					case ShotVelocity: GetDiffShotVelocityCR;
					};
					[
						op(opcode),
						x,
						y
					];
				case Reg:
					final opcode:Opcode = switch prop.type {
					case Position: GetDiffPositionRR;
					case Velocity: GetDiffVelocityRR;
					case ShotPosition: GetDiffShotPositionRR;
					case ShotVelocity: GetDiffShotVelocityRR;
					};
					op(opcode);
				default: throw unsupported();
				}
			case Float(operand):
				switch operand {
				case Imm(value):
					final opcode:Opcode = switch prop.component {
					case Vector: throw unsupported();
					case Length:
						switch prop.type {
						case Position: GetDiffDistanceCR;
						case Velocity: GetDiffSpeedCR;
						case ShotPosition: GetDiffShotDistanceCR;
						case ShotVelocity: GetDiffShotSpeedCR;
						}
					case Angle:
						switch prop.type {
						case Position: GetDiffBearingCR;
						case Velocity: GetDiffDirectionCR;
						case ShotPosition: GetDiffShotBearingCR;
						case ShotVelocity: GetDiffShotDirectionCR;
						}
					};
					[op(opcode), value];
				case Reg:
					final opcode:Opcode = switch prop.component {
					case Vector: throw unsupported();
					case Length:
						switch prop.type {
						case Position: GetDiffDistanceRR;
						case Velocity: GetDiffSpeedRR;
						case ShotPosition: GetDiffShotDistanceRR;
						case ShotVelocity: GetDiffShotSpeedRR;
						}
					case Angle:
						switch prop.type {
						case Position: GetDiffBearingRR;
						case Velocity: GetDiffDirectionRR;
						case ShotPosition: GetDiffShotBearingRR;
						case ShotVelocity: GetDiffShotDirectionRR;
						}
					};
					op(opcode);
				default: throw unsupported();
				}
			default: throw unsupported();
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

		case None:
			op(NoOperation);
		}
	}

	public static function toString(inst: Instruction): String {
		inline function itoa(v: Int): String
			return Std.string(v);

		inline function ftoa(v: Float): String
			return if (Floats.toInt(v) == v) '$v.0' else Std.string(v);

		inline function vtoa(x: Float, y: Float): String
			return '(${ftoa(x)}, ${ftoa(y)})';

		return switch inst {
		case Break:
			'break';
		case CountDownBreak:
			'countdown break';
		case Label(labelId):
			'label ${itoa(labelId)}';
		case GotoLabel(labelId):
			'goto label ${itoa(labelId)}';
		case CountDownGotoLabel(labelId):
			'countdown goto label ${itoa(labelId)}';
		case UseThread(programId, output):
			'use thread ${itoa(programId)} -> ${output.toString()}';
		case AwaitThread:
			'await thread';
		case End(endCode):
			'end ${itoa(endCode)}';

			// ---- load values ------------------------------------------------

		case Load(input):
			final output = DataRegisterSpecifier.get(input.getType());
			'load ${input.toString()} -> $output';
		case Save(input):
			final output = DataRegisterSpecifier.get(input.getType()).getBuffer();
			'save ${input.toString()} -> ${output.toString()}';
		case Store(input, address):
			'store ${input.toString()} -> ${varToString(address, input.getType())}';

			// ---- read/write stack ---------------------------------------------

		case Push(input):
			'push ${input.toString()} -> s';
		case Pop(type):
			final output = DataRegisterSpecifier.get(type).toString();
			'pop s -> $output';
		case Peek(type, bytesToSkip):
			final output = DataRegisterSpecifier.get(type).toString();
			'peek ${type.toString()} s, $bytesToSkip -> $output';
		case Drop(type):
			'drop ${type.toString()}';

			// ---- fire ---------------------------------------------------

		case FireSimple:
			'fire simple';
		case FireComplex(fireArgument):
			'fire complex ${itoa(fireArgument.int())}';
		case FireSimpleWithCode(fireCode):
			'fire simple with code ${itoa(fireCode)}';
		case FireComplexWithCode(fireArgument, fireCode):
			'fire complex with code ${itoa(fireArgument.int())} ${itoa(fireCode)}';

			// ---- other ---------------------------------------------------

		case GlobalEvent:
			'event global ri -> n';
		case LocalEvent:
			'event local ri -> n';
		case Debug(debugCode):
			'debug ${itoa(debugCode)} -> n';

			// ---- calc values ---------------------------------------------

		case Add(input):
			final outputStr = switch input {
			case Int(a, b):
				switch a {
				case Var(_): a.toString();
				default: DataRegisterSpecifier.Ri.toString();
				}
			case Float(a, b):
				switch a {
				case Var(_): a.toString();
				default: DataRegisterSpecifier.Rf.toString();
				}
			default: throw unsupported();
			};
			'add ${input.toString()} -> $outputStr';
		case Sub(input):
			final outputStr = switch input {
			case Int(a, b):
				switch a {
				case Var(_): a.toString();
				default: DataRegisterSpecifier.Ri.toString();
				}
			case Float(a, b):
				switch a {
				case Var(_): a.toString();
				default: DataRegisterSpecifier.Rf.toString();
				}
			default: throw unsupported();
			};
			'sub ${input.toString()} -> $outputStr';
		case Minus(reg):
			final inOutStr = reg.toString();
			'minus $inOutStr -> $inOutStr';
		case Mult(inputA, inputB):
			final outputStr = switch inputA {
			case Int(_): DataRegisterSpecifier.Ri.toString();
			case Float(_): DataRegisterSpecifier.Rf.toString();
			case Vec(_): DataRegisterSpecifier.Rvec.toString();
			default: throw unsupported();
			};
			'mult ${inputA.toString()}, ${inputB.toString()} -> $outputStr';
		case Div(inputA, inputB):
			final outputStr = switch inputA {
			case Int(_): DataRegisterSpecifier.Ri.toString();
			case Float(_): DataRegisterSpecifier.Rf.toString();
			case Vec(_): DataRegisterSpecifier.Rvec.toString();
			default: throw unsupported();
			};
			'div ${inputA.toString()}, ${inputB.toString()} -> $outputStr';
		case Mod(inputA, inputB):
			final outputStr = switch inputA {
			case Int(_): DataRegisterSpecifier.Ri.toString();
			case Float(_): DataRegisterSpecifier.Rf.toString();
			case Vec(_): DataRegisterSpecifier.Rvec.toString();
			default: throw unsupported();
			};
			'mod ${inputA.toString()}, ${inputB.toString()} -> $outputStr';

		case CastIntToFloat:
			'cast ri -> rf';
		case CastCartesian:
			'cast cartesian rfb, rf -> rvec';
		case CastPolar:
			'cast polar rfb, rf -> rvec';

		case RandomRatio:
			'random ratio n -> rf';
		case Random(max):
			'random ${max.toString()} -> rf';
		case RandomSigned(maxMagnitude):
			'random signed ${maxMagnitude.toString()} -> rf';

		case Sin:
			'sin rf -> rf';
		case Cos:
			'cos rf -> rf';

		case Increment(address):
			final inOutStr = varToString(address, Int);
			'increment $inOutStr -> $inOutStr';
		case Decrement(address):
			final inOutStr = varToString(address, Int);
			'decrement $inOutStr -> $inOutStr';

			// ---- read actor data

		case LoadTargetPosition:
			'load target position -> rvec';
		case LoadTargetX:
			'load target x -> rf';
		case LoadTargetY:
			'load target y -> rf';
		case LoadBearingToTarget:
			'load bearing to target -> rf';

		case GetDiff(input, prop):
			final outputStr = DataRegisterSpecifier.get(input.getType());
			'get diff ${input.toString()}, ${prop.toString()} -> $outputStr';

			// ---- write actor data -----------------------------------------

		case Set(input, prop):
			'set ${input.toString()} -> ${prop.toString()}';
		case Increase(input, prop):
			'increase ${input.toString()} -> ${prop.toString()}';

			// ----

		case None:
			"none";
		}
	}

	public static function bytecodeLength(inst: Instruction): UInt {
		return Opcode.size + switch inst {
			// ---- control flow -----------------------------------------------
		case Break: UInt.zero;
		case CountDownBreak: UInt.zero;
		case Label(labelId): throw "Label cannot be directly converted to bytecode.";
		case GotoLabel(labelId): LEN32;
		case CountDownGotoLabel(labelId): LEN32;
		case UseThread(programId, output): LEN32 + output.bytecodeLength();
		case AwaitThread: UInt.zero;
		case End(endCode): LEN32;

			// ---- load values ------------------------------------------------

		case Load(input): input.bytecodeLength();
		case Save(input): input.bytecodeLength();
		case Store(input, address): input.bytecodeLength() + LEN32;

			// ---- read/write stack ---------------------------------------------

		case Push(input): input.bytecodeLength();
		case Pop(_): UInt.zero;
		case Peek(_, bytesToSkip): LEN32;
		case Drop(_): UInt.zero;

			// ---- fire ---------------------------------------------------

		case FireSimple: UInt.zero;
		case FireComplex(fireArgument): LEN32;
		case FireSimpleWithCode(fireCode): LEN32;
		case FireComplexWithCode(fireArgument, fireCode): LEN32 + LEN32;

			// ---- other ---------------------------------------------------

		case GlobalEvent: UInt.zero;
		case LocalEvent: UInt.zero;
		case Debug(debugCode): LEN32;

			// ---- calc values ---------------------------------------------

		case Add(input): input.bytecodeLength();
		case Sub(input): input.bytecodeLength();
		case Minus(reg): UInt.zero;
		case Mult(inputA, inputB): inputB.bytecodeLength();
		case Div(inputA, inputB): inputA.bytecodeLength() + inputB.bytecodeLength();
		case Mod(inputA, inputB): inputA.bytecodeLength() + inputB.bytecodeLength();

		case CastIntToFloat: UInt.zero;
		case CastCartesian: UInt.zero;
		case CastPolar: UInt.zero;

		case RandomRatio: UInt.zero;
		case Random(max): max.bytecodeLength();
		case RandomSigned(maxMagnitude): maxMagnitude.bytecodeLength();

		case Sin: UInt.zero;
		case Cos: UInt.zero;

		case Increment(address): LEN32;
		case Decrement(address): LEN32;

			// ---- read actor data ------------------------------------------

		case LoadTargetPosition: UInt.zero;
		case LoadTargetX: UInt.zero;
		case LoadTargetY: UInt.zero;
		case LoadBearingToTarget: UInt.zero;

		case GetDiff(input, prop): input.bytecodeLength();

			// ---- write actor data -----------------------------------------

		case Set(input, prop): input.bytecodeLength();
		case Increase(input, prop): input.bytecodeLength();

			// ----

		case None: UInt.zero;
		}
	}

	/**
		@return `true` if `this` receives `Reg` with `regType` as input.
	**/
	public static function readsReg(inst: Instruction, regType: ValueType): Bool {
		return switch inst {
		case Load(input): input.tryGetRegType() == regType;
		case Save(input): input.tryGetRegType() == regType;
		case Store(input, _): input.tryGetRegType() == regType;
		case Push(input): input.tryGetRegType() == regType;

		case Add(input): input.tryGetRegType() == regType;
		case Sub(input): input.tryGetRegType() == regType;
		case Minus(input): input.tryGetRegType() == regType;
		case Mult(inputA, inputB): inputA.tryGetRegType() == regType || inputB.tryGetRegType() == regType;
		case Div(inputA, inputB): inputA.tryGetRegType() == regType || inputB.tryGetRegType() == regType;
		case Mod(inputA, inputB): inputA.tryGetRegType() == regType || inputB.tryGetRegType() == regType;

		case CastIntToFloat: regType == Int;
		case CastCartesian: regType == Float;
		case CastPolar: regType == Float;

		case Random(max): max.tryGetRegType() == regType;
		case RandomSigned(maxMagnitude): maxMagnitude.tryGetRegType() == regType;

		case Sin: regType == Float;
		case Cos: regType == Float;

		case GetDiff(input, prop): input.tryGetRegType() == regType;

		case Set(input, prop): input.tryGetRegType() == regType;
		case Increase(input, prop): input.tryGetRegType() == regType;

		default: false;
		}
	}

	/**
		@return `true` if `this` receives `RegBuf` with `regType` as input.
	**/
	public static function readsRegBuf(inst: Instruction, regType: ValueType): Bool {
		return switch inst {
		case Load(input): input.tryGetRegBufType() == regType;
		case Save(input): input.tryGetRegBufType() == regType;
		case Store(input, _): input.tryGetRegBufType() == regType;
		case Push(input): input.tryGetRegBufType() == regType;

		case Add(input): input.tryGetRegBufType() == regType;
		case Sub(input): input.tryGetRegBufType() == regType;
		case Minus(input): input.tryGetRegBufType() == regType;
		case Mult(inputA, inputB): inputA.tryGetRegBufType() == regType || inputB.tryGetRegBufType() == regType;
		case Div(inputA, inputB): inputA.tryGetRegBufType() == regType || inputB.tryGetRegBufType() == regType;
		case Mod(inputA, inputB): inputA.tryGetRegBufType() == regType || inputB.tryGetRegBufType() == regType;

		case CastCartesian: regType == Float;
		case CastPolar: regType == Float;

		case Random(max): max.tryGetRegBufType() == regType;
		case RandomSigned(maxMagnitude): maxMagnitude.tryGetRegBufType() == regType;

		case GetDiff(input, prop): input.tryGetRegBufType() == regType;

		case Set(input, prop): input.tryGetRegBufType() == regType;
		case Increase(input, prop): input.tryGetRegBufType() == regType;

		default: false;
		}
	}

	/**
		@return The output `ValueType` if the output of `this` is `Reg`.
	**/
	public static function tryGetWriteRegType(inst: Instruction): Maybe<ValueType> {
		return Maybe.from(switch inst {
		case Load(input): input.getType();
		case Pop(type): type;
		case Peek(type, _): type;

		case Add(input): input.tryGetRegType().nullable();
		case Sub(input): input.tryGetRegType().nullable();
		case Minus(input): input.tryGetRegType().nullable();
		case Mult(inputA, _):
			inputA.tryGetRegType().coalesce(inputA.tryGetRegBufType()).nullable();
		case Div(inputA, _):
			inputA.tryGetRegType().coalesce(inputA.tryGetRegBufType()).nullable();
		case Mod(inputA, _):
			inputA.tryGetRegType().coalesce(inputA.tryGetRegBufType()).nullable();

		case CastIntToFloat: ValueType.Float;
		case CastCartesian: ValueType.Vec;
		case CastPolar: ValueType.Vec;

		case RandomRatio: ValueType.Float;
		case Random(max): max.getType();
		case RandomSigned(maxMagnitude): maxMagnitude.getType();

		case Sin: ValueType.Float;
		case Cos: ValueType.Float;

		case LoadTargetPosition: ValueType.Vec;
		case LoadTargetX: ValueType.Float;
		case LoadTargetY: ValueType.Float;
		case LoadBearingToTarget: ValueType.Float;

		case GetDiff(input, _): input.getType();

		default: null;
		});
	}

	/**
		@return The output `ValueType` if the output of `this` is `RegBuf`.
	**/
	public static function tryGetWriteRegBufType(inst: Instruction): Maybe<ValueType> {
		return Maybe.from(switch inst {
		case Save(input): input.getType();
		default: null;
		});
	}

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

		case CastIntToFloat:
			switch maybeImm {
			case Int(operand):
				switch operand {
				case Imm(value):
					Load(Float(Imm((value : Float))));
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

		case CastCartesian:
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

		case CastPolar:
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
				if (maybeImm.isZero()) {
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
				if (maybeImm.isZero()) {
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
				if (maybeImm.isZero()) {
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
				if (maybeImm.isZero()) {
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
				if (maybeImm.isZero()) {
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
				if (maybeImm.isZero()) {
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
			final type = inputA.getType();
			if (maybeImm.isZero()) {
				switch regOrRegBuf {
				case Reg:
					if (inputA.isReg() || (inputA.isRegBuf() && inputB.isReg()))
						loadZero(type) else null;
				case RegBuf:
					if (inputA.isRegBuf() || (inputA.isReg() && inputB.isRegBuf()))
						loadZero(type) else null;
				default: null;
				}
			} else if (maybeImm.isOne()) {
				switch regOrRegBuf {
				case Reg:
					if (inputB.isReg()) {
						if (inputA.isReg()) None else Load(inputA);
					} else null;
				case RegBuf:
					if (inputB.isRegBuf()) {
						if (inputA.isReg()) None else Load(inputA);
					} else null;
				default: null;
				}
			} else {
				null;
			}

		case Div(inputA, inputB):
			final type = inputA.getType();
			if (maybeImm.isZero()) {
				switch regOrRegBuf {
				case Reg:
					if (inputA.isReg()) loadZero(type) else null;
				case RegBuf:
					if (inputA.isRegBuf()) loadZero(type) else null;
				default: null;
				}
			} else if (maybeImm.isOne()) {
				switch regOrRegBuf {
				case Reg:
					if (inputB.isReg()) {
						if (inputA.isReg()) None else Load(inputA);
					} else null;
				case RegBuf:
					if (inputB.isRegBuf()) {
						if (inputA.isReg()) None else Load(inputA);
					} else null;
				default: null;
				}
			} else {
				null;
			}

		case Mod(inputA, inputB):
			final type = inputA.getType();
			if (maybeImm.isZero()) {
				switch regOrRegBuf {
				case Reg:
					if (inputA.isReg()) loadZero(type) else null;
				case RegBuf:
					if (inputA.isRegBuf()) loadZero(type) else null;
				default: null;
				}
			} else {
				null;
			}

		case Increase(input, _):
			if (maybeImm.isZero()) switch regOrRegBuf {
			case Reg:
				if (input.isReg()) None else null;
			case RegBuf:
				if (input.isRegBuf()) None else null;
			default: null;
			} else {
				null;
			}

		default: null;
		}
		return Maybe.from(newInst);
	}
}
