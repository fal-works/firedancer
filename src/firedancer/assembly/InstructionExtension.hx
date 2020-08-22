package firedancer.assembly;

import firedancer.types.ActorAttributeType;
import firedancer.types.ActorAttributeComponentType;
import firedancer.bytecode.Word;
import firedancer.bytecode.WordArray;
import firedancer.bytecode.internal.Constants.*;
import firedancer.assembly.operation.GeneralOperation;
import firedancer.assembly.operation.CalcOperation;
import firedancer.assembly.operation.ReadOperation;
import firedancer.assembly.operation.WriteOperation;
import firedancer.assembly.OperandTools.*;

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
				case Var(address): [op(LoadIntVR), address];
				default: throw unsupported();
				}
			case Float(operand):
				switch operand {
				case Imm(value): [op(LoadFloatCR), value];
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

		case IncrementVV(address):
			[op(IncrementVV), address];
		case DecrementVV(address):
			[op(DecrementVV), address];

			// ---- read actor data

		case LoadTargetPositionR:
			op(LoadTargetPositionR);
		case LoadTargetXR:
			op(LoadTargetXR);
		case LoadTargetYR:
			op(LoadTargetYR);
		case LoadBearingToTargetR:
			op(LoadBearingToTargetR);

		case CalcRelative(attrType, cmpType, input):
			switch input {
			case Vec(operand):
				if (cmpType != Vector) throw unsupported();
				switch operand {
				case Imm(x, y):
					final opcode:Opcode = switch attrType {
					case Position: CalcRelativePositionCR;
					case Velocity: CalcRelativeVelocityCR;
					case ShotPosition: CalcRelativeShotPositionCR;
					case ShotVelocity: CalcRelativeShotVelocityCR;
					};
					[
						op(opcode),
						x,
						y
					];
				case Reg:
					final opcode:Opcode = switch attrType {
					case Position: CalcRelativePositionRR;
					case Velocity: CalcRelativeVelocityRR;
					case ShotPosition: CalcRelativeShotPositionRR;
					case ShotVelocity: CalcRelativeShotVelocityRR;
					};
					op(opcode);
				default: throw unsupported();
				}
			case Float(operand):
				switch operand {
				case Imm(value):
					final opcode:Opcode = switch cmpType {
					case Vector: throw unsupported();
					case Length:
						switch attrType {
						case Position: CalcRelativeDistanceCR;
						case Velocity: CalcRelativeSpeedCR;
						case ShotPosition: CalcRelativeShotDistanceCR;
						case ShotVelocity: CalcRelativeShotSpeedCR;
						}
					case Angle:
						switch attrType {
						case Position: CalcRelativeBearingCR;
						case Velocity: CalcRelativeDirectionCR;
						case ShotPosition: CalcRelativeShotBearingCR;
						case ShotVelocity: CalcRelativeShotDirectionCR;
						}
					};
					[op(opcode), value];
				case Reg:
					final opcode:Opcode = switch cmpType {
					case Vector: throw unsupported();
					case Length:
						switch attrType {
						case Position: CalcRelativeDistanceRR;
						case Velocity: CalcRelativeSpeedRR;
						case ShotPosition: CalcRelativeShotDistanceRR;
						case ShotVelocity: CalcRelativeShotSpeedRR;
						}
					case Angle:
						switch attrType {
						case Position: CalcRelativeBearingRR;
						case Velocity: CalcRelativeDirectionRR;
						case ShotPosition: CalcRelativeShotBearingRR;
						case ShotVelocity: CalcRelativeShotDirectionRR;
						}
					};
					op(opcode);
				default: throw unsupported();
				}
			default: throw unsupported();
			}

			// ---- write actor data -----------------------------------------

		case SetVector(attrType, cmpType, input):
			switch input {
			case Vec(operand):
				if (cmpType != Vector) throw unsupported();
				switch operand {
				case Imm(x, y):
					final opcode:Opcode = switch attrType {
					case Position: SetPositionC;
					case Velocity: SetVelocityC;
					case ShotPosition: SetShotPositionC;
					case ShotVelocity: SetShotVelocityC;
					};
					[
						op(opcode),
						x,
						y
					];
				case Reg:
					final opcode:Opcode = switch attrType {
					case Position: SetPositionR;
					case Velocity: SetVelocityR;
					case ShotPosition: SetShotPositionR;
					case ShotVelocity: SetShotVelocityR;
					};
					op(opcode);
				default: throw unsupported();
				}
			case Float(operand):
				switch operand {
				case Imm(value):
					final opcode:Opcode = switch cmpType {
					case Vector: throw unsupported();
					case Length:
						switch attrType {
						case Position: SetDistanceC;
						case Velocity: SetSpeedC;
						case ShotPosition: SetShotDistanceC;
						case ShotVelocity: SetShotSpeedC;
						}
					case Angle:
						switch attrType {
						case Position: SetBearingC;
						case Velocity: SetDirectionC;
						case ShotPosition: SetShotBearingC;
						case ShotVelocity: SetShotDirectionC;
						}
					};
					[op(opcode), value];
				case Reg:
					final opcode:Opcode = switch cmpType {
					case Vector: throw unsupported();
					case Length:
						switch attrType {
						case Position: SetDistanceR;
						case Velocity: SetSpeedR;
						case ShotPosition: SetShotDistanceR;
						case ShotVelocity: SetShotSpeedR;
						}
					case Angle:
						switch attrType {
						case Position: SetBearingR;
						case Velocity: SetDirectionR;
						case ShotPosition: SetShotBearingR;
						case ShotVelocity: SetShotDirectionR;
						}
					};
					op(opcode);
				default: throw unsupported();
				}
			default: throw unsupported();
			}

		case AddVector(attrType, cmpType, input):
			switch input {
			case Vec(operand):
				if (cmpType != Vector) throw unsupported();
				switch operand {
				case Imm(x, y):
					final opcode:Opcode = switch attrType {
					case Position: AddPositionC;
					case Velocity: AddVelocityC;
					case ShotPosition: AddShotPositionC;
					case ShotVelocity: AddShotVelocityC;
					};
					[
						op(opcode),
						x,
						y
					];
				case Reg:
					final opcode:Opcode = switch attrType {
					case Position: AddPositionR;
					case Velocity: AddVelocityR;
					case ShotPosition: AddShotPositionR;
					case ShotVelocity: AddShotVelocityR;
					};
					op(opcode);
				case Stack:
					final opcode:Opcode = switch attrType {
					case Position: AddPositionS;
					case Velocity: AddVelocityS;
					case ShotPosition: AddShotPositionS;
					case ShotVelocity: AddShotVelocityS;
					};
					op(opcode);
				default: throw unsupported();
				}
			case Float(operand):
				switch operand {
				case Imm(value):
					final opcode:Opcode = switch cmpType {
					case Vector: throw unsupported();
					case Length:
						switch attrType {
						case Position: AddDistanceC;
						case Velocity: AddSpeedC;
						case ShotPosition: AddShotDistanceC;
						case ShotVelocity: AddShotSpeedC;
						}
					case Angle:
						switch attrType {
						case Position: AddBearingC;
						case Velocity: AddDirectionC;
						case ShotPosition: AddShotBearingC;
						case ShotVelocity: AddShotDirectionC;
						}
					};
					[op(opcode), value];
				case Reg:
					final opcode:Opcode = switch cmpType {
					case Vector: throw unsupported();
					case Length:
						switch attrType {
						case Position: AddDistanceR;
						case Velocity: AddSpeedR;
						case ShotPosition: AddShotDistanceR;
						case ShotVelocity: AddShotSpeedR;
						}
					case Angle:
						switch attrType {
						case Position: AddBearingR;
						case Velocity: AddDirectionR;
						case ShotPosition: AddShotBearingR;
						case ShotVelocity: AddShotDirectionR;
						}
					};
					op(opcode);
				case Stack:
					final opcode:Opcode = switch cmpType {
					case Vector: throw unsupported();
					case Length:
						switch attrType {
						case Position: AddDistanceS;
						case Velocity: AddSpeedS;
						case ShotPosition: AddShotDistanceS;
						case ShotVelocity: AddShotSpeedS;
						}
					case Angle:
						switch attrType {
						case Position: AddBearingS;
						case Velocity: AddDirectionS;
						case ShotPosition: AddShotBearingS;
						case ShotVelocity: AddShotDirectionS;
						}
					};
					op(opcode);
				default: throw unsupported();
				}
			default: throw unsupported();
			}

		case None:
			throw unsupported();
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
			'goto ${itoa(labelId)}';
		case CountDownGotoLabel(labelId):
			'countdown goto ${itoa(labelId)}';
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
			'global event ri -> n';
		case LocalEvent:
			'local event ri -> n';
		case Debug(debugCode):
			'debug ${itoa(debugCode)} -> n';

			// ---- calc values ---------------------------------------------

		case Add(input):
			final outputStr = switch input {
			case Int(a, b):
				switch a {
				case Var(_): a.toString();
				case Reg: a.toString();
				case RegBuf: b.toString();
				default: throw unsupported();
				}
			case Float(a, b):
				switch a {
				case Var(_): a.toString();
				case Reg: a.toString();
				case RegBuf: b.toString();
				default: throw unsupported();
				}
			default: throw unsupported();
			};
			'add ${input.toString()} -> $outputStr';
		case Sub(input):
			final outputStr = switch input {
			case Int(a, b): a.toString();
			case Float(a, b): a.toString();
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
			'cast caretsian rfb, rf -> rvec';
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

		case IncrementVV(address):
			final inOutStr = varToString(address, Int);
			'increment $inOutStr -> $inOutStr';
		case DecrementVV(address):
			final inOutStr = varToString(address, Int);
			'decrement $inOutStr -> $inOutStr';

			// ---- read actor data

		case LoadTargetPositionR:
			'load target position ->v';
		case LoadTargetXR:
			'load target x ->v';
		case LoadTargetYR:
			'load target y ->v';
		case LoadBearingToTargetR:
			'load bearing to target ->v';

		case CalcRelative(attrType, cmpType, input):
			final output = actorAttributeToString(attrType, cmpType);
			'calc relative ${input.toString()} -> $output';

			// ---- write actor data -----------------------------------------

		case SetVector(attrType, cmpType, input):
			final output = actorAttributeToString(attrType, cmpType);
			'set ${input.toString()} -> $output';
		case AddVector(attrType, cmpType, input):
			final output = actorAttributeToString(attrType, cmpType);
			'add ${input.toString()} -> $output';

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

		case IncrementVV(address): LEN32;
		case DecrementVV(address): LEN32;

			// ---- read actor data ------------------------------------------

		case LoadTargetPositionR: UInt.zero;
		case LoadTargetXR: UInt.zero;
		case LoadTargetYR: UInt.zero;
		case LoadBearingToTargetR: UInt.zero;

		case CalcRelative(_, _, input): input.bytecodeLength();

			// ---- write actor data -----------------------------------------

		case SetVector(_, _, input): input.bytecodeLength();
		case AddVector(_, _, input): input.bytecodeLength();

			// ----

		case None: UInt.zero;
		}
	}

	static function actorAttributeToString(
		attrType: ActorAttributeType,
		cmpType: ActorAttributeComponentType
	) {
		return switch attrType {
		case Position:
			switch cmpType {
			case Vector: "position";
			case Length: "distance";
			case Angle: "bearing";
			}
		case Velocity:
			switch cmpType {
			case Vector: "velocity";
			case Length: "speed";
			case Angle: "direction";
			}
		case ShotPosition:
			switch cmpType {
			case Vector: "shot_position";
			case Length: "shot_distance";
			case Angle: "shot_bearing";
			}
		case ShotVelocity:
			switch cmpType {
			case Vector: "shot_velocity";
			case Length: "shot_speed";
			case Angle: "shot_direction";
			}
		}
	}

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

		case CalcRelative(_, _, input): input.tryGetRegType() == regType;

		case SetVector(_, _, input): input.tryGetRegType() == regType;
		case AddVector(_, _, input): input.tryGetRegType() == regType;

		default: false;
		}
	}

	public static function writesReg(inst: Instruction, regType: ValueType): Bool {
		return switch inst {
		case Load(input): input.getType() == regType;
		case Pop(type): type == regType;
		case Peek(type, _): type == regType;

		case Add(input): input.tryGetRegType() == regType;
		case Sub(input): input.tryGetRegType() == regType;
		case Minus(input): input.getType() == regType;
		case Mult(inputA, inputB): inputA.tryGetRegType() == regType || inputB.tryGetRegType() == regType;
		case Div(inputA, inputB): inputA.tryGetRegType() == regType || inputB.tryGetRegType() == regType;
		case Mod(inputA, inputB): inputA.tryGetRegType() == regType || inputB.tryGetRegType() == regType;

		case CastIntToFloat: regType == Float;
		case CastCartesian: regType == Vec;
		case CastPolar: regType == Vec;

		case RandomRatio: regType == Float;
		case Random(max): max.getType() == regType;
		case RandomSigned(maxMagnitude): maxMagnitude.getType() == regType;

		case Sin: regType == Float;
		case Cos: regType == Float;

		case LoadTargetPositionR: regType == Vec;
		case LoadTargetXR: regType == Float;
		case LoadTargetYR: regType == Float;
		case LoadBearingToTargetR: regType == Float;

		case CalcRelative(_, _, input): input.getType() == Float;

		default: false;
		}
	}

	public static function tryFoldConstant(
		inst: Instruction,
		loaded: Operand
	): Maybe<Instruction> {
		final newInst: Null<Instruction> = switch inst {
		case Load(input):
			final newInput = input.tryReplaceRegWithImm(loaded);
			if (newInput.isSome()) Load(newInput.unwrap()) else null;

		case Store(input, address):
			final newInput = input.tryReplaceRegWithImm(loaded);
			if (newInput.isSome()) Store(newInput.unwrap(), address) else null;

		case Save(input):
			final newInput = input.tryReplaceRegWithImm(loaded);
			if (newInput.isSome()) Save(newInput.unwrap()) else null;

		case Push(input):
			final newInput = input.tryReplaceRegWithImm(loaded);
			if (newInput.isSome()) Push(newInput.unwrap()) else null;

		case Minus(input):
			final newInput = input.tryReplaceRegWithImm(loaded);
			if (newInput.isSome()) Minus(newInput.unwrap()) else null;

		case Add(nextOperands):
			final newNextOperands = nextOperands.tryReplaceRegWithImm(loaded);
			if (newNextOperands.isSome()) Add(newNextOperands.unwrap()) else null;

		case Sub(nextOperands):
			final newNextOperands = nextOperands.tryReplaceRegWithImm(loaded);
			if (newNextOperands.isSome()) Add(newNextOperands.unwrap()) else null;

		case Mult(inputA, inputB):
			final newInputA = inputA.tryReplaceRegWithImm(loaded);
			if (newInputA.isSome()) {
				Instruction.Mult(newInputA.unwrap(), inputB);
			} else {
				final newInputB = inputB.tryReplaceRegWithImm(loaded);
				if (newInputB.isSome()) Instruction.Mult(inputA, newInputB.unwrap());
				else null;
			}

		case Div(inputA, inputB):
			final newInputA = inputA.tryReplaceRegWithImm(loaded);
			if (newInputA.isSome()) {
				Instruction.Div(newInputA.unwrap(), inputB);
			} else {
				final newInputB = inputB.tryReplaceRegWithImm(loaded);
				if (newInputB.isSome()) Instruction.Div(inputA, newInputB.unwrap())
				else null;
			}

		case Mod(inputA, inputB):
			final newInputA = inputA.tryReplaceRegWithImm(loaded);
			if (newInputA.isSome()) {
				Instruction.Mod(newInputA.unwrap(), inputB);
			} else {
				final newInputB = inputB.tryReplaceRegWithImm(loaded);
				if (newInputB.isSome()) Instruction.Mod(inputA, newInputB.unwrap())
				else null;
			}

		case CalcRelative(attrType, cmpType, input):
			final newInput = input.tryReplaceRegWithImm(loaded);
			if (newInput.isSome()) {
				CalcRelative(attrType, cmpType, newInput.unwrap());
			} else null;

		case SetVector(attrType, cmpType, input):
			final newInput = input.tryReplaceRegWithImm(loaded);
			if (newInput.isSome()) {
				SetVector(attrType, cmpType, newInput.unwrap());
			} else null;

		case AddVector(attrType, cmpType, input):
			final newInput = input.tryReplaceRegWithImm(loaded);
			if (newInput.isSome()) {
				AddVector(attrType, cmpType, newInput.unwrap());
			} else null;

		default: null;
		}

		return Maybe.from(newInst);
	}
}
