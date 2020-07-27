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
		speed: Float,
		direction: Float,
		fdCode: Bytecode
	): Void {
		this.agents.emit(x, y, speed, direction, fdCode);
	}

	public inline function newBullet(
		x: Float,
		y: Float,
		speed: Float,
		direction: Float
	): Void {
		this.bullets.emit(x, y, speed, direction, Maybe.none());
	}
}
