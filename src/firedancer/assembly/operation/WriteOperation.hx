package firedancer.assembly.operation;

/**
	Value that specifies an operation to be performed.
**/
@:using(firedancer.assembly.operation.WriteOperation.WriteOperationExtension)
enum abstract WriteOperation(Int) to Int {
	static function error(v: Int): String
		return 'Unknown write operation: $v';

	/**
		Converts `value` to `WriteOperation`.
		Throws error if `value` does not match any `WriteOperation` values.
	**/
	public static inline function from(value: Int): WriteOperation {
		return switch value {
			case WriteOperation.SetPositionC: SetPositionC;
			case WriteOperation.AddPositionC: AddPositionC;
			case WriteOperation.SetVelocityC: SetVelocityC;
			case WriteOperation.AddVelocityC: AddVelocityC;
			case WriteOperation.SetPositionR: SetPositionR;
			case WriteOperation.AddPositionR: AddPositionR;
			case WriteOperation.SetVelocityR: SetVelocityR;
			case WriteOperation.AddVelocityR: AddVelocityR;
			case WriteOperation.AddPositionS: AddPositionS;
			case WriteOperation.AddVelocityS: AddVelocityS;
			case WriteOperation.SetDistanceC: SetDistanceC;
			case WriteOperation.AddDistanceC: AddDistanceC;
			case WriteOperation.SetDistanceR: SetDistanceR;
			case WriteOperation.AddDistanceR: AddDistanceR;
			case WriteOperation.AddDistanceS: AddDistanceS;
			case WriteOperation.SetBearingC: SetBearingC;
			case WriteOperation.AddBearingC: AddBearingC;
			case WriteOperation.SetBearingR: SetBearingR;
			case WriteOperation.AddBearingR: AddBearingR;
			case WriteOperation.AddBearingS: AddBearingS;
			case WriteOperation.SetSpeedC: SetSpeedC;
			case WriteOperation.AddSpeedC: AddSpeedC;
			case WriteOperation.SetSpeedR: SetSpeedR;
			case WriteOperation.AddSpeedR: AddSpeedR;
			case WriteOperation.AddSpeedS: AddSpeedS;
			case WriteOperation.SetDirectionC: SetDirectionC;
			case WriteOperation.AddDirectionC: AddDirectionC;
			case WriteOperation.SetDirectionR: SetDirectionR;
			case WriteOperation.AddDirectionR: AddDirectionR;
			case WriteOperation.AddDirectionS: AddDirectionS;

			case WriteOperation.SetShotPositionC: SetShotPositionC;
			case WriteOperation.AddShotPositionC: AddShotPositionC;
			case WriteOperation.SetShotVelocityC: SetShotVelocityC;
			case WriteOperation.AddShotVelocityC: AddShotVelocityC;
			case WriteOperation.SetShotPositionR: SetShotPositionR;
			case WriteOperation.AddShotPositionR: AddShotPositionR;
			case WriteOperation.SetShotVelocityR: SetShotVelocityR;
			case WriteOperation.AddShotVelocityR: AddShotVelocityR;
			case WriteOperation.AddShotPositionS: AddShotPositionS;
			case WriteOperation.AddShotVelocityS: AddShotVelocityS;
			case WriteOperation.SetShotDistanceC: SetShotDistanceC;
			case WriteOperation.AddShotDistanceC: AddShotDistanceC;
			case WriteOperation.SetShotDistanceR: SetShotDistanceR;
			case WriteOperation.AddShotDistanceR: AddShotDistanceR;
			case WriteOperation.AddShotDistanceS: AddShotDistanceS;
			case WriteOperation.SetShotBearingC: SetShotBearingC;
			case WriteOperation.AddShotBearingC: AddShotBearingC;
			case WriteOperation.SetShotBearingR: SetShotBearingR;
			case WriteOperation.AddShotBearingR: AddShotBearingR;
			case WriteOperation.AddShotBearingS: AddShotBearingS;
			case WriteOperation.SetShotSpeedC: SetShotSpeedC;
			case WriteOperation.AddShotSpeedC: AddShotSpeedC;
			case WriteOperation.SetShotSpeedR: SetShotSpeedR;
			case WriteOperation.AddShotSpeedR: AddShotSpeedR;
			case WriteOperation.AddShotSpeedS: AddShotSpeedS;
			case WriteOperation.SetShotDirectionC: SetShotDirectionC;
			case WriteOperation.AddShotDirectionC: AddShotDirectionC;
			case WriteOperation.SetShotDirectionR: SetShotDirectionR;
			case WriteOperation.AddShotDirectionR: AddShotDirectionR;
			case WriteOperation.AddShotDirectionS: AddShotDirectionS;

			default: throw error(value);
		}
	}

