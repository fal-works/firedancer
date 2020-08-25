package firedancer.assembly.types;

/**
	Type of actor's property component to be operated.
**/
enum abstract ActorPropertyComponent(Int) {
	final Vector;
	final Length;
	final Angle;
	public function toString(): String {
		return switch (cast this : ActorPropertyComponent) {
		case Vector: "vector";
		case Length: "length";
		case Angle: "angle";
		}
	}
}
