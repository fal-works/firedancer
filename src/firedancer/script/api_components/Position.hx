package firedancer.script.api_components;

/**
	Provides features for operating actor's position.
**/
class Position {
	/**
		Provides functions for operating position in cartesian coordinates.
	**/
	public final cartesian = new CartesianPosition();

	public function new() {}

	/**
		Sets position to `(distance, bearing)`.
	**/
	public inline function set(distance: FloatExpression, bearing: AzimuthExpression) {
		final vec: VecExpression = { length: distance, angle: bearing };
		return new OperateActor(Position, SetVector(vec));
	}

	/**
		Adds a vector of `(distance, bearing)` to position.
	**/
	public inline function add(distance: FloatExpression, bearing: AzimuthExpression) {
		final vec: VecExpression = { length: distance, angle: bearing };
		return new OperateActor(Position, AddVector(vec));
	}
}

/**
	Provides functions for operating actor's position in cartesian coordinates.
**/
class CartesianPosition {
	public function new() {}

	/**
		Sets position to `(x, y)`.
	**/
	public inline function set(x: FloatExpression, y: FloatExpression) {
		final vec: VecExpression = { x: x, y: y };
		return new OperateActor(Position, SetVector(vec));
	}

	/**
		Adds `(x, y)` to position.
	**/
	public inline function add(x: FloatExpression, y: FloatExpression) {
		final vec: VecExpression = { x: x, y: y };
		return new OperateActor(Position, AddVector(vec));
	}
}

/**
	Provides functions for operating the length of actor's position vector.
**/
class Distance {
	public function new() {}

	/**
		Sets the length of position vector to `value`.
	**/
	public inline function set(value: FloatExpression) {
		return new OperateActor(Position, SetLength(value));
	}

	/**
		Adds `value` to the length of position vector.
	**/
	public inline function add(value: FloatExpression) {
		return new OperateActor(Position, AddLength(value));
	}
}

/**
	Provides functions for operating the angle of actor's position vector.
**/
class Bearing {
	public function new() {}

	/**
		Sets the angle of position vector to `value`.
	**/
	public inline function set(value: AzimuthExpression) {
		return new OperateActor(Position, SetAngle(value));
	}

	/**
		Adds `value` to the angle of position vector.
	**/
	public inline function add(value: AzimuthDisplacementExpression) {
		return new OperateActor(Position, AddAngle(value));
	}
}
