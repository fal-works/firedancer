package firedancer.assembly;

import haxe.Int32;

/**
	Value that specifies an operation to be performed.
**/
@:using(firedancer.assembly.Opcode.OpcodeExtension)
enum abstract Opcode(Int32) to Int to Int32 {
	static function error(v: Int32): String
		return 'Unknown opcode: $v';

	/**
		Converts `value` to `Opcode`.
		Throws error if `value` does not match any `Opcode` values.
	**/
	public static inline function from(value: Int32): Opcode {
		return switch value {
			case Opcode.Break: Break;
			case Opcode.CountDown: CountDown;
			case Opcode.PushInt: PushInt;
			case Opcode.Decrement: Decrement;
			case Opcode.SetPositionConst: SetPositionConst;
			case Opcode.SetVelocityConst: SetVelocityConst;
			default: throw error(value);
		}
	}

	final Break = 10;
	final CountDown;
	final PushInt = 20;
	final Decrement = 30;
	final SetPositionConst = 50;
	final SetVelocityConst;
}

class OpcodeExtension {
	/**
		@return The mnemonic for `code`.
	**/
	public static inline function toString(code: Opcode): String {
		return switch code {
			case Break: "break";
			case CountDown: "count_down";
			case PushInt: "push_int";
			case Decrement: "decrement";
			case SetPositionConst: "set_position_const";
			case SetVelocityConst: "set_velocity_const";
		}
	}
}
