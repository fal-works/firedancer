package firedancer.script.api_components;

/**
	Provides features for operating actor's velocity.
**/
class Velocity {
	/**
		Provides functions for operating velocity in cartesian coordinates.
	**/
	public final cartesian = new CartesianVelocity();

	public function new() {}

	/**
		Sets velocity to `(speed, direction)`.
	**/
	public inline function set(speed: FloatExpression, direction: AngleExpression) {
		final vec: VecExpression = { length: speed, angle: direction };
		return new SetActorVector(Velocity, vec);
	}

	/**
		Adds a vector of `(speed, direction)` to velocity.
	**/
	public inline function add(speed: FloatExpression, direction: AngleExpression) {
		final vec: VecExpression = { length: speed, angle: direction };
		return new AddActorAttribute(Velocity, AddVector(vec));
	}
}

/**
	Provides functions for operating actor's velocity in cartesian coordinates.
**/
class CartesianVelocity {
	public function new() {}

	/**
		Sets velocity to `(vx, vy)`.
	**/
	public inline function set(vx: FloatExpression, vy: FloatExpression) {
		final vec: VecExpression = { x: vx, y: vy };
		return new SetActorVector(ShotVelocity, vec);
	}

	/**
		Adds `(vx, vy)` to velocity.
	**/
	public inline function add(vx: FloatExpression, vy: FloatExpression) {
		final vec: VecExpression = { x: vx, y: vy };
		return new AddActorAttribute(ShotVelocity, AddVector(vec));
	}
}

/**
	Provides functions for operating the length of actor's velocity vector.
**/
class Speed {
	public function new() {}

	/**
		Sets the length of velocity vector to `value`.
	**/
	public inline function set(value: FloatExpression) {
		return new SetActorAttribute(Velocity, SetLength(value));
	}

	/**
		Adds `value` to the length of velocity vector.
	**/
	public inline function add(value: FloatExpression) {
		return new AddActorAttribute(Velocity, AddLength(value));
	}
}

/**
	Provides functions for operating the angle of actor's velocity vector.
**/
class Direction {
	public function new() {}

	/**
		Sets the angle of velocity vector to `value`.
	**/
	public inline function set(value: AngleExpression) {
		return new SetActorAttribute(Velocity, SetAngle(value));
	}

	/**
		Adds `value` to the angle of velocity vector.
	**/
	public inline function add(value: AngleExpression) {
		return new AddActorAttribute(Velocity, AddAngle(value));
	}
}
