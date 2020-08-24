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
	public inline function set(distance: FloatExpression, bearing: AngleExpression) {
		final vec: VecExpression = { length: distance, angle: bearing };
		return new SetActorVector(ShotPosition, vec);
	}

	/**
		Adds a vector of `(distance, bearing)` to shot position.
	**/
	public inline function add(distance: FloatExpression, bearing: AngleExpression) {
		final vec: VecExpression = { length: distance, angle: bearing };
		return new AddActorProperty(ShotPosition, AddVector(vec));
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
	public inline function set(x: FloatExpression, y: FloatExpression) {
		final vec: VecExpression = { x: x, y: y };
		return new SetActorVector(ShotPosition, vec);
	}

	/**
		Adds `(x, y)` to shot position.
	**/
	public inline function add(x: FloatExpression, y: FloatExpression) {
		final vec: VecExpression = { x: x, y: y };
		return new AddActorProperty(ShotPosition, AddVector(vec));
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
	public inline function set(value: FloatExpression) {
		return new SetActorProperty(ShotPosition, SetLength(value));
	}

	/**
		Adds `value` to the length of shot position vector.
	**/
	public inline function add(value: FloatExpression) {
		return new AddActorProperty(ShotPosition, AddLength(value));
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
	public inline function set(value: AngleExpression) {
		return new SetActorProperty(ShotPosition, SetAngle(value));
	}

	/**
		Adds `value` to the angle of shot position vector.
	**/
	public inline function add(value: AngleExpression) {
		return new AddActorProperty(ShotPosition, AddAngle(value));
	}
}
