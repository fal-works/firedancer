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
			case WriteShotOperation.SetShotPositionS: SetShotPositionS;
			case WriteShotOperation.AddShotPositionS: AddShotPositionS;
			case WriteShotOperation.SetShotVelocityS: SetShotVelocityS;
			case WriteShotOperation.AddShotVelocityS: AddShotVelocityS;
			case WriteShotOperation.SetShotPositionV: SetShotPositionV;
			case WriteShotOperation.AddShotPositionV: AddShotPositionV;
			case WriteShotOperation.SetShotVelocityV: SetShotVelocityV;
			case WriteShotOperation.AddShotVelocityV: AddShotVelocityV;
			case WriteShotOperation.SetShotDistanceC: SetShotDistanceC;
			case WriteShotOperation.AddShotDistanceC: AddShotDistanceC;
			case WriteShotOperation.SetShotDistanceS: SetShotDistanceS;
			case WriteShotOperation.AddShotDistanceS: AddShotDistanceS;
			case WriteShotOperation.SetShotDistanceV: SetShotDistanceV;
			case WriteShotOperation.AddShotDistanceV: AddShotDistanceV;
			case WriteShotOperation.SetShotBearingC: SetShotBearingC;
			case WriteShotOperation.AddShotBearingC: AddShotBearingC;
			case WriteShotOperation.SetShotBearingS: SetShotBearingS;
			case WriteShotOperation.AddShotBearingS: AddShotBearingS;
			case WriteShotOperation.SetShotBearingV: SetShotBearingV;
			case WriteShotOperation.AddShotBearingV: AddShotBearingV;
			case WriteShotOperation.SetShotSpeedC: SetShotSpeedC;
			case WriteShotOperation.AddShotSpeedC: AddShotSpeedC;
			case WriteShotOperation.SetShotSpeedS: SetShotSpeedS;
			case WriteShotOperation.AddShotSpeedS: AddShotSpeedS;
			case WriteShotOperation.SetShotSpeedV: SetShotSpeedV;
			case WriteShotOperation.AddShotSpeedV: AddShotSpeedV;
			case WriteShotOperation.SetShotDirectionC: SetShotDirectionC;
			case WriteShotOperation.AddShotDirectionC: AddShotDirectionC;
			case WriteShotOperation.SetShotDirectionS: SetShotDirectionS;
			case WriteShotOperation.AddShotDirectionS: AddShotDirectionS;
			case WriteShotOperation.SetShotDirectionV: SetShotDirectionV;
			case WriteShotOperation.AddShotDirectionV: AddShotDirectionV;

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
			case SetShotPositionS: "set_shot_position_s";
			case AddShotPositionS: "add_shot_position_s";
			case SetShotVelocityS: "set_shot_velocity_s";
			case AddShotVelocityS: "add_shot_velocity_s";
			case SetShotPositionV: "set_shot_position_v";
			case AddShotPositionV: "add_shot_position_v";
			case SetShotVelocityV: "set_shot_velocity_v";
			case AddShotVelocityV: "add_shot_velocity_v";
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
		}
	}

	/**
		Creates a `StatementType` instance that corresponds to `op`.
	**/
	public static inline function toStatementType(op: WriteShotOperation): StatementType {
		return switch op {
			case SetShotPositionC | AddShotPositionC | SetShotVelocityC | AddShotVelocityC: [Vec];
			case SetShotPositionS | AddShotPositionS | SetShotVelocityS | AddShotVelocityS: [];
			case SetShotPositionV | AddShotPositionV | SetShotVelocityV | AddShotVelocityV: [];
			case SetShotDistanceC | AddShotDistanceC | SetShotBearingC | AddShotBearingC: [Float];
			case SetShotSpeedC | AddShotSpeedC | SetShotDirectionC | AddShotDirectionC: [Float];
			case SetShotDistanceS | AddShotDistanceS | SetShotBearingS | AddShotBearingS: [];
			case SetShotSpeedS | AddShotSpeedS | SetShotDirectionS | AddShotDirectionS: [];
			case SetShotDistanceV | AddShotDistanceV | SetShotBearingV | AddShotBearingV: [];
			case SetShotSpeedV | AddShotSpeedV | SetShotDirectionV | AddShotDirectionV: [];
		}
	}

	/**
		@return The bytecode length in bytes required for a statement with `op`.
	**/
	public static inline function getBytecodeLength(op: WriteShotOperation): UInt
		return toStatementType(op).bytecodeLength();
}
