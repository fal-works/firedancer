package firedancer.types;

/**
	Type of actor's attribute to be operated.
**/
enum abstract ActorAttributeType(Int) {
	final Position;
	final Velocity;
	final ShotPosition;
	final ShotVelocity;
}
