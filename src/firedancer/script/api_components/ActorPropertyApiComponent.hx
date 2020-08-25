package firedancer.script.api_components;

import firedancer.assembly.types.ActorProperty;

/**
	Base class for API component classes related to `ActorProperty`.
**/
class ActorPropertyApiComponent {
	final property: ActorProperty;

	public function new(property: ActorProperty)
		this.property = property;
}
