import firedancer.vm.Program;
import firedancer.vm.PositionRef;
import actor.ActorAosoa;

/**
	Object for emitting new bullet.
**/
class Emitter extends firedancer.vm.Emitter {
	var aosoa: ActorAosoa;

	public function new()
		this.aosoa = @:nullSafety(Off) null;

	public function initialize(aosoa: ActorAosoa): Void
		this.aosoa = aosoa;

	override public function emit(
		x: Float,
		y: Float,
		vx: Float,
		vy: Float,
		fireCode: Int,
		program: Maybe<Program>,
		originPositionRef: Maybe<PositionRef>
	): Void {
		#if debug
		if (this.aosoa == null) throw "Emitter not initialized.";
		#end

		this.aosoa.use(x, y, vx, vy, program, originPositionRef);
	}
}
