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
		case ReadOperation.LoadTargetPositionR: LoadTargetPositionR;
		case ReadOperation.LoadTargetXR: LoadTargetXR;
		case ReadOperation.LoadTargetYR: LoadTargetYR;
		case ReadOperation.LoadBearingToTargetR: LoadBearingToTargetR;
		case ReadOperation.CalcRelativePositionCR: CalcRelativePositionCR;
		case ReadOperation.CalcRelativeVelocityCR: CalcRelativeVelocityCR;
		case ReadOperation.CalcRelativePositionRR: CalcRelativePositionRR;
		case ReadOperation.CalcRelativeVelocityRR: CalcRelativeVelocityRR;
		case ReadOperation.CalcRelativeDistanceCR: CalcRelativeDistanceCR;
		case ReadOperation.CalcRelativeBearingCR: CalcRelativeBearingCR;
		case ReadOperation.CalcRelativeSpeedCR: CalcRelativeSpeedCR;
		case ReadOperation.CalcRelativeDirectionCR: CalcRelativeDirectionCR;
		case ReadOperation.CalcRelativeDistanceRR: CalcRelativeDistanceRR;
		case ReadOperation.CalcRelativeBearingRR: CalcRelativeBearingRR;
		case ReadOperation.CalcRelativeSpeedRR: CalcRelativeSpeedRR;
		case ReadOperation.CalcRelativeDirectionRR: CalcRelativeDirectionRR;
		case ReadOperation.CalcRelativeShotPositionCR: CalcRelativeShotPositionCR;
		case ReadOperation.CalcRelativeShotVelocityCR: CalcRelativeShotVelocityCR;
		case ReadOperation.CalcRelativeShotPositionRR: CalcRelativeShotPositionRR;
		case ReadOperation.CalcRelativeShotVelocityRR: CalcRelativeShotVelocityRR;
		case ReadOperation.CalcRelativeShotDistanceCR: CalcRelativeShotDistanceCR;
		case ReadOperation.CalcRelativeShotBearingCR: CalcRelativeShotBearingCR;
		case ReadOperation.CalcRelativeShotSpeedCR: CalcRelativeShotSpeedCR;
		case ReadOperation.CalcRelativeShotDirectionCR: CalcRelativeShotDirectionCR;
		case ReadOperation.CalcRelativeShotDistanceRR: CalcRelativeShotDistanceRR;
		case ReadOperation.CalcRelativeShotBearingRR: CalcRelativeShotBearingRR;
		case ReadOperation.CalcRelativeShotSpeedRR: CalcRelativeShotSpeedRR;
		case ReadOperation.CalcRelativeShotDirectionRR: CalcRelativeShotDirectionRR;
		default: throw error(value);
		}
	}

	// ---- read actor data

	/**
		(target position) -> (vec register)
	**/
	final LoadTargetPositionR;

	/**
		(target x) -> (float register)
	**/
	final LoadTargetXR;

	/**
		(target y) -> (float register)
	**/
	final LoadTargetYR;

	/**
		(bearing from actor to target) -> (float register)
	**/
	final LoadBearingToTargetR;

	/**
		(vec immediate) - (position) ->  (vec register)
	**/
	final CalcRelativePositionCR;

	/**
		(vec immediate) - (velocity) -> (vec register)
	**/
	final CalcRelativeVelocityCR;

	/**
		(vec register) - (position) -> (vec register)
	**/
	final CalcRelativePositionRR;

	/**
		(vec register) - (velocity) -> (vec register)
	**/
	final CalcRelativeVelocityRR;

	/**
		(float immediate) - (distance) -> (float register)
	**/
	final CalcRelativeDistanceCR;

	/**
		(float immediate) - (bearing) -> (float register)
	**/
	final CalcRelativeBearingCR;

	/**
		(float immediate) - (speed) -> (float register)
	**/
	final CalcRelativeSpeedCR;

	/**
		(float immediate) - (direction) -> (float register)
	**/
	final CalcRelativeDirectionCR;

	/**
		(float register) - (distance) -> (float register)
	**/
	final CalcRelativeDistanceRR;

	/**
		(float register) - (bearing) -> (float register)
	**/
	final CalcRelativeBearingRR;

	/**
		(float register) - (speed) -> (float register)
	**/
	final CalcRelativeSpeedRR;

	/**
		(float register) - (direction) -> (float register)
	**/
	final CalcRelativeDirectionRR;

	/**
		(vec immediate) - (shot position) -> (vec register)
	**/
	final CalcRelativeShotPositionCR;

	/**
		(vec immediate) - (shot velocity) -> (vec register)
	**/
	final CalcRelativeShotVelocityCR;

	/**
		(vec register) - (shot position) -> (vec register)
	**/
	final CalcRelativeShotPositionRR;

	/**
		(vec register) - (shot velocity) -> (vec register)
	**/
	final CalcRelativeShotVelocityRR;

	/**
		(float immediate) - (shot distance) -> (float register)
	**/
	final CalcRelativeShotDistanceCR;

	/**
		(float immediate) - (shot bearing) -> (float register)
	**/
	final CalcRelativeShotBearingCR;

	/**
		(float immediate) - (shot speed) -> (float register)
	**/
	final CalcRelativeShotSpeedCR;

	/**
		(float immediate) - (shot direction) -> (float register)
	**/
	final CalcRelativeShotDirectionCR;

	/**
		(float register) - (shot distance) -> (float register)
	**/
	final CalcRelativeShotDistanceRR;

	/**
		(float register) - (shot bearing) -> (float register)
	**/
	final CalcRelativeShotBearingRR;

	/**
		(float register) - (shot speed) -> (float register)
	**/
	final CalcRelativeShotSpeedRR;

	/**
		(float register) - (shot direction) -> (float register)
	**/
	final CalcRelativeShotDirectionRR;

	public extern inline function int(): Int
		return this;
}

