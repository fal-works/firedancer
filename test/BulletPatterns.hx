import firedancer.script.Api.*;

class BulletPatterns {
	public static final typeA = compile([
		velocity.set(10, 180),
		speed.set(0).frames(60),
		shot.velocity.set(5, 180),
		loop([
			fire(),
			shot.direction.add(6),
			wait(1)
		])
	]);
}
