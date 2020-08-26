package actor;

import firedancer.bytecode.PositionRef;

/**
	Object for emitting new bullet.
**/
@:ripper_verified
class Emitter extends firedancer.bytecode.Emitter implements ripper.Data {
	final aosoa: ActorAosoa;

	override public function emit(
		x: Float,
		y: Float,
		vx: Float,
		vy: Float,
		fireCode: Int,
		program: Maybe<Program>,
		originPositionRef: Maybe<PositionRef>
	): Void {
		aosoa.use(x, y, vx, vy, program, originPositionRef);
	}
}
