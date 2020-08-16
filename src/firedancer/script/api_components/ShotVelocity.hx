package firedancer.script.api_components;

/**
	Provides features for operating actor's shot velocity.
**/
class ShotVelocity {
	/**
		Provides functions for operating shot velocity in cartesian coordinates.
	**/
	public final cartesian = new CartesianShotVelocity();

	public function new() {}

	/**
		Sets shot velocity to a vector of `(speed, direction)`.
	**/
	public inline function set(speed: FloatExpression, direction: AngleExpression) {
		final vec: VecExpression = { length: speed, angle: direction };
		return new SetActorVector(ShotVelocity, vec);
	}

	/**
		Adds a vector of `(speed, direction)` to shot velocity.
	**/
	public inline function add(speed: FloatExpression, direction: AngleExpression) {
		final vec: VecExpression = { length: speed, angle: direction };
		return new AddActorAttribute(ShotVelocity, AddVector(vec));
	}
}

/**
	Provides functions for operating actor's shot velocity in cartesian coordinates.
**/
class CartesianShotVelocity {
	public function new() {}

	/**
		Sets shot velocity to `(vx, vy)`.
	**/
	public inline function set(vx: FloatExpression, vy: FloatExpression) {
		final vec: VecExpression = { x: vx, y: vy };
		return new SetActorVector(ShotVelocity, vec);
	}

	/**
		Adds `(vx, vy)` to shot velocity.
	**/
	public inline function add(vx: FloatExpression, vy: FloatExpression) {
		final vec: VecExpression = { x: vx, y: vy };
		return new AddActorAttribute(ShotVelocity, AddVector(vec));
	}
}

/**
	Provides functions for operating the length of actor's shot velocity vector.
**/
class ShotSpeed {
	public function new() {}

	/**
		Sets the length of shot velocity vector to `value`.
	**/
	public inline function set(value: FloatExpression) {
		return new SetActorAttribute(ShotVelocity, SetLength(value));
	}

	/**
		Adds `value` to the length of shot velocity vector.
	**/
	public inline function add(value: FloatExpression) {
		return new AddActorAttribute(ShotVelocity, AddLength(value));
	}
}

/**
	Provides functions for operating the angle of actor's shot velocity vector.
**/
class ShotDirection {
	public function new() {}

	/**
		Sets the angle of shot velocity vector to `value`.
	**/
	public inline function set(value: AngleExpression) {
		return new SetActorAttribute(ShotVelocity, SetAngle(value));
	}

	/**
		Adds `value` to the angle of shot velocity vector.
	**/
	public inline function add(value: AngleExpression) {
		return new AddActorAttribute(ShotVelocity, AddAngle(value));
	}
}
