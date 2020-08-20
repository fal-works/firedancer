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
			case Stack: [op(UseThreadS), programId];
			default: throw unsupported();
			}
		case AwaitThread:
			op(AwaitThread);
		case End(endCode):
			[op(End), endCode];

			// ---- load values ------------------------------------------------

		case Load(input):
			switch input {
			case Immediate(imm):
				switch imm {
				case Int(value): [op(LoadIntCV), value];
				case Float(value): [op(LoadFloatCV), value];
				case Vec(x, y): [
						op(LoadVecCV),
						x,
						y
					];
				}
			case LocalVariable(address, type):
				switch type {
				case Int: [op(LoadIntLV), address];
				case Float: [op(LoadFloatLV), address];
				case Vec: throw unsupported();
				}
			}

		case Save(type):
			switch type {
			case Int: op(SaveIntV);
			case Float: op(SaveFloatV);
			case Vec: throw unsupported();
			}
		case Store(input, address):
			switch input {
			case Immediate(imm):
				switch imm {
				case Int(value):
					[
						op(StoreIntCL),
						address,
						value
					];
				case Float(value):
					[
						op(StoreIntCL),
						address,
						value
					];
				case Vec(_, _):
					throw unsupported();
				}
			case Reg(reg):
				switch reg {
				case Ri: [op(StoreIntVL), address];
				case Rf: [op(StoreFloatVL), address];
				default: throw unsupported();
				}
			}

			// ---- read/write stack ---------------------------------------------

		case Push(input):
			switch input {
			case Immediate(imm):
				switch imm {
				case Int(value): [op(PushIntC), value];
				case Float(value): [op(PushFloatC), value];
				case Vec(_, _): throw unsupported();
				}
			case Reg(reg):
				switch reg {
				case Ri: op(PushIntV);
				case Rf: op(PushFloatV);
				case Rvec: op(PushVecV);
				default: throw unsupported();
				}
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
			op(GlobalEvent);
		case LocalEvent:
			op(LocalEvent);
		case Debug(debugCode):
			[op(Debug), debugCode];

			// ---- calc values ---------------------------------------------

		case Add(inputA, inputB):
			if (inputA.getType() != inputB.getType()) throw unsupported();
			switch inputA {
			case Reg(regA):
				switch inputB {
				case Immediate(immB):
					switch immB {
					case Int(valueB):
						[op(AddIntVCV), (valueB : Int)];
					case Float(valueB):
						[op(AddFloatVCV), valueB];
					case Vec(_, _):
						throw unsupported();
					}
				case Reg(regB):
					if (regA == Rib && regB == Ri) {
						op(AddIntVVV);
					} else if (regA == Rfb && regB == Rf) {
						op(AddFloatVVV);
					} else throw unsupported();
				}
			case LocalVariable(address, _):
				switch inputB {
				case Immediate(immB):
					switch immB {
					case Int(valueB):
						[
							op(AddIntLCL),
							address,
							valueB
						];
					case Float(valueB):
						[
							op(AddFloatLCL),
							address,
							valueB
						];
					case Vec(_, _): throw unsupported();
					}
				case Reg(regB):
					switch regB {
					case Ri: [op(AddIntLVL), address];
					case Rf: [op(AddFloatLVL), address];
					default: throw unsupported();
					}
				}
			}
		case Sub(inputA, inputB):
			if (inputA.getType() != inputB.getType()) throw unsupported();
			switch inputA {
			case Immediate(immA):
				switch immA {
				case Int(valueA):
					switch inputB {
					case Reg(regB):
						switch regB {
						case Ri: [op(SubIntCVV), valueA];
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				case Float(valueA):
					switch inputB {
					case Reg(regB):
						switch regB {
						case Rf: [op(SubFloatCVV), valueA];
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				case Vec(_, _): throw unsupported();
				}
			case Reg(regA):
				switch inputB {
				case Immediate(immB):
					switch immB {
					case Int(valueB):
						[op(SubIntVCV), (valueB : Int)];
					case Float(valueB):
						[op(SubFloatVCV), valueB];
					case Vec(_, _):
						throw unsupported();
					}
				case Reg(regB):
					if (regA == Rib && regB == Ri) {
						op(SubIntVVV);
					} else if (regA == Rfb && regB == Rf) {
						op(SubFloatVVV);
					} else throw unsupported();
				}
			}
		case Minus(reg):
			switch reg {
			case Ri: op(MinusIntV);
			case Rf: op(MinusFloatV);
			case Rvec: op(MinusVecV);
			default: throw unsupported();
			};
		case Mult(regA, inputB):
			if (regA.getType() != inputB.getType()) throw unsupported();
			switch inputB {
			case Immediate(immB):
				switch immB {
				case Float(valueB):
					switch regA {
					case Ri: [op(MultIntVCV), valueB];
					case Rf: [op(MultFloatVCV), valueB];
					case Rvec: [op(MultVecVCV), valueB];
					default: throw unsupported();
					}
				default: throw unsupported();
				}
			case Reg(regB):
				switch regA {
				case Rib: switch regB {
					case Ri: op(MultIntVVV); // rib * ri
					default: throw unsupported();
					}
				case Rfb: switch regB {
					case Rf: op(MultFloatVVV); // rfb * rf
					default: throw unsupported();
					}
				case Rvec: switch regB {
					case Rf: op(MultVecVVV); // rvec * rf
					default: throw unsupported();
					}
				default: throw unsupported();
				}
			}
		case Div(inputA, inputB):
			if (inputA.getType() != inputB.getType()) throw unsupported();
			switch inputA {
			case Immediate(immA):
				switch immA {
				case Int(valueA):
					switch inputB {
					case Reg(regB):
						switch regB {
						case Ri: [op(DivIntCVV), valueA];
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				case Float(valueA):
					switch inputB {
					case Reg(regB):
						switch regB {
						case Rf: [op(DivFloatCVV), valueA];
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				case Vec(_, _): throw unsupported();
				}
			case Reg(regA):
				switch inputB {
				case Immediate(immB):
					switch immB {
					case Int(valueB):
						[op(DivIntVCV), (valueB : Int)];
					case Float(valueB):
						[op(DivFloatVCV), valueB];
					case Vec(_, _):
						throw unsupported();
					}
				case Reg(regB):
					if (regA == Rib && regB == Ri) {
						op(DivIntVVV);
					} else if (regA == Rfb && regB == Rf) {
						op(DivFloatVVV);
					} else if (regA == Rvec && regB == Rf) {
						op(DivVecVVV);
					} else throw unsupported();
				}
			}
		case Mod(inputA, inputB):
			if (inputA.getType() != inputB.getType()) throw unsupported();
			switch inputA {
			case Immediate(immA):
				switch immA {
				case Int(valueA):
					switch inputB {
					case Reg(regB):
						switch regB {
						case Ri: [op(ModIntCVV), valueA];
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				case Float(valueA):
					switch inputB {
					case Reg(regB):
						switch regB {
						case Rf: [op(ModFloatCVV), valueA];
						default: throw unsupported();
						}
					default: throw unsupported();
					}
				case Vec(_, _): throw unsupported();
				}
			case Reg(regA):
				switch inputB {
				case Immediate(immB):
					switch immB {
					case Int(valueB):
						[op(ModIntVCV), (valueB : Int)];
					case Float(valueB):
						[op(ModFloatVCV), valueB];
					case Vec(_, _):
						throw unsupported();
					}
				case Reg(regB):
					if (regA == Rib && regB == Ri) {
						op(ModIntVVV);
					} else if (regA == Rfb && regB == Rf) {
						op(ModFloatVVV);
					} else throw unsupported();
				}
			}

		case CastIntToFloat:
			op(CastIntToFloatVV);
		case CastCartesian:
			op(CastCartesianVV);
		case CastPolar:
			op(CastPolarVV);

		case RandomRatio:
			op(RandomRatioV);
		case Random(max):
			switch max {
			case Immediate(imm):
				switch imm {
				case Int(value): [op(RandomIntCV), value];
				case Float(value): [op(RandomFloatCV), value];
				default: throw unsupported();
				}
			case Reg(reg):
				switch reg {
				case Ri: op(RandomIntVV);
				case Rf: op(RandomFloatVV);
				default: throw unsupported();
				}
			}
		case RandomSigned(maxMagnitude):
			switch maxMagnitude {
			case Immediate(imm):
				switch imm {
				case Int(value): [op(RandomIntSignedCV), value];
				case Float(value): [op(RandomFloatSignedCV), value];
				default: throw unsupported();
				}
			case Reg(reg):
				switch reg {
				case Ri: op(RandomIntSignedVV);
				case Rf: op(RandomFloatSignedVV);
				default: throw unsupported();
				}
			}

		case Sin:
			op(Sin);
		case Cos:
			op(Cos);

		case IncrementL(address):
			[op(IncrementL), address];
		case DecrementL(address):
			[op(DecrementL), address];

			// ---- read actor data

		case LoadTargetPositionV:
			op(LoadTargetPositionV);
		case LoadTargetXV:
			op(LoadTargetXV);
		case LoadTargetYV:
			op(LoadTargetYV);
		case LoadBearingToTargetV:
			op(LoadBearingToTargetV);

		case CalcRelative(attrType, cmpType, input):
			switch input {
			case Immediate(imm):
				final opcode:Opcode = switch cmpType {
				case Vector:
					switch attrType {
					case Position: CalcRelativePositionCV;
					case Velocity: CalcRelativeVelocityCV;
					case ShotPosition: CalcRelativeShotPositionCV;
					case ShotVelocity: CalcRelativeShotVelocityCV;
					}
				case Length:
					switch attrType {
					case Position: CalcRelativeDistanceCV;
					case Velocity: CalcRelativeSpeedCV;
					case ShotPosition: CalcRelativeShotDistanceCV;
					case ShotVelocity: CalcRelativeShotSpeedCV;
					}
				case Angle:
					switch attrType {
					case Position: CalcRelativeBearingCV;
					case Velocity: CalcRelativeDirectionCV;
					case ShotPosition: CalcRelativeShotBearingCV;
					case ShotVelocity: CalcRelativeShotDirectionCV;
					}
				};
				switch imm {
				case Vec(x, y):
					if (cmpType != Vector) throw unsupported();
					[
						op(opcode),
						x,
						y
					];
				case Float(value):
					if (cmpType == Vector) throw unsupported();
					[op(opcode), value];
				default: throw unsupported();
				}
			case Reg(reg):
				final opcode:Opcode = switch cmpType {
				case Vector:
					switch attrType {
					case Position: CalcRelativePositionVV;
					case Velocity: CalcRelativeVelocityVV;
					case ShotPosition: CalcRelativeShotPositionVV;
					case ShotVelocity: CalcRelativeShotVelocityVV;
					}
				case Length:
					switch attrType {
					case Position: CalcRelativeDistanceVV;
					case Velocity: CalcRelativeSpeedVV;
					case ShotPosition: CalcRelativeShotDistanceVV;
					case ShotVelocity: CalcRelativeShotSpeedVV;
					}
				case Angle:
					switch attrType {
					case Position: CalcRelativeBearingVV;
					case Velocity: CalcRelativeDirectionVV;
					case ShotPosition: CalcRelativeShotBearingVV;
					case ShotVelocity: CalcRelativeShotDirectionVV;
					}
				};
				switch reg {
				case Rvec:
					if (cmpType != Vector) throw unsupported();
					op(opcode);
				case Rf:
					if (cmpType == Vector) throw unsupported();
					op(opcode);
				default: throw unsupported();
				}
			}

			// ---- write actor data -----------------------------------------

		case SetVector(attrType, cmpType, input):
			switch input {
			case Imm(imm):
				final opcode:Opcode = switch cmpType {
				case Vector:
					switch attrType {
					case Position: SetPositionC;
					case Velocity: SetVelocityC;
					case ShotPosition: SetShotPositionC;
					case ShotVelocity: SetShotVelocityC;
					}
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
				switch imm {
				case Vec(x, y):
					if (cmpType != Vector) throw unsupported();
					[
						op(opcode),
						x,
						y
					];
				case Float(value):
					if (cmpType == Vector) throw unsupported();
					[op(opcode), value];
				default: throw unsupported();
				}
			case Reg(reg):
				final opcode:Opcode = switch cmpType {
				case Vector:
					switch attrType {
					case Position: SetPositionV;
					case Velocity: SetVelocityV;
					case ShotPosition: SetShotPositionV;
					case ShotVelocity: SetShotVelocityV;
					}
				case Length:
					switch attrType {
					case Position: SetDistanceV;
					case Velocity: SetSpeedV;
					case ShotPosition: SetShotDistanceV;
					case ShotVelocity: SetShotSpeedV;
					}
				case Angle:
					switch attrType {
					case Position: SetBearingV;
					case Velocity: SetDirectionV;
					case ShotPosition: SetShotBearingV;
					case ShotVelocity: SetShotDirectionV;
					}
				};
				switch reg {
				case Rvec:
					if (cmpType != Vector) throw unsupported();
					op(opcode);
				case Rf:
					if (cmpType == Vector) throw unsupported();
					op(opcode);
				default: throw unsupported();
				}
			case Stack: throw unsupported();
			}
		case AddVector(attrType, cmpType, input):
			switch input {
			case Imm(imm):
				final opcode:Opcode = switch cmpType {
				case Vector:
					switch attrType {
					case Position: AddPositionC;
					case Velocity: AddVelocityC;
					case ShotPosition: AddShotPositionC;
					case ShotVelocity: AddShotVelocityC;
					}
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
				switch imm {
				case Vec(x, y):
					if (cmpType != Vector) throw unsupported();
					[
						op(opcode),
						x,
						y
					];
				case Float(value):
					if (cmpType == Vector) throw unsupported();
					[op(opcode), value];
				default: throw unsupported();
				}
			case Reg(reg):
				final opcode:Opcode = switch cmpType {
				case Vector:
					switch attrType {
					case Position: AddPositionV;
					case Velocity: AddVelocityV;
					case ShotPosition: AddShotPositionV;
					case ShotVelocity: AddShotVelocityV;
					}
				case Length:
					switch attrType {
					case Position: AddDistanceV;
					case Velocity: AddSpeedV;
					case ShotPosition: AddShotDistanceV;
					case ShotVelocity: AddShotSpeedV;
					}
				case Angle:
					switch attrType {
					case Position: AddBearingV;
					case Velocity: AddDirectionV;
					case ShotPosition: AddShotBearingV;
					case ShotVelocity: AddShotDirectionV;
					}
				};
				switch reg {
				case Rvec:
					if (cmpType != Vector) throw unsupported();
					op(opcode);
				case Rf:
					if (cmpType == Vector) throw unsupported();
					op(opcode);
				default: throw unsupported();
				}
			case Stack:
				final opcode:Opcode = switch cmpType {
				case Vector:
					switch attrType {
					case Position: AddPositionS;
					case Velocity: AddVelocityS;
					case ShotPosition: AddShotPositionS;
					case ShotVelocity: AddShotVelocityS;
					}
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
			}
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
		case Save(type):
			final input = DataRegisterSpecifier.get(type);
			final output = input.getBuffer();
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

		case Add(inputA, inputB):
			final outputStr = switch inputA {
			case Reg(regA): DataRegisterSpecifier.get(regA.getType()).toString();
			case LocalVariable(address, type): varToString(address, type);
			}
			'add ${inputA.toString()}, ${inputB.toString()} -> $outputStr';
		case Sub(inputA, inputB):
			final outputStr = DataRegisterSpecifier.get(inputA.getType()).toString();
			'sub ${inputA.toString()}, ${inputB.toString()} -> $outputStr';
		case Minus(reg):
			final inOutStr = reg.toString();
			'minus $inOutStr -> $inOutStr';
		case Mult(regA, inputB):
			final outputStr = DataRegisterSpecifier.get(regA.getType()).toString();
			'mult ${regA.toString()}, ${inputB.toString()} -> $outputStr';
		case Div(inputA, inputB):
			final outputStr = DataRegisterSpecifier.get(inputA.getType()).toString();
			'div ${inputA.toString()}, ${inputB.toString()} -> $outputStr';
		case Mod(inputA, inputB):
			final outputStr = DataRegisterSpecifier.get(inputA.getType()).toString();
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

		case IncrementL(address):
			final inOutStr = varToString(address, Int);
			'increment $inOutStr -> $inOutStr';
		case DecrementL(address):
			final inOutStr = varToString(address, Int);
			'decrement $inOutStr -> $inOutStr';

			// ---- read actor data

		case LoadTargetPositionV:
			'load target position ->v';
		case LoadTargetXV:
			'load target x ->v';
		case LoadTargetYV:
			'load target y ->v';
		case LoadBearingToTargetV:
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
		case Save(type): UInt.zero;
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

		case Add(inputA, inputB): inputA.bytecodeLength() + inputB.bytecodeLength();
		case Sub(inputA, inputB): inputA.bytecodeLength() + inputB.bytecodeLength();
		case Minus(reg): UInt.zero;
		case Mult(regA, inputB): inputB.bytecodeLength();
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

		case IncrementL(address): LEN32;
		case DecrementL(address): LEN32;

			// ---- read actor data ------------------------------------------

		case LoadTargetPositionV: UInt.zero;
		case LoadTargetXV: UInt.zero;
		case LoadTargetYV: UInt.zero;
		case LoadBearingToTargetV: UInt.zero;

		case CalcRelative(_, _, input): input.bytecodeLength();

			// ---- write actor data -----------------------------------------

		case SetVector(_, _, input): input.bytecodeLength();
		case AddVector(_, _, input): input.bytecodeLength();
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
}