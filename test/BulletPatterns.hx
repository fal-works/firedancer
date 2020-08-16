import firedancer.types.EventHandler;
import firedancer.script.Api.*;
import firedancer.script.Ast;
import FdEndCode.*;

class BulletPatterns {
	static final aimPlayer = [
		aim().shotSpeed(5),
		loop([
			fire(),
			wait(8)
		])
	];

	static final spiral = [
		shot.velocity.set(5, 180),
		loop([
			fire(),
			shot.direction.add(12),
			wait(1)
		])
	];

	static final fireWithPattern = [
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

	static final fireBound = [
		shot.position.set(5, 180),
		loop([
			loop([
				fire(loop([
					distance.add(4),
					bearing.add(1),
					wait(1)
				])).bind(),
				shot.bearing.add(30),
			]).count(12),
			wait(30)
		]).count(4),
		end(VANISH) // Here the origin of children is set to (0, 0)
	];

	static final everyFrameTest = [
		shot.velocity.set(5, 180),
		everyFrame(shot.direction.add(4)),
		loop([
			fire(),
			wait(8)
		])
	];

	static final asyncTest = [
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

	static final parallelTest = [
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

	static final vanishTest = [
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

	static final randomTest = loop([
		shot.velocity.set(
			random.between(1, 4),
			180 + (random.angle.signed(45) * 1)
		),
		fire(),
		wait(2)
	]);

	static final randomIntTest = loop([
		shot.velocity.set(
			5,
			180 + random.int.signed(4) * 30
		),
		loop([
			fire(),
			wait(random.int.between(1, 5) * 4)
		]).count(random.int.between(1, 5)),
		wait(16)
	]);

	static final cnt = intVar("cnt");

	static final localVarTest = [
		shot.velocity.set(5, 180),
		cnt.let(),
		loop([
			shot.direction.set(cnt * 20),
			fire(),
			wait(4),
			cnt.increment()
		])
	];

	static final eventTest = loop([
		event(random.int.between(0, 10)),
		wait(60)
	]);

	static final dumpTest = [
		shot.velocity.set(5, 180),
		cnt.let(),
		loop([
			shot.direction.set(cnt * 20),
			fire(),
			debug(Dump),
			wait(4),
			cnt.increment()
		]).count(2)
	];

	static final bearingVar = angleVar("bearing");
	static final rotationVar = angleVar("rotation");

	static final transformTest = [
		loop([
			fire([
				bearingVar.let(),
				rotationVar.let(),
				loop([
					position.set(150, bearingVar)
						.rotate(rotationVar)
						.scale(1.0, 0.3),
					wait(1),
					bearingVar.add(4),
					rotationVar.add(2)
				])
			]).bind(),
			wait(6)
		]).count(24)
	];

	static final testAst = test(transformTest); // Change this for testing

	public static final programPackage = compile(["test" => testAst]);
	public static final testPattern = programPackage.getProgramByName("test");

	static function test(ast: Ast): Ast {
		return [
			// position.cartesian.add(-120, 0),
			velocity.set(10, 180),
			speed.set(0).frames(60),
			ast
		];
	}
}
