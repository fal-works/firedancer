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
		@param fireType Any integer value to branch the emission process
		(e.g. switch graphics of the actor to be emitted).
		@param code The bytecode to run.
		@param parentPositionRef The reference to the position of the parent actor
		(to which the new actor' position should be bound), or a zero-position reference
		if the position does not need to be bound.
	**/
	public function emit(
		x: Float,
		y: Float,
		vx: Float,
		vy: Float,
		fireType: Int,
		code: Maybe<Bytecode>,
		parentPositionRef: PositionRef
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
		fireType: Int,
		code: Maybe<Bytecode>,
		parentPositionRef: PositionRef
	): Void {}
}
