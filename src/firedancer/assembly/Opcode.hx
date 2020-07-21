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
			case Opcode.CountDownBreak: CountDownBreak;
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
			case Opcode.Fire: Fire;
			default: throw error(value);
		}
	}

	// ---- control flow --------------------------------------------------------

	/**
		Breaks the current frame.
	**/
	final Break = 1;

	/**
		Peeks the top integer (which should be the remaining loop count) from the stack
		and checks if it is zero.
		- If not zero, decrements the loop counter at the stack top and breaks the current frame.
		  The next frame will begin with this `CountDownBreak` opcode again.
		- If zero, drops the loop counter from the stack and goes to next.
	**/
	final CountDownBreak;

	/**
		Adds a given constant value to the current bytecode position.
	**/
	final Jump;

	/**
		Peeks the top integer (which should be the remaining loop count) from the stack
		and checks if it is zero.
		- If not zero, decrements the loop counter at the stack top and goes to next.
		- If zero, drops the loop counter from the stack and
			adds a given constant value to the current bytecode position.
	**/
	final CountDownJump;

	// ---- read/write/calc values ----------------------------------------------

	/**
		Pushes a given constant integer to the stack top.
	**/
	final PushInt;

	/**
		Reads a vector at the stack top (skipping a given constant bytes from the top)
		and assigns it to the volatile vector.
	**/
	final PeekVec;

	/**
		Drops vector from the stack top.
	**/
	final DropVec;

	/**
		Decrements the integer at the stack top.
	**/
	final Decrement;

	/**
		Multiplicates the current volatile vector by a given constant float and pushes it to the stack top.
	**/
	final MultVecVCS;

	// ---- read/write/calc actor data ------------------------------------------

	/**
		Sets actor's position to a given constant vector.
	**/
	final SetPositionC;

	/**
		Adds a given constant vector to actor's position.
	**/
	final AddPositionC;

	/**
		Sets actor's velocity to a given constant vector.
	**/
	final SetVelocityC;

	/**
		Adds a given constant vector to actor's velocity.
	**/
	final AddVelocityC;

	/**
		Sets actor's position to the vector at the stack top.
	**/
	final SetPositionS;

	/**
		Adds the vector at the stack top to actor's position.
	**/
	final AddPositionS;

	/**
		Sets actor's velocity to the vector at the stack top.
	**/
	final SetVelocityS;

	/**
		Adds the vector at the stack top to actor's velocity.
	**/
	final AddVelocityS;

	/**
		Sets actor's position to the current volatile vector.
	**/
	final SetPositionV;

	/**
		Adds the current volatile vector to actor's position.
	**/
	final AddPositionV;

	/**
		Sets actor's velocity to the current volatile vector.
	**/
	final SetVelocityV;

	/**
		Adds the current volatile vector to actor's velocity.
	**/
	final AddVelocityV;

	/**
		Converts a given constant vector (which should be an absolute position)
		to a relative one from actor's current position and assigns it to the volatile vector.
	**/
	final CalcRelativePositionCV;

	/**
		Converts a given constant vector (which should be an absolute velocity)
		to a relative one from actor's current velocity and assigns it to the volatile vector.
	**/
	final CalcRelativeVelocityCV;

	// ---- other operations ----------------------------------------------------

	final Fire;
}

class OpcodeExtension {
	/**
		@return The mnemonic for `code`.
	**/
	public static inline function toString(code: Opcode): String {
		return switch code {
			case Break: "break";
			case CountDownBreak: "count_down_break";
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
			case Fire: "fire";
		}
	}

	/**
		Creates a `StatementType` instance that corresponds to `opcode`.
	**/
	public static inline function toStatementType(opcode: Opcode): StatementType {
		return switch opcode {
			case Break: [];
			case CountDownBreak: [];
			case Jump: [Int]; // bytecode length to jump
			case CountDownJump: [Int]; // bytecode length to jump
			case PushInt: [Int]; // integer to push
			case PeekVec: [Int]; // bytes to be skipped from the stack top
			case DropVec: [];
			case Decrement: [];
			case SetPositionC | AddPositionC | SetVelocityC | AddVelocityC: [Vec];
			case SetPositionS | AddPositionS | SetVelocityS | AddVelocityS: [];
			case SetPositionV | AddPositionV | SetVelocityV | AddVelocityV: [];
			case CalcRelativePositionCV | CalcRelativeVelocityCV: [Vec]; // absolute vector
			case MultVecVCS: [Float]; // multiplier value
			case Fire: [Int]; // bytecode ID
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
