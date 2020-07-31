package firedancer.types;

import sneaker.exception.NotOverriddenException;
import firedancer.bytecode.Bytecode;

/**
	Any object that can emit a new actor.
**/
class Emitter {
	/**
		Emits an actor.

		This method must be overridden by an user-defined sub-class.

		@param x X-component of the initial position.
		@param y Y-component of the initial position.
		@param vx X-component of initial velocity.
		@param vy Y-component of initial velocity.
		@param code The bytecode to run.
	**/
	public function emit(
		x: Float,
		y: Float,
		vx: Float,
		vy: Float,
		code: Maybe<Bytecode>
	): Void {
		throw new NotOverriddenException();
	}
}

/**
	Null object class for `Emitter`.
**/
class NullEmitter extends Emitter {
	public function new() {}

	override public function emit(
		x: Float,
		y: Float,
		vx: Float,
		vy: Float,
		code: Maybe<Bytecode>
	): Void {}
}
