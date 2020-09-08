package firedancer.assembly.types;

@:notNull @:forward
@:using(firedancer.assembly.types.ActorPropertyExtension)
abstract ActorProperty(Data) from Data {
	public static function create(
		type: ActorPropertyType,
		component: ActorPropertyComponent
	): ActorProperty {
		final data: Data = { type: type, component: component };
		return data;
	}

	@:op(A == B) inline function equals(other: ActorProperty): Bool
		return this.type == other.type && this.component == other.component;
}

@:structInit
private class Data {
	public final type: ActorPropertyType;
	public final component: ActorPropertyComponent;

	public inline function getValueType(): ValueType
		return component.getValueType();

	public function toString(): String {
		return switch type {
		case Position:
			switch component {
			case Vector: "position";
			case Length: "distance";
			case Angle: "bearing";
			}
		case Velocity:
			switch component {
			case Vector: "velocity";
			case Length: "speed";
			case Angle: "direction";
			}
		case ShotPosition:
			switch component {
			case Vector: "shot_position";
			case Length: "shot_distance";
			case Angle: "shot_bearing";
			}
		case ShotVelocity:
			switch component {
			case Vector: "shot_velocity";
			case Length: "shot_speed";
			case Angle: "shot_direction";
			}
		}
	}
}
