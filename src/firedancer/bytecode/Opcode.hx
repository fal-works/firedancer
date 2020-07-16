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
			case Opcode.SetVelocity: SetVelocity;
			default: throw error(value);
		}
	}

	final Break = 10;
	final CountDown;
	final PushInt = 20;
	final Decrement = 30;
	final SetVelocity = 50;
}

class OpcodeExtension {
	public static inline function toString(code: Opcode): String {
		return switch code {
			case Break: "BREAK";
			case CountDown: "COUNT DOWN";
			case PushInt: "PUSH INT";
			case Decrement: "DECREMENT";
			case SetVelocity: "SET VELOCITY";
		}
	}
}
