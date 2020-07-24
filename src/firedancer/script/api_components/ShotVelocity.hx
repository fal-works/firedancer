package firedancer.script.api_components;

import firedancer.types.Azimuth;
import firedancer.script.nodes.OperateAttribute;
import firedancer.script.nodes.OperateVector;

class ShotVelocity {
	/**
		Provides functions for operating shot velocity in cartesian coordinates.
	**/
	public final cartesian = new CartesianShotVelocity();

	public function new() {}

	/**
		Sets shot velocity to a vector of `(speed, direction)`.
	**/
	public inline function set(speed: Float, direction: Azimuth) {
		return new OperateVectorC(
			SetShotVelocityC,
			speed * direction.cos(),
			speed * direction.sin()
		);
	}

	/**
		Adds a vector of `(speed, direction)` to shot velocity.
	**/
	public inline function add(speed: Float, direction: Azimuth) {
		return new OperateVectorC(
			AddShotVelocityC,
			speed * direction.cos(),
			speed * direction.sin()
		);
	}
}

class CartesianShotVelocity {
	public function new() {}

	/**
		Sets shot velocity to `(x, y)`.
	**/
	public inline function set(x: Float, y: Float) {
		return new OperateVectorC(SetShotVelocityC, x, y);
	}

	/**
		Adds `(x, y)` to shot velocity.
	**/
	public inline function add(x: Float, y: Float) {
		return new OperateVectorC(AddShotVelocityC, x, y);
	}
}

class ShotSpeed {
	public function new() {}

	/**
		Sets the length of shot velocity vector to `value`.
	**/
	public inline function set(value: Float) {
		return new OperateAttributeC(SetShotSpeedC, value);
	}

	/**
		Adds `value` to the length of shot velocity vector.
	**/
	public inline function add(value: Float) {
		return new OperateAttributeC(AddShotSpeedC, value);
	}
}

class ShotDirection {
	public function new() {}

	/**
		Sets the angle of shot velocity vector to `value`.
	**/
	public inline function set(value: Azimuth) {
		return new OperateAttributeC(SetShotDirectionC, value.toRadians());
	}

	/**
		Adds `value` to the angle of shot velocity vector.
	**/
	public inline function add(value: Float) {
		return new OperateAttributeC(AddShotDirectionC, value);
	}
}
