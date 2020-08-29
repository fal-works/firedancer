package firedancer.script.api_components;

import firedancer.script.api_components.ShotPosition;
import firedancer.script.api_components.ShotVelocity;

class Shot {
	public function new() {}

	/**
		Provides functions for operating shot position.
	**/
	public final position = new ShotPosition();

	/**
		Provides functions for operating the length of shot position vector.
	**/
	public final distance = new ShotDistance();

	/**
		Provides functions for operating the angle of shot position vector.
	**/
	public final bearing = new ShotBearing();

	/**
		Provides functions for operating shot velocity.
	**/
	public final velocity = new ShotVelocity();

	/**
		Provides functions for operating the length of shot velocity vector.
	**/
	public final speed = new ShotSpeed();

	/**
		Provides functions for operating the angle of shot velocity vector.
	**/
	public final direction = new ShotDirection();

	/**
		Angle from the current shot position to the current target position.
	**/
	public final angleToTarget = AngleExpression.fromEnum(Runtime(Inst(GetTarget(AngleFromShotPosition))));
}
