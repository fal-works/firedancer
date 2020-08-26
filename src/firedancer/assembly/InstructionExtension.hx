package firedancer.assembly;

import firedancer.bytecode.Constants.*;
import firedancer.assembly.OperandTools.*;

class InstructionExtension {
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

		case Fire(fireType): fireType.toString();

			// ---- other ---------------------------------------------------

		case Event(eventType):
			'event ${eventType.toString()} ri -> n';
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

		case Cast(type):
			final outputStr = DataRegisterSpecifier.get(type.getOutputType()).toString();
			switch type {
			case IntToFloat:
				'cast ri -> $outputStr';
			case CartesianToVec:
				'cast cartesian rfb, rf -> $outputStr';
			case PolarToVec:
				'cast polar rfb, rf -> $outputStr';
			}

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

		case Get(prop):
			final outputStr = DataRegisterSpecifier.get(prop.getValueType()).toString();
			'get ${prop.toString()} -> $outputStr';

		case GetDiff(input, prop):
			final outputStr = DataRegisterSpecifier.get(input.getType()).toString();
			'get diff ${input.toString()}, ${prop.toString()} -> $outputStr';

		case GetTarget(prop):
			final outputStr = DataRegisterSpecifier.get(prop.getType()).toString();
			'get target_${prop.toString()} -> $outputStr';

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
		case GotoLabel(labelId): IntSize;
		case CountDownGotoLabel(labelId): IntSize;
		case UseThread(programId, output): IntSize + output.bytecodeLength();
		case AwaitThread: UInt.zero;
		case End(endCode): IntSize;

			// ---- load values ------------------------------------------------

		case Load(input): input.bytecodeLength();
		case Save(input): input.bytecodeLength();
		case Store(input, address): input.bytecodeLength() + IntSize;

			// ---- read/write stack ---------------------------------------------

		case Push(input): input.bytecodeLength();
		case Pop(_): UInt.zero;
		case Peek(_, bytesToSkip): IntSize;
		case Drop(_): UInt.zero;

			// ---- fire ---------------------------------------------------

		case Fire(fireType): fireType.bytecodeLength();

			// ---- other ---------------------------------------------------

		case Event(_): UInt.zero;
		case Debug(debugCode): IntSize;

			// ---- calc values ---------------------------------------------

		case Add(input): input.bytecodeLength();
		case Sub(input): input.bytecodeLength();
		case Minus(reg): UInt.zero;
		case Mult(inputA, inputB): inputB.bytecodeLength();
		case Div(inputA, inputB): inputA.bytecodeLength() + inputB.bytecodeLength();
		case Mod(inputA, inputB): inputA.bytecodeLength() + inputB.bytecodeLength();

		case Cast(_): UInt.zero;

		case RandomRatio: UInt.zero;
		case Random(max): max.bytecodeLength();
		case RandomSigned(maxMagnitude): maxMagnitude.bytecodeLength();

		case Sin: UInt.zero;
		case Cos: UInt.zero;

		case Increment(address): IntSize;
		case Decrement(address): IntSize;

			// ---- read actor data ------------------------------------------

		case Get(prop): UInt.zero;
		case GetDiff(input, prop): input.bytecodeLength();
		case GetTarget(prop): UInt.zero;

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

		case Event(_): regType == Int;

		case Add(input): input.tryGetRegType() == regType;
		case Sub(input): input.tryGetRegType() == regType;
		case Minus(input): input.tryGetRegType() == regType;
		case Mult(inputA, inputB): inputA.tryGetRegType() == regType || inputB.tryGetRegType() == regType;
		case Div(inputA, inputB): inputA.tryGetRegType() == regType || inputB.tryGetRegType() == regType;
		case Mod(inputA, inputB): inputA.tryGetRegType() == regType || inputB.tryGetRegType() == regType;

		case Cast(type): switch type {
			case IntToFloat: regType == Int;
			case CartesianToVec | PolarToVec: regType == Float;
			}

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

		case Cast(type): switch type {
			case CartesianToVec | PolarToVec: regType == Float;
			default: false;
			}

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

		case Cast(castType): castType.getOutputType();

		case RandomRatio: ValueType.Float;
		case Random(max): max.getType();
		case RandomSigned(maxMagnitude): maxMagnitude.getType();

		case Sin: ValueType.Float;
		case Cos: ValueType.Float;

		case Get(prop): prop.getValueType();
		case GetDiff(input, _): input.getType();
		case GetTarget(prop): prop.getType();

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

	static function unsupported(): String
		return "Unsupported operation.";
}
