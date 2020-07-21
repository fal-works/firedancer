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
			case Opcode.PeekVec: PeekVec;
			case Opcode.DropVec: DropVec;
			case Opcode.Decrement: Decrement;
			case Opcode.SetPositionC: SetPositionC;
			case Opcode.AddPositionC: AddPositionC;
			case Opcode.SetVelocityC: SetVelocityC;
			case Opcode.AddVelocityC: AddVelocityC;
			case Opcode.SetPositionS: SetPositionS;
			case Opcode.AddPositionS: AddPositionS;
			case Opcode.SetVelocityS: SetVelocityS;
			case Opcode.AddVelocityS: AddVelocityS;
			case Opcode.SetPositionV: SetPositionV;
			case Opcode.AddPositionV: AddPositionV;
			case Opcode.SetVelocityV: SetVelocityV;
			case Opcode.AddVelocityV: AddVelocityV;
			case Opcode.CalcRelativePositionCV: CalcRelativePositionCV;
			case Opcode.CalcRelativeVelocityCV: CalcRelativeVelocityCV;
			case Opcode.MultVecVCS: MultVecVCS;
			default: throw error(value);
		}
	}

	final Break = 10;
	final CountDown;
	final Jump;
	final CountDownJump;
	final PushInt = 20;
	final PeekVec;
	final DropVec;
	final Decrement = 30;
	final SetPositionC = 50;
	final AddPositionC;
	final SetVelocityC;
	final AddVelocityC;
	final SetPositionS;
	final AddPositionS;
	final SetVelocityS;
	final AddVelocityS;
	final SetPositionV;
	final AddPositionV;
	final SetVelocityV;
	final AddVelocityV;
	final CalcRelativePositionCV = 70;
	final CalcRelativeVelocityCV;
	final MultVecVCS;
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
			case PeekVec: "peek_vec";
			case DropVec: "drop_vec";
			case Decrement: "decrement";
			case SetPositionC: "set_position_c";
			case AddPositionC: "add_position_c";
			case SetVelocityC: "set_velocity_c";
			case AddVelocityC: "set_velocity_c";
			case SetPositionS: "set_position_s";
			case AddPositionS: "add_position_s";
			case SetVelocityS: "set_velocity_s";
			case AddVelocityS: "add_velocity_s";
			case SetPositionV: "set_position_v";
			case AddPositionV: "add_position_v";
			case SetVelocityV: "set_velocity_v";
			case AddVelocityV: "add_velocity_v";
			case CalcRelativePositionCV: "calc_rel_position_cv";
			case CalcRelativeVelocityCV: "calc_rel_velocity_cv";
			case MultVecVCS: "mult_vec_vcs";
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
			case PeekVec: [Int]; // operand: bytes to be skipped from the stack top
			case DropVec: [];
			case Decrement: [];
			case SetPositionC | AddPositionC | SetVelocityC | AddVelocityC: [Vec];
			case SetPositionS | AddPositionS | SetVelocityS | AddVelocityS: [];
			case SetPositionV | AddPositionV | SetVelocityV | AddVelocityV: [];
			case CalcRelativePositionCV | CalcRelativeVelocityCV: [Vec];
			case MultVecVCS: [Float];
		}
	}

	/**
		@return The bytecode length in bytes required for a statement with `opcode`.
	**/
	public static inline function getBytecodeLength(opcode: Opcode): UInt
		return toStatementType(opcode).bytecodeLength();
}

/**
	Subset of `Opcode` related to position/velocity operation with constant values.
**/
enum abstract OpcodeOperateVectorC(Opcode) to Opcode {
	final SetPositionC = Opcode.SetPositionC;
	final AddPositionC = Opcode.AddPositionC;
	final SetVelocityC = Opcode.SetVelocityC;
	final AddVelocityC = Opcode.AddVelocityC;
}

/**
	Subset of `Opcode` related to position/velocity operation with stacked values.
**/
enum abstract OpcodeOperateVectorS(Opcode) to Opcode {
	final SetPositionS = Opcode.SetPositionS;
	final AddPositionS = Opcode.AddPositionS;
	final SetVelocityS = Opcode.SetVelocityS;
	final AddVelocityS = Opcode.AddVelocityS;
}

/**
	Subset of `Opcode` related to position/velocity operation with volatile values.
**/
enum abstract OpcodeOperateVectorV(Opcode) to Opcode {
	final SetPositionV = Opcode.SetPositionV;
	final AddPositionV = Opcode.AddPositionV;
	final SetVelocityV = Opcode.SetVelocityV;
	final AddVelocityV = Opcode.AddVelocityV;
}
