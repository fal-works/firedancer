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
		case ReadOperation.LoadPositionR: LoadPositionR;
		case ReadOperation.LoadDistanceR: LoadDistanceR;
		case ReadOperation.LoadBearingR: LoadBearingR;
		case ReadOperation.LoadVelocityR: LoadVelocityR;
		case ReadOperation.LoadSpeedR: LoadSpeedR;
		case ReadOperation.LoadDirectionR: LoadDirectionR;
		case ReadOperation.LoadShotPositionR: LoadShotPositionR;
		case ReadOperation.LoadShotDistanceR: LoadShotDistanceR;
		case ReadOperation.LoadShotBearingR: LoadShotBearingR;
		case ReadOperation.LoadShotVelocityR: LoadShotVelocityR;
		case ReadOperation.LoadShotSpeedR: LoadShotSpeedR;
		case ReadOperation.LoadShotDirectionR: LoadShotDirectionR;
		case ReadOperation.LoadTargetPositionR: LoadTargetPositionR;
		case ReadOperation.LoadTargetXR: LoadTargetXR;
		case ReadOperation.LoadTargetYR: LoadTargetYR;
		case ReadOperation.LoadBearingToTargetR: LoadBearingToTargetR;
		case ReadOperation.GetDiffPositionCR: GetDiffPositionCR;
		case ReadOperation.GetDiffVelocityCR: GetDiffVelocityCR;
		case ReadOperation.GetDiffPositionRR: GetDiffPositionRR;
		case ReadOperation.GetDiffVelocityRR: GetDiffVelocityRR;
		case ReadOperation.GetDiffDistanceCR: GetDiffDistanceCR;
		case ReadOperation.GetDiffBearingCR: GetDiffBearingCR;
		case ReadOperation.GetDiffSpeedCR: GetDiffSpeedCR;
		case ReadOperation.GetDiffDirectionCR: GetDiffDirectionCR;
		case ReadOperation.GetDiffDistanceRR: GetDiffDistanceRR;
		case ReadOperation.GetDiffBearingRR: GetDiffBearingRR;
		case ReadOperation.GetDiffSpeedRR: GetDiffSpeedRR;
		case ReadOperation.GetDiffDirectionRR: GetDiffDirectionRR;
		case ReadOperation.GetDiffShotPositionCR: GetDiffShotPositionCR;
		case ReadOperation.GetDiffShotVelocityCR: GetDiffShotVelocityCR;
		case ReadOperation.GetDiffShotPositionRR: GetDiffShotPositionRR;
		case ReadOperation.GetDiffShotVelocityRR: GetDiffShotVelocityRR;
		case ReadOperation.GetDiffShotDistanceCR: GetDiffShotDistanceCR;
		case ReadOperation.GetDiffShotBearingCR: GetDiffShotBearingCR;
		case ReadOperation.GetDiffShotSpeedCR: GetDiffShotSpeedCR;
		case ReadOperation.GetDiffShotDirectionCR: GetDiffShotDirectionCR;
		case ReadOperation.GetDiffShotDistanceRR: GetDiffShotDistanceRR;
		case ReadOperation.GetDiffShotBearingRR: GetDiffShotBearingRR;
		case ReadOperation.GetDiffShotSpeedRR: GetDiffShotSpeedRR;
		case ReadOperation.GetDiffShotDirectionRR: GetDiffShotDirectionRR;
		default: throw error(value);
		}
	}

	// ---- read actor data

	/**
		(position) -> (vec register)
	**/
	final LoadPositionR;

	/**
		(distance) -> (float register)
	**/
	final LoadDistanceR;

	/**
		(bearing) -> (float register)
	**/
	final LoadBearingR;

	/**
		(velocity) -> (vec register)
	**/
	final LoadVelocityR;

	/**
		(speed) -> (float register)
	**/
	final LoadSpeedR;

	/**
		(direction) -> (float register)
	**/
	final LoadDirectionR;

	/**
		(shot position) -> (vec register)
	**/
	final LoadShotPositionR;

	/**
		(shot distance) -> (float register)
	**/
	final LoadShotDistanceR;

	/**
		(shot bearing) -> (float register)
	**/
	final LoadShotBearingR;

	/**
		(shot velocity) -> (vec register)
	**/
	final LoadShotVelocityR;

	/**
		(shot speed) -> (float register)
	**/
	final LoadShotSpeedR;

	/**
		(shot direction) -> (float register)
	**/
	final LoadShotDirectionR;

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
	final GetDiffPositionCR;

	/**
		(vec immediate) - (velocity) -> (vec register)
	**/
	final GetDiffVelocityCR;

	/**
		(vec register) - (position) -> (vec register)
	**/
	final GetDiffPositionRR;

	/**
		(vec register) - (velocity) -> (vec register)
	**/
	final GetDiffVelocityRR;

	/**
		(float immediate) - (distance) -> (float register)
	**/
	final GetDiffDistanceCR;

	/**
		(float immediate) - (bearing) -> (float register)
	**/
	final GetDiffBearingCR;

	/**
		(float immediate) - (speed) -> (float register)
	**/
	final GetDiffSpeedCR;

	/**
		(float immediate) - (direction) -> (float register)
	**/
	final GetDiffDirectionCR;

	/**
		(float register) - (distance) -> (float register)
	**/
	final GetDiffDistanceRR;

	/**
		(float register) - (bearing) -> (float register)
	**/
	final GetDiffBearingRR;

	/**
		(float register) - (speed) -> (float register)
	**/
	final GetDiffSpeedRR;

	/**
		(float register) - (direction) -> (float register)
	**/
	final GetDiffDirectionRR;

	/**
		(vec immediate) - (shot position) -> (vec register)
	**/
	final GetDiffShotPositionCR;

	/**
		(vec immediate) - (shot velocity) -> (vec register)
	**/
	final GetDiffShotVelocityCR;

	/**
		(vec register) - (shot position) -> (vec register)
	**/
	final GetDiffShotPositionRR;

	/**
		(vec register) - (shot velocity) -> (vec register)
	**/
	final GetDiffShotVelocityRR;

	/**
		(float immediate) - (shot distance) -> (float register)
	**/
	final GetDiffShotDistanceCR;

	/**
		(float immediate) - (shot bearing) -> (float register)
	**/
	final GetDiffShotBearingCR;

	/**
		(float immediate) - (shot speed) -> (float register)
	**/
	final GetDiffShotSpeedCR;

	/**
		(float immediate) - (shot direction) -> (float register)
	**/
	final GetDiffShotDirectionCR;

	/**
		(float register) - (shot distance) -> (float register)
	**/
	final GetDiffShotDistanceRR;

	/**
		(float register) - (shot bearing) -> (float register)
	**/
	final GetDiffShotBearingRR;

	/**
		(float register) - (shot speed) -> (float register)
	**/
	final GetDiffShotSpeedRR;

	/**
		(float register) - (shot direction) -> (float register)
	**/
	final GetDiffShotDirectionRR;

	public extern inline function int(): Int
		return this;
}

