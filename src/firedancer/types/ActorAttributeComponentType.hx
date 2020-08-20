package firedancer.types;

/**
	Type of actor's attribute component to be operated.
**/
enum abstract ActorAttributeComponentType(Int) {
	final Vector;
	final Length;
	final Angle;

	public function toString(): String {
		return switch (cast this: ActorAttributeComponentType) {
			case Vector: "vector";
			case Length: "length";
			case Angle: "angle";
		}
	}
}
