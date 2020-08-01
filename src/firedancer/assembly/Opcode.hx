package firedancer.assembly;

/**
	Value that specifies an operation to be performed.
**/
@:using(firedancer.assembly.Opcode.OpcodeExtension)
enum abstract Opcode(Int) to Int {
	public static extern inline final size = UInt.one;

	static function error(v: Int): String
		return 'Unknown opcode: $v';

	/**
		Converts `value` to `Opcode`.
		Throws error if `value` does not match any `Opcode` values.
	**/
	public static inline function from(value: Int): Opcode {
		return switch value {
			case Opcode.Break: Break;
			case Opcode.CountDownBreak: CountDownBreak;
			case Opcode.Jump: Jump;
			case Opcode.CountDownJump: CountDownJump;
			case Opcode.PushInt: PushInt;
			case Opcode.PeekFloat: PeekFloat;
			case Opcode.DropFloat: DropFloat;
			case Opcode.PeekVec: PeekVec;
			case Opcode.DropVec: DropVec;
			case Opcode.Decrement: Decrement;
			case Opcode.LoadFloatCV: LoadFloatCV;
			case Opcode.LoadVecCV: LoadVecCV;
			case Opcode.LoadVecXCV: LoadVecXCV;
			case Opcode.LoadVecYCV: LoadVecYCV;
			case Opcode.LoadTargetPositionV: LoadTargetPositionV;
			case Opcode.LoadTargetXV: LoadTargetXV;
			case Opcode.LoadTargetYV: LoadTargetYV;
			case Opcode.LoadBearingToTargetV: LoadBearingToTargetV;
			case Opcode.CastCartesianVV: CastCartesianVV;
			case Opcode.CastPolarVV: CastPolarVV;
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
			case Opcode.CalcRelativePositionVV: CalcRelativePositionVV;
			case Opcode.CalcRelativeVelocityVV: CalcRelativeVelocityVV;
			case Opcode.SetDistanceC: SetDistanceC;
			case Opcode.AddDistanceC: AddDistanceC;
			case Opcode.SetDistanceS: SetDistanceS;
			case Opcode.AddDistanceS: AddDistanceS;
			case Opcode.SetDistanceV: SetDistanceV;
			case Opcode.AddDistanceV: AddDistanceV;
			case Opcode.SetBearingC: SetBearingC;
			case Opcode.AddBearingC: AddBearingC;
			case Opcode.SetBearingS: SetBearingS;
			case Opcode.AddBearingS: AddBearingS;
			case Opcode.SetBearingV: SetBearingV;
			case Opcode.AddBearingV: AddBearingV;
			case Opcode.SetSpeedC: SetSpeedC;
			case Opcode.AddSpeedC: AddSpeedC;
			case Opcode.SetSpeedS: SetSpeedS;
			case Opcode.AddSpeedS: AddSpeedS;
			case Opcode.SetSpeedV: SetSpeedV;
			case Opcode.AddSpeedV: AddSpeedV;
			case Opcode.SetDirectionC: SetDirectionC;
			case Opcode.AddDirectionC: AddDirectionC;
			case Opcode.SetDirectionS: SetDirectionS;
			case Opcode.AddDirectionS: AddDirectionS;
			case Opcode.SetDirectionV: SetDirectionV;
			case Opcode.AddDirectionV: AddDirectionV;
			case Opcode.CalcRelativeDistanceCV: CalcRelativeDistanceCV;
			case Opcode.CalcRelativeBearingCV: CalcRelativeBearingCV;
			case Opcode.CalcRelativeSpeedCV: CalcRelativeSpeedCV;
			case Opcode.CalcRelativeDirectionCV: CalcRelativeDirectionCV;
			case Opcode.CalcRelativeDistanceVV: CalcRelativeDistanceVV;
			case Opcode.CalcRelativeBearingVV: CalcRelativeBearingVV;
			case Opcode.CalcRelativeSpeedVV: CalcRelativeSpeedVV;
			case Opcode.CalcRelativeDirectionVV: CalcRelativeDirectionVV;
			case Opcode.SetShotPositionC: SetShotPositionC;
			case Opcode.AddShotPositionC: AddShotPositionC;
			case Opcode.SetShotVelocityC: SetShotVelocityC;
			case Opcode.AddShotVelocityC: AddShotVelocityC;
			case Opcode.SetShotPositionS: SetShotPositionS;
			case Opcode.AddShotPositionS: AddShotPositionS;
			case Opcode.SetShotVelocityS: SetShotVelocityS;
			case Opcode.AddShotVelocityS: AddShotVelocityS;
			case Opcode.SetShotPositionV: SetShotPositionV;
			case Opcode.AddShotPositionV: AddShotPositionV;
			case Opcode.SetShotVelocityV: SetShotVelocityV;
			case Opcode.AddShotVelocityV: AddShotVelocityV;
			case Opcode.CalcRelativeShotPositionCV: CalcRelativeShotPositionCV;
			case Opcode.CalcRelativeShotVelocityCV: CalcRelativeShotVelocityCV;
			case Opcode.CalcRelativeShotPositionVV: CalcRelativeShotPositionVV;
			case Opcode.CalcRelativeShotVelocityVV: CalcRelativeShotVelocityVV;
			case Opcode.SetShotDistanceC: SetShotDistanceC;
			case Opcode.AddShotDistanceC: AddShotDistanceC;
			case Opcode.SetShotDistanceS: SetShotDistanceS;
			case Opcode.AddShotDistanceS: AddShotDistanceS;
			case Opcode.SetShotDistanceV: SetShotDistanceV;
			case Opcode.AddShotDistanceV: AddShotDistanceV;
			case Opcode.SetShotBearingC: SetShotBearingC;
			case Opcode.AddShotBearingC: AddShotBearingC;
			case Opcode.SetShotBearingS: SetShotBearingS;
			case Opcode.AddShotBearingS: AddShotBearingS;
			case Opcode.SetShotBearingV: SetShotBearingV;
			case Opcode.AddShotBearingV: AddShotBearingV;
			case Opcode.SetShotSpeedC: SetShotSpeedC;
			case Opcode.AddShotSpeedC: AddShotSpeedC;
			case Opcode.SetShotSpeedS: SetShotSpeedS;
			case Opcode.AddShotSpeedS: AddShotSpeedS;
			case Opcode.SetShotSpeedV: SetShotSpeedV;
			case Opcode.AddShotSpeedV: AddShotSpeedV;
			case Opcode.SetShotDirectionC: SetShotDirectionC;
			case Opcode.AddShotDirectionC: AddShotDirectionC;
			case Opcode.SetShotDirectionS: SetShotDirectionS;
			case Opcode.AddShotDirectionS: AddShotDirectionS;
			case Opcode.SetShotDirectionV: SetShotDirectionV;
			case Opcode.AddShotDirectionV: AddShotDirectionV;
			case Opcode.CalcRelativeShotDistanceCV: CalcRelativeShotDistanceCV;
			case Opcode.CalcRelativeShotBearingCV: CalcRelativeShotBearingCV;
			case Opcode.CalcRelativeShotSpeedCV: CalcRelativeShotSpeedCV;
			case Opcode.CalcRelativeShotDirectionCV: CalcRelativeShotDirectionCV;
			case Opcode.CalcRelativeShotDistanceVV: CalcRelativeShotDistanceVV;
			case Opcode.CalcRelativeShotBearingVV: CalcRelativeShotBearingVV;
			case Opcode.CalcRelativeShotSpeedVV: CalcRelativeShotSpeedVV;
			case Opcode.CalcRelativeShotDirectionVV: CalcRelativeShotDirectionVV;
			case Opcode.MultFloatVCS: MultFloatVCS;
			case Opcode.MultVecVCS: MultVecVCS;
			case Opcode.Fire: Fire;
			case Opcode.FireWithType: FireWithType;
			case Opcode.UseThread: UseThread;
			case Opcode.UseThreadS: UseThreadS;
			case Opcode.AwaitThread: AwaitThread;
			case Opcode.End: End;
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
		Reads a float at the stack top (skipping a given constant bytes from the top)
		and assigns it to the volatile float.
	**/
	final PeekFloat;

	/**
		Drops float from the stack top.
	**/
	final DropFloat;

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
		Assigns a given constant float to the current volatile float.
	**/
	final LoadFloatCV;

	/**
		Assigns given constant float values to the current volatile vector.
	**/
	final LoadVecCV;

	/**
		Assigns a given constant float to the x-component of the current volatile vector.
	**/
	final LoadVecXCV;

	/**
		Assigns a given constant float to the y-component of the current volatile vector.
	**/
	final LoadVecYCV;

	/**
		Multiplicates the current volatile float by a given constant float and pushes it to the stack top.
	**/
	final MultFloatVCS;

	/**
		Multiplicates the current volatile vector by a given constant float and pushes it to the stack top.
	**/
	final MultVecVCS;

	/**
		Assigns actor's target position to the volatile vector.
	**/
	final LoadTargetPositionV;

	/**
		Assigns the x-component of actor's target position to the x-component of the volatile vector.
	**/
	final LoadTargetXV;

	/**
		Assigns the y-component of actor's target position to the y-component of the volatile vector.
	**/
	final LoadTargetYV;

	/**
		Assigns the bearing angle from actor to target to the volatile float.
	**/
	final LoadBearingToTargetV;

	/**
		Interprets the last loaded volatile float values `(prev, cur)` as `(x, y)` and
		assigns them to the volatile vector.
	**/
	final CastCartesianVV;

	/**
		Interprets the last loaded volatile float values `(prev, cur)` as `(length, angle)` and
		assigns their cartesian representation to the volatile vector.
	**/
	final CastPolarVV;

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

	/**
		Converts the current volatile vector (which should be an absolute position)
		to a relative one from actor's current position and re-assigns it to the volatile vector.
	**/
	final CalcRelativePositionVV;

	/**
		Converts the current volatile vector (which should be an absolute velocity)
		to a relative one from actor's current velocity and re-assigns it to the volatile vector.
	**/
	final CalcRelativeVelocityVV;

	final SetDistanceC;
	final AddDistanceC;
	final SetDistanceS;
	final AddDistanceS;
	final SetDistanceV;
	final AddDistanceV;
	final SetBearingC;
	final AddBearingC;
	final SetBearingS;
	final AddBearingS;
	final SetBearingV;
	final AddBearingV;

	final SetSpeedC;
	final AddSpeedC;
	final SetSpeedS;
	final AddSpeedS;
	final SetSpeedV;
	final AddSpeedV;
	final SetDirectionC;
	final AddDirectionC;
	final SetDirectionS;
	final AddDirectionS;
	final SetDirectionV;
	final AddDirectionV;

	final CalcRelativeDistanceCV;
	final CalcRelativeBearingCV;
	final CalcRelativeSpeedCV;
	final CalcRelativeDirectionCV;

	final CalcRelativeDistanceVV;
	final CalcRelativeBearingVV;
	final CalcRelativeSpeedVV;
	final CalcRelativeDirectionVV;

	// ---- read/write/calc shot position/velocity ------------------------------

	/**
		Sets actor's shot position to a given constant vector.
	**/
	final SetShotPositionC;

	/**
		Adds a given constant vector to actor's shot position.
	**/
	final AddShotPositionC;

	/**
		Sets actor's shot velocity to a given constant vector.
	**/
	final SetShotVelocityC;

	/**
		Adds a given constant vector to actor's shot velocity.
	**/
	final AddShotVelocityC;

	/**
		Sets actor's shot position to the vector at the stack top.
	**/
	final SetShotPositionS;

	/**
		Adds the vector at the stack top to actor's shot position.
	**/
	final AddShotPositionS;

	/**
		Sets actor's shot velocity to the vector at the stack top.
	**/
	final SetShotVelocityS;

	/**
		Adds the vector at the stack top to actor's shot velocity.
	**/
	final AddShotVelocityS;

	/**
		Sets actor's shot position to the current volatile vector.
	**/
	final SetShotPositionV;

	/**
		Adds the current volatile vector to actor's shot position.
	**/
	final AddShotPositionV;

	/**
		Sets actor's shot velocity to the current volatile vector.
	**/
	final SetShotVelocityV;

	/**
		Adds the current volatile vector to actor's shot velocity.
	**/
	final AddShotVelocityV;

	/**
		Converts a given constant vector to a relative one from the current shot position
		and assigns it to the volatile vector.
	**/
	final CalcRelativeShotPositionCV;

	/**
		Converts a given constant vector to a relative one from the current shot velocity
		and assigns it to the volatile vector.
	**/
	final CalcRelativeShotVelocityCV;

	/**
		Converts the current volatile vector to a relative one from the current shot position
		and re-assigns it to the volatile vector.
	**/
	final CalcRelativeShotPositionVV;

	/**
		Converts the current volatile vector to a relative one from the current shot velocity
		and re-assigns it to the volatile vector.
	**/
	final CalcRelativeShotVelocityVV;

	final SetShotDistanceC;
	final AddShotDistanceC;
	final SetShotDistanceS;
	final AddShotDistanceS;
	final SetShotDistanceV;
	final AddShotDistanceV;
	final SetShotBearingC;
	final AddShotBearingC;
	final SetShotBearingS;
	final AddShotBearingS;
	final SetShotBearingV;
	final AddShotBearingV;

	final SetShotSpeedC;
	final AddShotSpeedC;
	final SetShotSpeedS;
	final AddShotSpeedS;
	final SetShotSpeedV;
	final AddShotSpeedV;
	final SetShotDirectionC;
	final AddShotDirectionC;
	final SetShotDirectionS;
	final AddShotDirectionS;
	final SetShotDirectionV;
	final AddShotDirectionV;

	final CalcRelativeShotDistanceCV;
	final CalcRelativeShotBearingCV;
	final CalcRelativeShotSpeedCV;
	final CalcRelativeShotDirectionCV;

	final CalcRelativeShotDistanceVV;
	final CalcRelativeShotBearingVV;
	final CalcRelativeShotSpeedVV;
	final CalcRelativeShotDirectionVV;

	// ---- other operations ----------------------------------------------------

	/**
		Emits a new actor with a default type.

		Argument:
		- (int) Bytecode ID, or any negative value to emit without bytecode
	**/
	final Fire;

	/**
		Emits a new actor with a specified type.

		Arguments:
		1. (int) Bytecode ID, or any negative value to emit without bytecode
		2. (int) Fire type
	**/
	final FireWithType;

	/**
		Activates a new thread with bytecode ID specified by a given constant integer.
	**/
	final UseThread;

	/**
		Activates a new thread with bytecode ID specified by a given constant integer,
		then pushes the thread ID to the stack.
	**/
	final UseThreadS;

	/**
		Peeks the top integer (which should be a thread ID) from the stack
		and checks if the thread is currently active.
		- If active, breaks the current frame.
		  The next frame will begin with this `AwaitThread` opcode again.
		- If not active, drops the thread ID from the stack and goes to next.
	**/
	final AwaitThread;

	/**
		Ends running bytecode and returns an end code specified by a given constant integer.
	**/
	final End;

	public extern inline function int(): Int
		return this;
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
			case PeekFloat: "peek_float";
			case DropFloat: "drop_float";
			case PeekVec: "peek_vec";
			case DropVec: "drop_vec";
			case Decrement: "decrement";
			case LoadFloatCV: "load_float_cv";
			case LoadVecCV: "load_vec_cv";
			case LoadVecXCV: "load_vec_x_cv";
			case LoadVecYCV: "load_vec_y_cv";
			case LoadTargetPositionV: "load_target_position_v";
			case LoadTargetXV: "load_target_x_v";
			case LoadTargetYV: "load_target_y_v";
			case LoadBearingToTargetV: "load_bearing_to_target_v";
			case CastCartesianVV: "cast_cartesian_vv";
			case CastPolarVV: "cast_polar_vv";
			case SetPositionC: "set_position_c";
			case AddPositionC: "add_position_c";
			case SetVelocityC: "set_velocity_c";
			case AddVelocityC: "add_velocity_c";
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
			case CalcRelativePositionVV: "calc_rel_position_vv";
			case CalcRelativeVelocityVV: "calc_rel_velocity_vv";
			case SetDistanceC: "set_distance_c";
			case AddDistanceC: "add_distance_c";
			case SetDistanceS: "set_distance_s";
			case AddDistanceS: "add_distance_s";
			case SetDistanceV: "set_distance_v";
			case AddDistanceV: "add_distance_v";
			case SetBearingC: "set_bearing_c";
			case AddBearingC: "add_bearing_c";
			case SetBearingS: "set_bearing_s";
			case AddBearingS: "add_bearing_s";
			case SetBearingV: "set_bearing_v";
			case AddBearingV: "add_bearing_v";
			case SetSpeedC: "set_speed_c";
			case AddSpeedC: "add_speed_c";
			case SetSpeedS: "set_speed_s";
			case AddSpeedS: "add_speed_s";
			case SetSpeedV: "set_speed_v";
			case AddSpeedV: "add_speed_v";
			case SetDirectionC: "set_direction_c";
			case AddDirectionC: "add_direction_c";
			case SetDirectionS: "set_direction_s";
			case AddDirectionS: "add_direction_s";
			case SetDirectionV: "set_direction_v";
			case AddDirectionV: "add_direction_v";
			case CalcRelativeDistanceCV: "calc_rel_distance_cv";
			case CalcRelativeBearingCV: "calc_rel_bearing_cv";
			case CalcRelativeSpeedCV: "calc_rel_speed_cv";
			case CalcRelativeDirectionCV: "calc_rel_direction_cv";
			case CalcRelativeDistanceVV: "calc_rel_distance_vv";
			case CalcRelativeBearingVV: "calc_rel_bearing_vv";
			case CalcRelativeSpeedVV: "calc_rel_speed_vv";
			case CalcRelativeDirectionVV: "calc_rel_direction_vv";
			case SetShotPositionC: "set_shot_position_c";
			case AddShotPositionC: "add_shot_position_c";
			case SetShotVelocityC: "set_shot_velocity_c";
			case AddShotVelocityC: "add_shot_velocity_c";
			case SetShotPositionS: "set_shot_position_s";
			case AddShotPositionS: "add_shot_position_s";
			case SetShotVelocityS: "set_shot_velocity_s";
			case AddShotVelocityS: "add_shot_velocity_s";
			case SetShotPositionV: "set_shot_position_v";
			case AddShotPositionV: "add_shot_position_v";
			case SetShotVelocityV: "set_shot_velocity_v";
			case AddShotVelocityV: "add_shot_velocity_v";
			case CalcRelativeShotPositionCV: "calc_rel_shot_position_cv";
			case CalcRelativeShotVelocityCV: "calc_rel_shot_velocity_cv";
			case CalcRelativeShotPositionVV: "calc_rel_shot_position_vv";
			case CalcRelativeShotVelocityVV: "calc_rel_shot_velocity_vv";
			case SetShotDistanceC: "set_shot_distance_c";
			case AddShotDistanceC: "add_shot_distance_c";
			case SetShotDistanceS: "set_shot_distance_s";
			case AddShotDistanceS: "add_shot_distance_s";
			case SetShotDistanceV: "set_shot_distance_v";
			case AddShotDistanceV: "add_shot_distance_v";
			case SetShotBearingC: "set_shot_bearing_c";
			case AddShotBearingC: "add_shot_bearing_c";
			case SetShotBearingS: "set_shot_bearing_s";
			case AddShotBearingS: "add_shot_bearing_s";
			case SetShotBearingV: "set_shot_bearing_v";
			case AddShotBearingV: "add_shot_bearing_v";
			case SetShotSpeedC: "set_shot_speed_c";
			case AddShotSpeedC: "add_shot_speed_c";
			case SetShotSpeedS: "set_shot_speed_s";
			case AddShotSpeedS: "add_shot_speed_s";
			case SetShotSpeedV: "set_shot_speed_v";
			case AddShotSpeedV: "add_shot_speed_v";
			case SetShotDirectionC: "set_shot_direction_c";
			case AddShotDirectionC: "add_shot_direction_c";
			case SetShotDirectionS: "set_shot_direction_s";
			case AddShotDirectionS: "add_shot_direction_s";
			case SetShotDirectionV: "set_shot_direction_v";
			case AddShotDirectionV: "add_shot_direction_v";
			case CalcRelativeShotDistanceCV: "calc_rel_shot_distance_cv";
			case CalcRelativeShotBearingCV: "calc_rel_shot_bearing_cv";
			case CalcRelativeShotSpeedCV: "calc_rel_shot_speed_cv";
			case CalcRelativeShotDirectionCV: "calc_rel_shot_direction_cv";
			case CalcRelativeShotDistanceVV: "calc_rel_distance_vv";
			case CalcRelativeShotBearingVV: "calc_rel_bearing_vv";
			case CalcRelativeShotSpeedVV: "calc_rel_speed_vv";
			case CalcRelativeShotDirectionVV: "calc_rel_direction_vv";
			case MultFloatVCS: "mult_float_vcs";
			case MultVecVCS: "mult_vec_vcs";
			case Fire: "fire";
			case FireWithType: "fire_with_type";
			case UseThread: "use_thread";
			case UseThreadS: "use_thread_s";
			case AwaitThread: "await_thread";
			case End: "end";
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
			case PeekFloat | PeekVec: [Int]; // bytes to be skipped from the stack top
			case DropFloat | DropVec: [];
			case Decrement: [];
			case LoadFloatCV: [Float];
			case LoadVecCV: [Vec];
			case LoadVecXCV | LoadVecYCV: [Float];
			case LoadTargetPositionV | LoadTargetXV | LoadTargetYV: [];
			case LoadBearingToTargetV: [];
			case CastCartesianVV | CastPolarVV: [];
			case SetPositionC | AddPositionC | SetVelocityC | AddVelocityC: [Vec];
			case SetPositionS | AddPositionS | SetVelocityS | AddVelocityS: [];
			case SetPositionV | AddPositionV | SetVelocityV | AddVelocityV: [];
			case CalcRelativePositionCV | CalcRelativeVelocityCV: [Vec]; // vector before calc
			case CalcRelativePositionVV | CalcRelativeVelocityVV: [];
			case SetDistanceC | AddDistanceC | SetBearingC | AddBearingC: [Float];
			case SetSpeedC | AddSpeedC | SetDirectionC | AddDirectionC: [Float];
			case SetDistanceS | AddDistanceS | SetBearingS | AddBearingS: [];
			case SetSpeedS | AddSpeedS | SetDirectionS | AddDirectionS: [];
			case SetDistanceV | AddDistanceV | SetBearingV | AddBearingV: [];
			case SetSpeedV | AddSpeedV | SetDirectionV | AddDirectionV: [];
			case CalcRelativeDistanceCV | CalcRelativeBearingCV: [Float]; // value before calc
			case CalcRelativeSpeedCV | CalcRelativeDirectionCV: [Float]; // value before calc
			case CalcRelativeDistanceVV | CalcRelativeBearingVV: [];
			case CalcRelativeSpeedVV | CalcRelativeDirectionVV: [];
			case SetShotPositionC | AddShotPositionC | SetShotVelocityC | AddShotVelocityC: [Vec];
			case SetShotPositionS | AddShotPositionS | SetShotVelocityS | AddShotVelocityS: [];
			case SetShotPositionV | AddShotPositionV | SetShotVelocityV | AddShotVelocityV: [];
			case CalcRelativeShotPositionCV | CalcRelativeShotVelocityCV: [Vec]; // vector before calc
			case CalcRelativeShotPositionVV | CalcRelativeShotVelocityVV: [];
			case SetShotDistanceC | AddShotDistanceC | SetShotBearingC | AddShotBearingC: [Float];
			case SetShotSpeedC | AddShotSpeedC | SetShotDirectionC | AddShotDirectionC: [Float];
			case SetShotDistanceS | AddShotDistanceS | SetShotBearingS | AddShotBearingS: [];
			case SetShotSpeedS | AddShotSpeedS | SetShotDirectionS | AddShotDirectionS: [];
			case SetShotDistanceV | AddShotDistanceV | SetShotBearingV | AddShotBearingV: [];
			case SetShotSpeedV | AddShotSpeedV | SetShotDirectionV | AddShotDirectionV: [];
			case CalcRelativeShotDistanceCV | CalcRelativeShotBearingCV: [Float]; // value before calc
			case CalcRelativeShotSpeedCV | CalcRelativeShotDirectionCV: [Float]; // value before calc
			case CalcRelativeShotDistanceVV | CalcRelativeShotBearingVV: [];
			case CalcRelativeShotSpeedVV | CalcRelativeShotDirectionVV: [];
			case MultFloatVCS | MultVecVCS: [Float]; // multiplier value
			case Fire: [Int]; // bytecode ID or negative for null
			case FireWithType: [Int, Int]; // 1. bytecode ID or negative for null, 2. Fire type
			case UseThread | UseThreadS: [Int]; // bytecode ID
			case AwaitThread: [];
			case End: [Int]; // end code
		}
	}

	/**
		@return The bytecode length in bytes required for a statement with `opcode`.
	**/
	public static inline function getBytecodeLength(opcode: Opcode): UInt
		return toStatementType(opcode).bytecodeLength();
}
