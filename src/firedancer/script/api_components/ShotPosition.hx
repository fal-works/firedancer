package firedancer.script.api_components;

/**
	Provides features for operating actor's shot position.
**/
class ShotPosition {
	/**
		Provides functions for operating shot position in cartesian coordinates.
	**/
	public final cartesian = new CartesianShotPosition();

	public function new() {}

	/**
		Sets shot position to a vector of `(distance, bearing)`.
	**/
	public inline function set(distance: FloatArgument, bearing: Azimuth) {
		final vec: VecArgument = { length: distance, angle: bearing };
		return new OperateActor(ShotPosition, SetVector(vec));
	}

	/**
		Adds a vector of `(distance, bearing)` to shot position.
	**/
	public inline function add(distance: FloatArgument, bearing: Azimuth) {
		final vec: VecArgument = { length: distance, angle: bearing };
		return new OperateActor(ShotPosition, AddVector(vec));
	}
}

/**
	Provides functions for operating actor's shot position in cartesian coordinates.
**/
class CartesianShotPosition {
	public function new() {}

	/**
		Sets shot position to `(x, y)`.
	**/
	public inline function set(x: FloatArgument, y: FloatArgument) {
		final vec: VecArgument = { x: x, y: y };
		return new OperateActor(ShotPosition, SetVector(vec));
	}

	/**
		Adds `(x, y)` to shot position.
	**/
	public inline function add(x: FloatArgument, y: FloatArgument) {
		final vec: VecArgument = { x: x, y: y };
		return new OperateActor(ShotPosition, AddVector(vec));
	}
}

/**
	Provides functions for operating the length of actor's shot position vector.
**/
class ShotDistance {
	public function new() {}

	/**
		Sets the length of shot position vector to `value`.
	**/
	public inline function set(value: FloatArgument) {
		return new OperateActor(ShotPosition, SetLength(value));
	}

	/**
		Adds `value` to the length of shot position vector.
	**/
	public inline function add(value: FloatArgument) {
		return new OperateActor(ShotPosition, AddLength(value));
	}
}

/**
	Provides functions for operating the angle of actor's shot position vector.
**/
class ShotBearing {
	public function new() {}

	/**
		Sets the angle of shot position vector to `value`.
	**/
	public inline function set(value: Azimuth) {
		return new OperateActor(ShotPosition, SetAngle(value));
	}

	/**
		Adds `value` to the angle of shot position vector.
	**/
	public inline function add(value: FloatArgument) {
		return new OperateActor(ShotPosition, AddAngle(value));
	}
}