	// ---- write actor data ------------------------------------------

	/**
		(vec immediate) -> (position)
	**/
	final SetPositionC;

	/**
		(position) + (vec immediate) -> (position)
	**/
	final AddPositionC;

	/**
		(vec immediate) -> (velocity)
	**/
	final SetVelocityC;

	/**
		(velocity) + (vec immediate) -> (velocity)
	**/
	final AddVelocityC;

	/**
		(vec register) -> (position)
	**/
	final SetPositionR;

	/**
		(position) + (vec register) -> (position)
	**/
	final AddPositionR;

	/**
		(vec register) -> (velocity)
	**/
	final SetVelocityR;

	/**
		(velocity) + (vec register) -> (velocity)
	**/
	final AddVelocityR;

	/**
		(position) + (vec peeked from stack top) -> (position)
	**/
	final AddPositionS;

	/**
		(velocity) + (vec peeked from stack top) -> (velocity)
	**/
	final AddVelocityS;

	/**
		(float immediate) -> (distance)
	**/
	final SetDistanceC;

	/**
		(distance) + (float immediate) -> (distance)
	**/
	final AddDistanceC;

	/**
		(float register) -> (distance)
	**/
	final SetDistanceR;

	/**
		(distance) + (float register) -> (distance)
	**/
	final AddDistanceR;

	/**
		(distance) + (float peeked from stack top) -> (distance)
	**/
	final AddDistanceS;

	/**
		(float immediate) -> (bearing)
	**/
	final SetBearingC;

	/**
		(bearing) + (float immediate) -> (bearing)
	**/
	final AddBearingC;

	/**
		(float register) -> (bearing)
	**/
	final SetBearingR;

	/**
		(bearing) + (float register) -> (bearing)
	**/
	final AddBearingR;

	/**
		(bearing) + (float peeked from stack top) -> (bearing)
	**/
	final AddBearingS;

	/**
		(float immediate) -> (speed)
	**/
	final SetSpeedC;

	/**
		(speed) + (float immediate) -> (speed)
	**/
	final AddSpeedC;

	/**
		(float register) -> (speed)
	**/
	final SetSpeedR;

	/**
		(speed) + (float register) -> (speed)
	**/
	final AddSpeedR;

	/**
		(speed) + (float peeked from stack top) -> (speed)
	**/
	final AddSpeedS;

	/**
		(float immediate) -> (direction)
	**/
	final SetDirectionC;

	/**
		(direction) + (float immediate) -> (direction)
	**/
	final AddDirectionC;

	/**
		(float register) -> (direction)
	**/
	final SetDirectionR;

	/**
		(direction) + (float register) -> (direction)
	**/
	final AddDirectionR;

	/**
		(direction) + (float peeked from stack top) -> (direction)
	**/
	final AddDirectionS;

	// ---- read/write/calc shot position/velocity ------------------------------

	/**
		(vec immediate) -> (shot position)
	**/
	final SetShotPositionC;

	/**
		(shot position) + (vec immediate) -> (shot position)
	**/
	final AddShotPositionC;

	/**
		(vec immediate) -> (shot velocity)
	**/
	final SetShotVelocityC;

	/**
		(shot velocity) + (vec immediate) -> (shot velocity)
	**/
	final AddShotVelocityC;

	/**
		(vec register) -> (shot position)
	**/
	final SetShotPositionR;

	/**
		(shot position) + (vec register) -> (shot position)
	**/
	final AddShotPositionR;

	/**
		(vec register) -> (shot velocity)
	**/
	final SetShotVelocityR;

	/**
		(shot velocity) + (vec register) -> (shot velocity)
	**/
	final AddShotVelocityR;

	/**
		(shot position) + (vec peeked from stack top) -> (shot position)
	**/
	final AddShotPositionS;

	/**
		(shot velocity) + (vec peeked from stack top) -> (shot velocity)
	**/
	final AddShotVelocityS;

	/**
		(float immediate) -> (shot distance)
	**/
	final SetShotDistanceC;

	/**
		(shot distance) + (float immediate) -> (shot distance)
	**/
	final AddShotDistanceC;

	/**
		(float register) -> (shot distance)
	**/
	final SetShotDistanceR;

	/**
		(shot distance) + (float register) -> (shot distance)
	**/
	final AddShotDistanceR;

	/**
		(shot distance) + (float peeked from stack top) -> (shot distance)
	**/
	final AddShotDistanceS;

	/**
		(float immediate) -> (shot bearing)
	**/
	final SetShotBearingC;

	/**
		(shot bearing) + (float immediate) -> (shot bearing)
	**/
	final AddShotBearingC;

	/**
		(float register) -> (shot bearing)
	**/
	final SetShotBearingR;

