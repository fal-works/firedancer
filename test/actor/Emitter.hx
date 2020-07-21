package actor;

/**
	Object for emitting new bullet.
**/
@:ripper_verified
class Emitter implements ripper.Data implements firedancer.types.Emitter {
	final aosoa: ActorAosoa;

	public inline function emit(
		x: Float,
		y: Float,
		vx: Float,
		vy: Float,
		code: Maybe<Bytecode>
	): Void {
		aosoa.use(x, y, vx, vy, code);
	}
}
