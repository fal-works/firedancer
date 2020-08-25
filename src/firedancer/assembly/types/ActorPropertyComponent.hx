package firedancer.assembly.types;

/**
	Type of actor's property component to be operated.
**/
enum abstract ActorPropertyComponent(Int) {
	final Vector;
	final Length;
	final Angle;

	/**
		@return The corresponding `ValueType`.
	**/
	public function getValueType(): ValueType {
		return switch (cast this : ActorPropertyComponent) {
		case Vector: Vec;
		case Length | Angle: Float;
		}
	}

	public function toString(): String {
		return switch (cast this : ActorPropertyComponent) {
		case Vector: "vector";
		case Length: "length";
		case Angle: "angle";
		}
	}
}
