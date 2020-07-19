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
			case Opcode.Jump: Jump;
			case Opcode.CountDownJump: CountDownJump;
			case Opcode.PushInt: PushInt;
			case Opcode.Decrement: Decrement;
			case Opcode.SetPositionConst: SetPositionConst;
			case Opcode.SetVelocityConst: SetVelocityConst;
			default: throw error(value);
		}
	}

	final Break = 10;
	final CountDown;
	final Jump;
	final CountDownJump;
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
			case Jump: "jump";
			case CountDownJump: "count_down_jump";
			case PushInt: "push_int";
			case Decrement: "decrement";
			case SetPositionConst: "set_position_const";
			case SetVelocityConst: "set_velocity_const";
		}
	}

	/**
		Creates a `StatementType` instance that corresponds to `opcode`.
	**/
	public static inline function toStatementType(opcode: Opcode): StatementType {
		return switch opcode {
			case Break: [];
			case CountDown: [];
			case Jump: [Int];
			case CountDownJump: [Int];
			case PushInt: [Int];
			case Decrement: [];
			case SetPositionConst: [Vec];
			case SetVelocityConst: [Vec];
		}
	}

	/**
		@return The bytecode length in bytes required for a statement with `opcode`.
	**/
	public static inline function getBytecodeLength(opcode: Opcode): UInt
		return toStatementType(opcode).bytecodeLength();
}
