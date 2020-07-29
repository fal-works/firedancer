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
	public inline function set(speed: FloatArgument, direction: AzimuthArgument) {
		final vec: VecArgument = { length: speed, angle: direction };
		return new OperateActor(ShotVelocity, SetVector(vec));
	}

	/**
		Adds a vector of `(speed, direction)` to shot velocity.
	**/
	public inline function add(speed: FloatArgument, direction: AzimuthArgument) {
		final vec: VecArgument = { length: speed, angle: direction };
		return new OperateActor(ShotVelocity, AddVector(vec));
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
	public inline function set(vx: FloatArgument, vy: FloatArgument) {
		final vec: VecArgument = { x: vx, y: vy };
		return new OperateActor(ShotVelocity, SetVector(vec));
	}

	/**
		Adds `(vx, vy)` to shot velocity.
	**/
	public inline function add(vx: FloatArgument, vy: FloatArgument) {
		final vec: VecArgument = { x: vx, y: vy };
		return new OperateActor(ShotVelocity, AddVector(vec));
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
	public inline function set(value: FloatArgument) {
		return new OperateActor(ShotVelocity, SetLength(value));
	}

	/**
		Adds `value` to the length of shot velocity vector.
	**/
	public inline function add(value: FloatArgument) {
		return new OperateActor(ShotVelocity, AddLength(value));
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
	public inline function set(value: AzimuthArgument) {
		return new OperateActor(ShotVelocity, SetAngle(value));
	}

	/**
		Adds `value` to the angle of shot velocity vector.
	**/
	public inline function add(value: AzimuthDisplacementArgument) {
		return new OperateActor(ShotVelocity, AddAngle(value));
	}
}