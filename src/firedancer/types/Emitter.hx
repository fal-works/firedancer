package firedancer.types;

import firedancer.bytecode.Bytecode;

/**
	Any object that can emit a new actor.
**/
interface Emitter {
	/**
		@param x X-component of the start point.
		@param y Y-component of the start point.
		@param vx X-component of initial velocity.
		@param vy Y-component of initial velocity.
		@param code The bytecode to run.
	**/
	function emit(
		x: Float,
		y: Float,
		vx: Float,
		vy: Float,
		code: Maybe<Bytecode>
	): Void;
}
