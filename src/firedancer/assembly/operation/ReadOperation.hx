package firedancer.assembly.operation;

/**
	Value that specifies an operation to be performed.
**/
@:using(firedancer.assembly.operation.ReadOperation.ReadOperationExtension)
enum abstract ReadOperation(Int) to Int {
	static function error(v: Int): String
		return 'Unknown read operation: $v';

	/**
		Converts `value` to `ReadOperation`.
		Throws error if `value` does not match any `ReadOperation` values.
	**/
	public static inline function from(value: Int): ReadOperation {
		return switch value {
			case ReadOperation.LoadTargetPositionV: LoadTargetPositionV;
			case ReadOperation.LoadTargetXV: LoadTargetXV;
			case ReadOperation.LoadTargetYV: LoadTargetYV;
			case ReadOperation.LoadBearingToTargetV: LoadBearingToTargetV;
			case ReadOperation.CalcRelativePositionCV: CalcRelativePositionCV;
			case ReadOperation.CalcRelativeVelocityCV: CalcRelativeVelocityCV;
			case ReadOperation.CalcRelativePositionVV: CalcRelativePositionVV;
			case ReadOperation.CalcRelativeVelocityVV: CalcRelativeVelocityVV;
			case ReadOperation.CalcRelativeDistanceCV: CalcRelativeDistanceCV;
			case ReadOperation.CalcRelativeBearingCV: CalcRelativeBearingCV;
			case ReadOperation.CalcRelativeSpeedCV: CalcRelativeSpeedCV;
			case ReadOperation.CalcRelativeDirectionCV: CalcRelativeDirectionCV;
			case ReadOperation.CalcRelativeDistanceVV: CalcRelativeDistanceVV;
			case ReadOperation.CalcRelativeBearingVV: CalcRelativeBearingVV;
			case ReadOperation.CalcRelativeSpeedVV: CalcRelativeSpeedVV;
			case ReadOperation.CalcRelativeDirectionVV: CalcRelativeDirectionVV;
			case ReadOperation.CalcRelativeShotPositionCV: CalcRelativeShotPositionCV;
			case ReadOperation.CalcRelativeShotVelocityCV: CalcRelativeShotVelocityCV;
			case ReadOperation.CalcRelativeShotPositionVV: CalcRelativeShotPositionVV;
			case ReadOperation.CalcRelativeShotVelocityVV: CalcRelativeShotVelocityVV;
			case ReadOperation.CalcRelativeShotDistanceCV: CalcRelativeShotDistanceCV;
			case ReadOperation.CalcRelativeShotBearingCV: CalcRelativeShotBearingCV;
			case ReadOperation.CalcRelativeShotSpeedCV: CalcRelativeShotSpeedCV;
			case ReadOperation.CalcRelativeShotDirectionCV: CalcRelativeShotDirectionCV;
			case ReadOperation.CalcRelativeShotDistanceVV: CalcRelativeShotDistanceVV;
			case ReadOperation.CalcRelativeShotBearingVV: CalcRelativeShotBearingVV;
			case ReadOperation.CalcRelativeShotSpeedVV: CalcRelativeShotSpeedVV;
			case ReadOperation.CalcRelativeShotDirectionVV: CalcRelativeShotDirectionVV;
			default: throw error(value);
		}
	}

	// ---- read actor data

	/**
		Assigns actor's target position to the volatile vector.
	**/
	final LoadTargetPositionV;

	/**
		Assigns the x-component of actor's target position to the volatile float.
	**/
	final LoadTargetXV;

	/**
		Assigns the y-component of actor's target position to the volatile float.
	**/
	final LoadTargetYV;

	/**
		Assigns the bearing angle from actor to target to the volatile float.
	**/
	final LoadBearingToTargetV;

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

	final CalcRelativeDistanceCV;
	final CalcRelativeBearingCV;
	final CalcRelativeSpeedCV;
	final CalcRelativeDirectionCV;
	final CalcRelativeDistanceVV;
	final CalcRelativeBearingVV;
	final CalcRelativeSpeedVV;
	final CalcRelativeDirectionVV;

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

