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

	static final aimPlayer: Ast = [
		position.cartesian.add(-200, 0),
		velocity.set(10, 180),
		speed.set(0).frames(60),
		aimPlayerBody
	];

	static final spiralBody: Ast = [
		shot.velocity.set(5, 180),
		loop([
			fire(),
			shot.direction.add(12),
			wait(1)
		])
	];

	static final spiral: Ast = [
		velocity.set(10, 180),
		speed.set(0).frames(60),
		spiralBody
	];

	static final fireWithPatternBody: Ast = [
		shot.velocity.set(5, 180),
		loop([
			fire([
				wait(30),
				direction.add(-120)
			]),
			shot.direction.add(36),
			wait(8)
		])
	];

	static final fireWithPattern: Ast = [
		velocity.set(10, 180),
		speed.set(0).frames(60),
		fireWithPatternBody
	];

	static final eachFrameTestBody: Ast = [
		shot.velocity.set(5, 180),
		eachFrame(shot.direction.add(4)),
		loop([
			fire(),
			wait(8)
		])
	];

	static final eachFrameTest: Ast = [
		velocity.set(10, 180),
		speed.set(0).frames(60),
		eachFrameTestBody
	];

	static final asyncTestBody: Ast = [
		shot.velocity.set(5, 180),
		async(
			loop([
				fire(),
				wait(8)
			])
		),
		loop([
			fire(),
			shot.direction.add(32),
			wait(4)
		])
	];

	static final asyncTest: Ast = [
		velocity.set(10, 180),
		speed.set(0).frames(60),
		asyncTestBody
	];

	static final sandbox: Ast = loop([
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
	]).count(2);

	static final testAst = asyncTest; // Change this for testing

	public static final context = compile(["test" => testAst]);
	public static final testPattern = context.getBytecodeByName("test");
}