class ReadOperationExtension {
	/**
		@return The mnemonic for `code`.
	**/
	public static inline function toString(code: ReadOperation): String {
		return switch code {
		case LoadTargetPositionR: "load_target_position_r";
		case LoadTargetXR: "load_target_x_r";
		case LoadTargetYR: "load_target_y_r";
		case LoadBearingToTargetR: "load_bearing_to_target_r";
		case CalcRelativePositionCR: "calc_rel_position_cr";
		case CalcRelativeVelocityCR: "calc_rel_velocity_cr";
		case CalcRelativePositionRR: "calc_rel_position_rr";
		case CalcRelativeVelocityRR: "calc_rel_velocity_rr";
		case CalcRelativeDistanceCR: "calc_rel_distance_cr";
		case CalcRelativeBearingCR: "calc_rel_bearing_cr";
		case CalcRelativeSpeedCR: "calc_rel_speed_cr";
		case CalcRelativeDirectionCR: "calc_rel_direction_cr";
		case CalcRelativeDistanceRR: "calc_rel_distance_rr";
		case CalcRelativeBearingRR: "calc_rel_bearing_rr";
		case CalcRelativeSpeedRR: "calc_rel_speed_rr";
		case CalcRelativeDirectionRR: "calc_rel_direction_rr";
		case CalcRelativeShotPositionCR: "calc_rel_shot_position_cr";
		case CalcRelativeShotVelocityCR: "calc_rel_shot_velocity_cr";
		case CalcRelativeShotPositionRR: "calc_rel_shot_position_rr";
		case CalcRelativeShotVelocityRR: "calc_rel_shot_velocity_rr";
		case CalcRelativeShotDistanceCR: "calc_rel_shot_distance_cr";
		case CalcRelativeShotBearingCR: "calc_rel_shot_bearing_cr";
		case CalcRelativeShotSpeedCR: "calc_rel_shot_speed_cr";
		case CalcRelativeShotDirectionCR: "calc_rel_shot_direction_cr";
		case CalcRelativeShotDistanceRR: "calc_rel_distance_rr";
		case CalcRelativeShotBearingRR: "calc_rel_bearing_rr";
		case CalcRelativeShotSpeedRR: "calc_rel_speed_rr";
		case CalcRelativeShotDirectionRR: "calc_rel_direction_rr";
		}
	}
}