	final CalcRelativeShotDistanceCV;
	final CalcRelativeShotBearingCV;
	final CalcRelativeShotSpeedCV;
	final CalcRelativeShotDirectionCV;
	final CalcRelativeShotDistanceVV;
	final CalcRelativeShotBearingVV;
	final CalcRelativeShotSpeedVV;
	final CalcRelativeShotDirectionVV;
	public extern inline function int(): Int
		return this;
}

class ReadOperationExtension {
	/**
		@return The mnemonic for `code`.
	**/
	public static inline function toString(code: ReadOperation): String {
		return switch code {
			case LoadTargetPositionV: "load_target_position_v";
			case LoadTargetXV: "load_target_x_v";
			case LoadTargetYV: "load_target_y_v";
			case LoadBearingToTargetV: "load_bearing_to_target_v";
			case CalcRelativePositionCV: "calc_rel_position_cv";
			case CalcRelativeVelocityCV: "calc_rel_velocity_cv";
			case CalcRelativePositionVV: "calc_rel_position_vv";
			case CalcRelativeVelocityVV: "calc_rel_velocity_vv";
			case CalcRelativeDistanceCV: "calc_rel_distance_cv";
			case CalcRelativeBearingCV: "calc_rel_bearing_cv";
			case CalcRelativeSpeedCV: "calc_rel_speed_cv";
			case CalcRelativeDirectionCV: "calc_rel_direction_cv";
			case CalcRelativeDistanceVV: "calc_rel_distance_vv";
			case CalcRelativeBearingVV: "calc_rel_bearing_vv";
			case CalcRelativeSpeedVV: "calc_rel_speed_vv";
			case CalcRelativeDirectionVV: "calc_rel_direction_vv";
			case CalcRelativeShotPositionCV: "calc_rel_shot_position_cv";
			case CalcRelativeShotVelocityCV: "calc_rel_shot_velocity_cv";
			case CalcRelativeShotPositionVV: "calc_rel_shot_position_vv";
			case CalcRelativeShotVelocityVV: "calc_rel_shot_velocity_vv";
			case CalcRelativeShotDistanceCV: "calc_rel_shot_distance_cv";
			case CalcRelativeShotBearingCV: "calc_rel_shot_bearing_cv";
			case CalcRelativeShotSpeedCV: "calc_rel_shot_speed_cv";
			case CalcRelativeShotDirectionCV: "calc_rel_shot_direction_cv";
			case CalcRelativeShotDistanceVV: "calc_rel_distance_vv";
			case CalcRelativeShotBearingVV: "calc_rel_bearing_vv";
			case CalcRelativeShotSpeedVV: "calc_rel_speed_vv";
			case CalcRelativeShotDirectionVV: "calc_rel_direction_vv";
		}
	}

	/**
		Creates a `InstructionType` instance that corresponds to `op`.
	**/
	public static inline function toInstructionType(op: ReadOperation): InstructionType {
		return switch op {
			case LoadTargetPositionV | LoadTargetXV | LoadTargetYV: [];
			case LoadBearingToTargetV: [];
			case CalcRelativePositionCV | CalcRelativeVelocityCV: [Vec]; // vector before calc
			case CalcRelativePositionVV | CalcRelativeVelocityVV: [];
			case CalcRelativeDistanceCV | CalcRelativeBearingCV: [Float]; // value before calc
			case CalcRelativeSpeedCV | CalcRelativeDirectionCV: [Float]; // value before calc
			case CalcRelativeDistanceVV | CalcRelativeBearingVV: [];
			case CalcRelativeSpeedVV | CalcRelativeDirectionVV: [];
			case CalcRelativeShotPositionCV | CalcRelativeShotVelocityCV: [Vec]; // vector before calc
			case CalcRelativeShotPositionVV | CalcRelativeShotVelocityVV: [];
			case CalcRelativeShotDistanceCV | CalcRelativeShotBearingCV: [Float]; // value before calc
			case CalcRelativeShotSpeedCV | CalcRelativeShotDirectionCV: [Float]; // value before calc
			case CalcRelativeShotDistanceVV | CalcRelativeShotBearingVV: [];
			case CalcRelativeShotSpeedVV | CalcRelativeShotDirectionVV: [];
		}
	}

	/**
		@return The bytecode length in bytes required for an instruction with `op`.
	**/
	public static inline function getBytecodeLength(op: ReadOperation): UInt
		return toInstructionType(op).bytecodeLength();
}
