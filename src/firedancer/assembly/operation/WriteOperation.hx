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
			case WriteOperation.SetPositionV: SetPositionV;
			case WriteOperation.AddPositionV: AddPositionV;
			case WriteOperation.SetVelocityV: SetVelocityV;
			case WriteOperation.AddVelocityV: AddVelocityV;
			case WriteOperation.AddPositionS: AddPositionS;
			case WriteOperation.AddVelocityS: AddVelocityS;
			case WriteOperation.SetDistanceC: SetDistanceC;
			case WriteOperation.AddDistanceC: AddDistanceC;
			case WriteOperation.SetDistanceV: SetDistanceV;
			case WriteOperation.AddDistanceV: AddDistanceV;
			case WriteOperation.AddDistanceS: AddDistanceS;
			case WriteOperation.SetBearingC: SetBearingC;
			case WriteOperation.AddBearingC: AddBearingC;
			case WriteOperation.SetBearingV: SetBearingV;
			case WriteOperation.AddBearingV: AddBearingV;
			case WriteOperation.AddBearingS: AddBearingS;
			case WriteOperation.SetSpeedC: SetSpeedC;
			case WriteOperation.AddSpeedC: AddSpeedC;
			case WriteOperation.SetSpeedV: SetSpeedV;
			case WriteOperation.AddSpeedV: AddSpeedV;
			case WriteOperation.AddSpeedS: AddSpeedS;
			case WriteOperation.SetDirectionC: SetDirectionC;
			case WriteOperation.AddDirectionC: AddDirectionC;
			case WriteOperation.SetDirectionV: SetDirectionV;
			case WriteOperation.AddDirectionV: AddDirectionV;
			case WriteOperation.AddDirectionS: AddDirectionS;
			default: throw error(value);
		}
	}

	// ---- write actor data ------------------------------------------

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
		Adds the vector at the stack top to actor's position.
	**/
	final AddPositionS;

	/**
		Adds the vector at the stack top to actor's velocity.
	**/
	final AddVelocityS;

	final SetDistanceC;
	final AddDistanceC;
	final SetDistanceV;
	final AddDistanceV;
	final AddDistanceS;
	final SetBearingC;
	final AddBearingC;
	final SetBearingV;
	final AddBearingV;
	final AddBearingS;

	final SetSpeedC;
	final AddSpeedC;
	final SetSpeedV;
	final AddSpeedV;
	final AddSpeedS;
	final SetDirectionC;
	final AddDirectionC;
	final SetDirectionV;
	final AddDirectionV;
	final AddDirectionS;

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
			case SetPositionV: "set_position_v";
			case AddPositionV: "add_position_v";
			case SetVelocityV: "set_velocity_v";
			case AddVelocityV: "add_velocity_v";
			case AddPositionS: "add_position_s";
			case AddVelocityS: "add_velocity_s";
			case SetDistanceC: "set_distance_c";
			case AddDistanceC: "add_distance_c";
			case SetDistanceV: "set_distance_v";
			case AddDistanceV: "add_distance_v";
			case AddDistanceS: "add_distance_s";
			case SetBearingC: "set_bearing_c";
			case AddBearingC: "add_bearing_c";
			case SetBearingV: "set_bearing_v";
			case AddBearingV: "add_bearing_v";
			case AddBearingS: "add_bearing_s";
			case SetSpeedC: "set_speed_c";
			case AddSpeedC: "add_speed_c";
			case SetSpeedV: "set_speed_v";
			case AddSpeedV: "add_speed_v";
			case AddSpeedS: "add_speed_s";
			case SetDirectionC: "set_direction_c";
			case AddDirectionC: "add_direction_c";
			case SetDirectionV: "set_direction_v";
			case AddDirectionV: "add_direction_v";
			case AddDirectionS: "add_direction_s";
		}
	}

	/**
		Creates a `StatementType` instance that corresponds to `op`.
	**/
	public static inline function toStatementType(op: WriteOperation): StatementType {
		return switch op {
			case SetPositionC | AddPositionC | SetVelocityC | AddVelocityC: [Vec];
			case SetPositionV | AddPositionV | SetVelocityV | AddVelocityV: [];
			case AddPositionS | AddVelocityS: [];
			case SetDistanceC | AddDistanceC | SetBearingC | AddBearingC: [Float];
			case SetSpeedC | AddSpeedC | SetDirectionC | AddDirectionC: [Float];
			case SetDistanceV | AddDistanceV | SetBearingV | AddBearingV: [];
			case SetSpeedV | AddSpeedV | SetDirectionV | AddDirectionV: [];
			case AddDistanceS | AddBearingS: [];
			case AddSpeedS | AddDirectionS: [];
		}
	}

	/**
		@return The bytecode length in bytes required for a statement with `op`.
	**/
	public static inline function getBytecodeLength(op: WriteOperation): UInt
		return toStatementType(op).bytecodeLength();
}