class ReadOperationExtension {
	/**
		@return The mnemonic for `code`.
	**/
	public static inline function toString(code: ReadOperation): String {
		return switch code {
		case LoadPositionR: "load_position_r";
		case LoadDistanceR: "load_distance_r";
		case LoadBearingR: "load_bearing_r";
		case LoadVelocityR: "load_velocity_r";
		case LoadSpeedR: "load_speed_r";
		case LoadDirectionR: "load_direction_r";
		case LoadShotPositionR: "load_shot_position_r";
		case LoadShotDistanceR: "load_shot_distance_r";
		case LoadShotBearingR: "load_shot_bearing_r";
		case LoadShotVelocityR: "load_shot_velocity_r";
		case LoadShotSpeedR: "load_shot_speed_r";
		case LoadShotDirectionR: "load_shot_direction_r";
		case LoadTargetPositionR: "load_target_position_r";
		case LoadTargetXR: "load_target_x_r";
		case LoadTargetYR: "load_target_y_r";
		case LoadBearingToTargetR: "load_bearing_to_target_r";
		case GetDiffPositionCR: "calc_rel_position_cr";
		case GetDiffVelocityCR: "calc_rel_velocity_cr";
		case GetDiffPositionRR: "calc_rel_position_rr";
		case GetDiffVelocityRR: "calc_rel_velocity_rr";
		case GetDiffDistanceCR: "calc_rel_distance_cr";
		case GetDiffBearingCR: "calc_rel_bearing_cr";
		case GetDiffSpeedCR: "calc_rel_speed_cr";
		case GetDiffDirectionCR: "calc_rel_direction_cr";
		case GetDiffDistanceRR: "calc_rel_distance_rr";
		case GetDiffBearingRR: "calc_rel_bearing_rr";
		case GetDiffSpeedRR: "calc_rel_speed_rr";
		case GetDiffDirectionRR: "calc_rel_direction_rr";
		case GetDiffShotPositionCR: "calc_rel_shot_position_cr";
		case GetDiffShotVelocityCR: "calc_rel_shot_velocity_cr";
		case GetDiffShotPositionRR: "calc_rel_shot_position_rr";
		case GetDiffShotVelocityRR: "calc_rel_shot_velocity_rr";
		case GetDiffShotDistanceCR: "calc_rel_shot_distance_cr";
		case GetDiffShotBearingCR: "calc_rel_shot_bearing_cr";
		case GetDiffShotSpeedCR: "calc_rel_shot_speed_cr";
		case GetDiffShotDirectionCR: "calc_rel_shot_direction_cr";
		case GetDiffShotDistanceRR: "calc_rel_distance_rr";
		case GetDiffShotBearingRR: "calc_rel_bearing_rr";
		case GetDiffShotSpeedRR: "calc_rel_speed_rr";
		case GetDiffShotDirectionRR: "calc_rel_direction_rr";
		}
	}
}
