package firedancer.bytecode;

import haxe.Int32;

/**
	Value of `firedancer.bytecode.Word.Opcode`.

	Operation code value i.e. a value that specifies an operation to be performed.
**/
@:using(firedancer.bytecode.Opcode.OpcodeExtension)
enum abstract Opcode(Int) to Int to Int32 {
	static function error(v: Int): String
		return 'Unknown opcode: $v';

	/**
		Converts `value` to `Opcode`.
		Throws error if `value` does not match any `Opcode` values.
	**/
	public static inline function from(value: Int): Opcode {
		return switch value {
			case Opcode.Break: Break;
			case Opcode.CountDown: CountDown;
			case Opcode.PushInt: PushInt;
			case Opcode.Decrement: Decrement;
			case Opcode.SetPositionC: SetPositionC;
			case Opcode.SetVelocityC: SetVelocityC;
			default: throw error(value);
		}
	}

	final Break = 10;
	final CountDown;
	final PushInt = 20;
	final Decrement = 30;
	final SetPositionC = 50;
	final SetVelocityC;
}

class OpcodeExtension {
	public static inline function toString(code: Opcode): String {
		return switch code {
			case Break: "BREAK";
			case CountDown: "COUNT_DOWN";
			case PushInt: "PUSH_INT";
			case Decrement: "DECREMENT";
			case SetPositionC: "SET_POSITION_CONST";
			case SetVelocityC: "SET_VELOCITY_CONST";
		}
	}
}
