package firedancer.assembly.types;

@:structInit
@:using(firedancer.assembly.types.ActorPropertyExtension)
class ActorProperty {
	public static function create(
		type: ActorPropertyType,
		component: ActorPropertyComponent
	): ActorProperty {
		return { type: type, component: component };
	}

	public final type: ActorPropertyType;
	public final component: ActorPropertyComponent;

	public function toString(): String {
		return return switch type {
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