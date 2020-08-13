package firedancer.types;

import sneaker.exception.NotOverriddenException;
import firedancer.bytecode.Thread;

/**
	Object for defining the behavior of various events when they are called.
**/
class EventHandler {
	/**
		Called every time a global event is invoked.

		This method must be overridden by an user-defined sub-class.

		@param globalEventCode Any user-defined value for branching the process (e.g. play sound).
	**/
	public function onGlobalEvent(globalEventCode: Int): Void {
		throw new NotOverriddenException();
	}

	/**
		Called every time a local event is invoked.

		This method must be overridden by an user-defined sub-class.

		@param localEventCode Any user-defined value for branching the process (e.g. generate graphics effect).
		@param x The x-component of the actor's position relative from the origin.
		@param y The y-component of the actor's position relative from the origin.
		@param thread The thread in which the event was invoked.
		@param originPositionRef Reference to the origin position.
		@param targetpositionRef Reference to the target position.
	**/
	public function onLocalEvent(
		localEventCode: Int,
		x: Float,
		y: Float,
		thread: Thread,
		originPositionRef: Maybe<PositionRef>,
		targetpositionRef: PositionRef
	): Void {
		throw new NotOverriddenException();
	}
}

/**
	Null object for `EventHandler`.
**/
class NullEventHandler extends EventHandler {
	public function new() {}

	override public function onGlobalEvent(globalEventCode: Int): Void {}

	override public function onLocalEvent(
		localEventCode: Int,
		x: Float,
		y: Float,
		thread: Thread,
		originPositionRef: Maybe<PositionRef>,
		targetpositionRef: PositionRef
	): Void {}
}
