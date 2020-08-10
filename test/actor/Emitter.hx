package actor;

import firedancer.types.PositionRef;

/**
	Object for emitting new bullet.
**/
@:ripper_verified
class Emitter extends firedancer.types.Emitter implements ripper.Data {
	final aosoa: ActorAosoa;

	override public function emit(
		x: Float,
		y: Float,
		vx: Float,
		vy: Float,
		fireType: Int,
		code: Maybe<Bytecode>,
		parentPosition: PositionRef
	): Void {
		aosoa.use(x, y, vx, vy, code, parentPosition);
	}
}
