import firedancer.script.Api.*;
import firedancer.script.Ast;
import FdEndCode.*;

class BulletPatterns {
	static final aimPlayer: Ast = [
		aim().shotSpeed(5),
		loop([
			fire(),
			wait(8)
		])
	];

	static final spiral: Ast = [
		shot.velocity.set(5, 180),
		loop([
			fire(),
			shot.direction.add(12),
			wait(1)
		])
	];

	static final fireWithPattern: Ast = [
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

	static final eachFrameTest: Ast = [
		shot.velocity.set(5, 180),
		eachFrame(shot.direction.add(4)),
		loop([
			fire(),
			wait(8)
		])
	];

	static final asyncTest: Ast = [
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

	static final parallelTest: Ast = [
		shot.velocity.set(5, 180),
		parallel([
			loop([
				fire(),
				wait(8)
			]),
			loop([
				fire(),
				shot.direction.add(32),
				wait(4)
			])
		])
	];

	static final vanishTest: Ast = [
		shot.velocity.set(5, 180),
		loop([
			fire([
				wait(30),
				end(VANISH)
			]),
			shot.direction.add(12),
			wait(1)
		])
	];

	static final randomTest: Ast = [
		shot.velocity.set(5, 180),
		loop([
			fire(),
			shot.direction.set(random.float(360)),
			wait(1)
		])
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

	static final testAst = test(randomTest); // Change this for testing

	public static final context = compile(["test" => testAst]);
	public static final testPattern = context.getBytecodeByName("test");

	static function test(ast: Ast): Ast {
		return [
			velocity.set(10, 180),
			speed.set(0).frames(60),
			ast
		];
	}
}
