package firedancer.script.api_components;

import firedancer.types.Azimuth;
import firedancer.script.nodes.OperateAttribute;
import firedancer.script.nodes.OperateVector;

class ShotPosition {
	/**
		Provides functions for operating shot position in cartesian coordinates.
	**/
	public final cartesian = new CartesianShotPosition();

	public function new() {}

	/**
		Sets shot position to a vector of `(distance, bearing)`.
	**/
	public inline function set(distance: Float, bearing: Azimuth) {
		return new OperateVectorC(
			SetShotPositionC,
			distance * bearing.cos(),
			distance * bearing.sin()
		);
	}

	/**
		Adds a vector of `(distance, bearing)` to shot position.
	**/
	public inline function add(distance: Float, bearing: Azimuth) {
		return new OperateVectorC(
			AddShotPositionC,
			distance * bearing.cos(),
			distance * bearing.sin()
		);
	}
}

class CartesianShotPosition {
	public function new() {}

	/**
		Sets shot position to `(x, y)`.
	**/
	public inline function set(x: Float, y: Float) {
		return new OperateVectorC(SetShotPositionC, x, y);
	}

	/**
		Adds `(x, y)` to shot position.
	**/
	public inline function add(x: Float, y: Float) {
		return new OperateVectorC(AddShotPositionC, x, y);
	}
}

class ShotDistance {
	public function new() {}

	/**
		Sets the length of shot position vector to `value`.
	**/
	public inline function set(value: Float) {
		return new OperateAttributeC(SetShotDistanceC, value);
	}

	/**
		Adds `value` to the length of shot position vector.
	**/
	public inline function add(value: Float) {
		return new OperateAttributeC(AddShotDistanceC, value);
	}
}

class ShotBearing {
	public function new() {}

	/**
		Sets the angle of shot position vector to `value`.
	**/
	public inline function set(value: Azimuth) {
		return new OperateAttributeC(SetShotBearingC, value.toRadians());
	}

	/**
		Adds `value` to the angle of shot position vector.
	**/
	public inline function add(value: Float) {
		return new OperateAttributeC(AddShotBearingC, value);
	}
}
