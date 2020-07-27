import firedancer.script.Api.*;
import firedancer.script.Ast;

class BulletPatterns {
	static final aimPlayerBody: Ast = [
		aim().shotSpeed(5),
		loop([
			fire(),
			wait(8)
		])
	];

	public static final aimPlayer = compile([
		position.cartesian.add(-200, 0),
		velocity.set(10, 180),
		speed.set(0).frames(60),
		aimPlayerBody
	]);

	static final spiral = compile([
		velocity.set(10, 180),
		speed.set(0).frames(60),
		shot.velocity.set(5, 180),
		loop([
			fire(),
			shot.direction.add(6),
			wait(1)
		])
	]);

	static final sandbox = compile(loop([
		wait(30),
		shot.velocity.set(5, 180),
		loop([fire(), wait(4)]).count(10),
		shot.direction.set(15).frames(10),
		loop([fire(), wait(4)]).count(30),
		velocity.set(0, 0),
		position.cartesian.set(100, 100).frames(30),
		position.cartesian.set(200, 200).frames(30),
		wait(30),
		velocity.set(5, 150),
		wait(30),
		velocity.set(5, 210)
	]).count(2));

	public static final testPattern = aimPlayer;
}