	/**
		(shot bearing) + (float register) -> (shot bearing)
	**/
	final AddShotBearingR;

	/**
		(shot bearing) + (float peeked from stack top) -> (shot bearing)
	**/
	final AddShotBearingS;

	/**
		(float immediate) -> (shot speed)
	**/
	final SetShotSpeedC;

	/**
		(shot speed) + (float immediate) -> (shot speed)
	**/
	final AddShotSpeedC;

	/**
		(float register) -> (shot speed)
	**/
	final SetShotSpeedR;

	/**
		(shot speed) + (float register) -> (shot speed)
	**/
	final AddShotSpeedR;

	/**
		(shot speed) + (float peeked from stack top) -> (shot speed)
	**/
	final AddShotSpeedS;

	/**
		(float immediate) -> (shot direction)
	**/
	final SetShotDirectionC;

	/**
		(shot direction) + (float immediate) -> (shot direction)
	**/
	final AddShotDirectionC;

	/**
		(float register) -> (shot direction)
	**/
	final SetShotDirectionR;

	/**
		(shot direction) + (float register) -> (shot direction)
	**/
	final AddShotDirectionR;

	/**
		(shot direction) + (float peeked from stack top) -> (shot direction)
	**/
	final AddShotDirectionS;

	public extern inline function int(): Int
		return this;
}

class WriteOperationExtension {
	/**
		@return The mnemonic for `code`.
	**/
	public static inline function toString(code: WriteOperation): String {
		return switch code {
			case SetPositionC: "set_position_c";
			case AddPositionC: "add_position_c";
			case SetVelocityC: "set_velocity_c";
			case AddVelocityC: "add_velocity_c";
			case SetPositionR: "set_position_r";
			case AddPositionR: "add_position_r";
			case SetVelocityR: "set_velocity_r";
			case AddVelocityR: "add_velocity_r";
			case AddPositionS: "add_position_s";
			case AddVelocityS: "add_velocity_s";
			case SetDistanceC: "set_distance_c";
			case AddDistanceC: "add_distance_c";
			case SetDistanceR: "set_distance_r";
			case AddDistanceR: "add_distance_r";
			case AddDistanceS: "add_distance_s";
			case SetBearingC: "set_bearing_c";
			case AddBearingC: "add_bearing_c";
			case SetBearingR: "set_bearing_r";
			case AddBearingR: "add_bearing_r";
			case AddBearingS: "add_bearing_s";
			case SetSpeedC: "set_speed_c";
			case AddSpeedC: "add_speed_c";
			case SetSpeedR: "set_speed_r";
			case AddSpeedR: "add_speed_r";
			case AddSpeedS: "add_speed_s";
			case SetDirectionC: "set_direction_c";
			case AddDirectionC: "add_direction_c";
			case SetDirectionR: "set_direction_r";
			case AddDirectionR: "add_direction_r";
			case AddDirectionS: "add_direction_s";

			case SetShotPositionC: "set_shot_position_c";
			case AddShotPositionC: "add_shot_position_c";
			case SetShotVelocityC: "set_shot_velocity_c";
			case AddShotVelocityC: "add_shot_velocity_c";
			case SetShotPositionR: "set_shot_position_r";
			case AddShotPositionR: "add_shot_position_r";
			case SetShotVelocityR: "set_shot_velocity_r";
			case AddShotVelocityR: "add_shot_velocity_r";
			case AddShotPositionS: "add_shot_position_s";
			case AddShotVelocityS: "add_shot_velocity_s";
			case SetShotDistanceC: "set_shot_distance_c";
			case AddShotDistanceC: "add_shot_distance_c";
			case SetShotDistanceR: "set_shot_distance_r";
			case AddShotDistanceR: "add_shot_distance_r";
			case AddShotDistanceS: "add_shot_distance_s";
			case SetShotBearingC: "set_shot_bearing_c";
			case AddShotBearingC: "add_shot_bearing_c";
			case SetShotBearingR: "set_shot_bearing_r";
			case AddShotBearingR: "add_shot_bearing_r";
			case AddShotBearingS: "add_shot_bearing_s";
			case SetShotSpeedC: "set_shot_speed_c";
			case AddShotSpeedC: "add_shot_speed_c";
			case SetShotSpeedR: "set_shot_speed_r";
			case AddShotSpeedR: "add_shot_speed_r";
			case AddShotSpeedS: "add_shot_speed_s";
			case SetShotDirectionC: "set_shot_direction_c";
			case AddShotDirectionC: "add_shot_direction_c";
			case SetShotDirectionR: "set_shot_direction_r";
			case AddShotDirectionR: "add_shot_direction_r";
			case AddShotDirectionS: "add_shot_direction_s";
		}
	}
}
