package firedancer.script.api_components;

import firedancer.types.Azimuth;
import firedancer.script.nodes.OperateAttribute;
import firedancer.script.nodes.OperateVector;

class Velocity {
	/**
		Provides functions for operating velocity in cartesian coordinates.
	**/
	public final cartesian = new CartesianVelocity();

	public function new() {}

	/**
		Sets velocity to `(speed, direction)`.
	**/
	public inline function set(speed: Float, direction: Azimuth) {
		return new OperateVectorC(
			SetVelocityC,
			speed * direction.cos(),
			speed * direction.sin()
		);
	}

	/**
		Adds a vector of `(speed, direction)` to velocity.
	**/
	public inline function add(speed: Float, direction: Azimuth) {
		return new OperateVectorC(
			AddVelocityC,
			speed * direction.cos(),
			speed * direction.sin()
		);
	}
}

class CartesianVelocity {
	public function new() {}

	/**
		Sets velocity to `(vx, vy)`.
	**/
	public inline function set(vx: Float, vy: Float) {
		return new OperateVectorC(SetVelocityC, vx, vy);
	}

	/**
		Adds `(x, y)` to velocity.
	**/
	public inline function add(x: Float, y: Float) {
		return new OperateVectorC(AddVelocityC, x, y);
	}
}

class Speed {
	public function new() {}

	/**
		Sets the length of velocity vector to `value`.
	**/
	public inline function set(value: Float) {
		return new OperateAttributeC(SetSpeedC, value);
	}

	/**
		Adds `value` to the length of velocity vector.
	**/
	public inline function add(value: Float) {
		return new OperateAttributeC(AddSpeedC, value);
	}
}

class Direction {
	public function new() {}

	/**
		Sets the angle of velocity vector to `value`.
	**/
	public inline function set(value: Azimuth) {
		return new OperateAttributeC(SetDirectionC, value.toRadians());
	}

	/**
		Adds `value` to the angle of velocity vector.
	**/
	public inline function add(value: Float) {
		return new OperateAttributeC(AddDirectionC, value);
	}
}
