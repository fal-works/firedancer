package firedancer.assembly.types;

/**
	Type of actor's property to be operated.
**/
enum abstract ActorPropertyType(Int) {
	final Position;
	final Velocity;
	final ShotPosition;
	final ShotVelocity;

	public function toString(): String {
		return switch (cast this: ActorPropertyType) {
			case Position: "position";
			case Velocity: "velocity";
			case ShotPosition: "shot_position";
			case ShotVelocity: "shot_velocity";
		}
	}
}
