package firedancer.assembly.types;

enum abstract TargetProperty(Int) {
	final Position;
	final X;
	final Y;
	final AngleFromShotPosition;

	/**
		@return `String` representation of `this`.
	**/
	public function toString(): String {
		return switch (cast this : TargetProperty) {
		case Position: "position";
		case X: "x";
		case Y: "y";
		case AngleFromShotPosition: "angle_from_shot_position";
		}
	}

	public function getType(): ValueType {
		return switch (cast this : TargetProperty) {
		case Position: Vec;
		case X | Y: Float;
		case AngleFromShotPosition: Float;
		}
	}
}
