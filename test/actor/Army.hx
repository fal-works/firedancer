package actor;

class Army implements ripper.Data {
	public final agents: ActorAosoa;
	public final bullets: ActorAosoa;
	public final targetPosition: Point;

	public function update() {
		this.agents.update(this.targetPosition);
		this.bullets.update(this.targetPosition);
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
		fdCode: Maybe<Bytecode>
	): Void {
		this.agents.use(x, y, vx, vy, fdCode);
	}

	public inline function newBullet(
		x: Float,
		y: Float,
		vx: Float,
		vy: Float,
		fdCode: Maybe<Bytecode>
	): Void {
		this.bullets.use(x, y, vx, vy, fdCode);
	}
}
