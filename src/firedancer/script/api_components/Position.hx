package firedancer.script.api_components;

import firedancer.types.Azimuth;
import firedancer.script.nodes.OperateAttribute;
import firedancer.script.nodes.OperateVector;

class Position {
	/**
		Provides functions for operating position in cartesian coordinates.
	**/
	public final cartesian = new CartesianPosition();

	public function new() {}

	/**
		Sets position to `(distance, bearing)`.
	**/
	public inline function set(distance: Float, bearing: Azimuth) {
		return new OperateVectorC(
			SetPositionC,
			distance * bearing.cos(),
			distance * bearing.sin()
		);
	}

	/**
		Adds a vector of `(distance, bearing)` to position.
	**/
	public inline function add(distance: Float, bearing: Azimuth) {
		return new OperateVectorC(
			AddPositionC,
			distance * bearing.cos(),
			distance * bearing.sin()
		);
	}
}

class CartesianPosition {
	public function new() {}

	/**
		Sets position to `(x, y)`.
	**/
	public inline function set(x: Float, y: Float) {
		return new OperateVectorC(SetPositionC, x, y);
	}

	/**
		Adds `(x, y)` to position.
	**/
	public inline function add(x: Float, y: Float) {
		return new OperateVectorC(AddPositionC, x, y);
	}
}

class Distance {
	public function new() {}

	/**
		Sets the length of position vector to `value`.
	**/
	public inline function set(value: Float) {
		return new OperateAttributeC(SetDistanceC, value);
	}

	/**
		Adds `value` to the length of position vector.
	**/
	public inline function add(value: Float) {
		return new OperateAttributeC(AddDistanceC, value);
	}
}

class Bearing {
	public function new() {}

	/**
		Sets the angle of position vector to `value`.
	**/
	public inline function set(value: Azimuth) {
		return new OperateAttributeC(SetBearingC, value.toRadians());
	}

	/**
		Adds `value` to the angle of position vector.
	**/
	public inline function add(value: Float) {
		return new OperateAttributeC(AddBearingC, value);
	}
}
