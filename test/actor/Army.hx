package actor;

class Army {
	public final agents: ActorAosoa;
	public final bullets: ActorAosoa;

	public function new(
		agents: ActorAosoa,
		bullets: ActorAosoa
	) {
		this.agents = agents;
		this.bullets = bullets;
	}

	public function update() {
		this.agents.update();
		this.bullets.update();
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
