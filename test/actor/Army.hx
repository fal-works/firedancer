package actor;

class Army implements ripper.Data {
	public final agents: ActorAosoa;
	public final bullets: ActorAosoa;
	public final targetPositionRef: PositionRef;

	public function update() {
		this.agents.update(this.targetPositionRef);
		this.bullets.update(this.targetPositionRef);
	}

	public function synchronize() {
		this.agents.synchronize();
		this.bullets.synchronize();
	}

	public inline function newAgent(
		x: Float,
		y: Float,
		vx: Float,
		vy: Float,
		fdProgram: Maybe<Program>
	): Void {
		this.agents.use(x, y, vx, vy, fdProgram, Maybe.none());
	}

	public inline function newBullet(
		x: Float,
		y: Float,
		vx: Float,
		vy: Float,
		fdProgram: Maybe<Program>
	): Void {
		this.bullets.use(x, y, vx, vy, fdProgram, Maybe.none());
	}
}
