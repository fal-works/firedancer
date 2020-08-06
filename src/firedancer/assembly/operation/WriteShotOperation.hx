package firedancer.assembly.operation;

/**
	Value that specifies an operation to be performed.
**/
@:using(firedancer.assembly.operation.WriteShotOperation.WriteShotOperationExtension)
enum abstract WriteShotOperation(Int) to Int {
	static function error(v: Int): String
		return 'Unknown write shot operation: $v';

	/**
		Converts `value` to `WriteShotOperation`.
		Throws error if `value` does not match any `WriteShotOperation` values.
	**/
	public static inline function from(value: Int): WriteShotOperation {
		return switch value {
			case WriteShotOperation.SetShotPositionC: SetShotPositionC;
			case WriteShotOperation.AddShotPositionC: AddShotPositionC;
			case WriteShotOperation.SetShotVelocityC: SetShotVelocityC;
			case WriteShotOperation.AddShotVelocityC: AddShotVelocityC;
			case WriteShotOperation.SetShotPositionV: SetShotPositionV;
			case WriteShotOperation.AddShotPositionV: AddShotPositionV;
			case WriteShotOperation.SetShotVelocityV: SetShotVelocityV;
			case WriteShotOperation.AddShotVelocityV: AddShotVelocityV;
			case WriteShotOperation.AddShotPositionS: AddShotPositionS;
			case WriteShotOperation.AddShotVelocityS: AddShotVelocityS;
			case WriteShotOperation.SetShotDistanceC: SetShotDistanceC;
			case WriteShotOperation.AddShotDistanceC: AddShotDistanceC;
			case WriteShotOperation.SetShotDistanceV: SetShotDistanceV;
			case WriteShotOperation.AddShotDistanceV: AddShotDistanceV;
			case WriteShotOperation.AddShotDistanceS: AddShotDistanceS;
			case WriteShotOperation.SetShotBearingC: SetShotBearingC;
			case WriteShotOperation.AddShotBearingC: AddShotBearingC;
			case WriteShotOperation.SetShotBearingV: SetShotBearingV;
			case WriteShotOperation.AddShotBearingV: AddShotBearingV;
			case WriteShotOperation.AddShotBearingS: AddShotBearingS;
			case WriteShotOperation.SetShotSpeedC: SetShotSpeedC;
			case WriteShotOperation.AddShotSpeedC: AddShotSpeedC;
			case WriteShotOperation.SetShotSpeedV: SetShotSpeedV;
			case WriteShotOperation.AddShotSpeedV: AddShotSpeedV;
			case WriteShotOperation.AddShotSpeedS: AddShotSpeedS;
			case WriteShotOperation.SetShotDirectionC: SetShotDirectionC;
			case WriteShotOperation.AddShotDirectionC: AddShotDirectionC;
			case WriteShotOperation.SetShotDirectionV: SetShotDirectionV;
			case WriteShotOperation.AddShotDirectionV: AddShotDirectionV;
			case WriteShotOperation.AddShotDirectionS: AddShotDirectionS;

			default: throw error(value);
		}
	}


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
		Adds the vector at the stack top to actor's shot position.
	**/
	final AddShotPositionS;

	/**
		Adds the vector at the stack top to actor's shot velocity.
	**/
	final AddShotVelocityS;

	final SetShotDistanceC;
	final AddShotDistanceC;
	final SetShotDistanceV;
	final AddShotDistanceV;
	final AddShotDistanceS;
	final SetShotBearingC;
	final AddShotBearingC;
	final SetShotBearingV;
	final AddShotBearingV;
	final AddShotBearingS;

	final SetShotSpeedC;
	final AddShotSpeedC;
	final SetShotSpeedV;
	final AddShotSpeedV;
	final AddShotSpeedS;
	final SetShotDirectionC;
	final AddShotDirectionC;
	final SetShotDirectionV;
	final AddShotDirectionV;
	final AddShotDirectionS;


	public extern inline function int(): Int
		return this;
}

class WriteShotOperationExtension {
	/**
		@return The mnemonic for `code`.
	**/
	public static inline function toString(code: WriteShotOperation): String {
		return switch code {
			case SetShotPositionC: "set_shot_position_c";
			case AddShotPositionC: "add_shot_position_c";
			case SetShotVelocityC: "set_shot_velocity_c";
			case AddShotVelocityC: "add_shot_velocity_c";
			case SetShotPositionV: "set_shot_position_v";
			case AddShotPositionV: "add_shot_position_v";
			case SetShotVelocityV: "set_shot_velocity_v";
			case AddShotVelocityV: "add_shot_velocity_v";
			case AddShotPositionS: "add_shot_position_s";
			case AddShotVelocityS: "add_shot_velocity_s";
			case SetShotDistanceC: "set_shot_distance_c";
			case AddShotDistanceC: "add_shot_distance_c";
			case SetShotDistanceV: "set_shot_distance_v";
			case AddShotDistanceV: "add_shot_distance_v";
			case AddShotDistanceS: "add_shot_distance_s";
			case SetShotBearingC: "set_shot_bearing_c";
			case AddShotBearingC: "add_shot_bearing_c";
			case SetShotBearingV: "set_shot_bearing_v";
			case AddShotBearingV: "add_shot_bearing_v";
			case AddShotBearingS: "add_shot_bearing_s";
			case SetShotSpeedC: "set_shot_speed_c";
			case AddShotSpeedC: "add_shot_speed_c";
			case SetShotSpeedV: "set_shot_speed_v";
			case AddShotSpeedV: "add_shot_speed_v";
			case AddShotSpeedS: "add_shot_speed_s";
			case SetShotDirectionC: "set_shot_direction_c";
			case AddShotDirectionC: "add_shot_direction_c";
			case SetShotDirectionV: "set_shot_direction_v";
			case AddShotDirectionV: "add_shot_direction_v";
			case AddShotDirectionS: "add_shot_direction_s";
		}
	}

	/**
		Creates a `StatementType` instance that corresponds to `op`.
	**/
	public static inline function toStatementType(op: WriteShotOperation): StatementType {
		return switch op {
			case SetShotPositionC | AddShotPositionC | SetShotVelocityC | AddShotVelocityC: [Vec];
			case SetShotPositionV | AddShotPositionV | SetShotVelocityV | AddShotVelocityV: [];
			case AddShotPositionS | AddShotVelocityS: [];
			case SetShotDistanceC | AddShotDistanceC | SetShotBearingC | AddShotBearingC: [Float];
			case SetShotSpeedC | AddShotSpeedC | SetShotDirectionC | AddShotDirectionC: [Float];
			case SetShotDistanceV | AddShotDistanceV | SetShotBearingV | AddShotBearingV: [];
			case SetShotSpeedV | AddShotSpeedV | SetShotDirectionV | AddShotDirectionV: [];
			case AddShotDistanceS | AddShotBearingS: [];
			case AddShotSpeedS | AddShotDirectionS: [];
		}
	}

	/**
		@return The bytecode length in bytes required for a statement with `op`.
	**/
	public static inline function getBytecodeLength(op: WriteShotOperation): UInt
		return toStatementType(op).bytecodeLength();
}
