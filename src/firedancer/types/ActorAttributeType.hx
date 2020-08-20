package firedancer.types;

/**
	Type of actor's attribute to be operated.
**/
enum abstract ActorAttributeType(Int) {
	final Position;
	final Velocity;
	final ShotPosition;
	final ShotVelocity;

	public function toString(): String {
		return switch (cast this: ActorAttributeType) {
			case Position: "position";
			case Velocity: "velocity";
			case ShotPosition: "shot_position";
			case ShotVelocity: "shot_velocity";
		}
	}
}
