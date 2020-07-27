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
	public inline function set(speed: FloatArgument, direction: AzimuthArgument) {
		final vec: VecArgument = { length: speed, angle: direction };
		return new OperateActor(Velocity, SetVector(vec));
	}

	/**
		Adds a vector of `(speed, direction)` to velocity.
	**/
	public inline function add(speed: FloatArgument, direction: AzimuthArgument) {
		final vec: VecArgument = { length: speed, angle: direction };
		return new OperateActor(Velocity, AddVector(vec));
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
	public inline function set(vx: FloatArgument, vy: FloatArgument) {
		final vec: VecArgument = { x: vx, y: vy };
		return new OperateActor(ShotVelocity, SetVector(vec));
	}

	/**
		Adds `(vx, vy)` to velocity.
	**/
	public inline function add(vx: FloatArgument, vy: FloatArgument) {
		final vec: VecArgument = { x: vx, y: vy };
		return new OperateActor(ShotVelocity, AddVector(vec));
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
	public inline function set(value: FloatArgument) {
		return new OperateActor(Velocity, SetLength(value));
	}

	/**
		Adds `value` to the length of velocity vector.
	**/
	public inline function add(value: FloatArgument) {
		return new OperateActor(Velocity, AddLength(value));
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
	public inline function set(value: AzimuthArgument) {
		return new OperateActor(Velocity, SetAngle(value));
	}

	/**
		Adds `value` to the angle of velocity vector.
	**/
	public inline function add(value: AzimuthDisplacementArgument) {
		return new OperateActor(Velocity, AddAngle(value));
	}
}
