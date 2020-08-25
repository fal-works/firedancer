import firedancer.bytecode.Program;
import firedancer.bytecode.ProgramPackage;
import firedancer.script.Api.*;
import firedancer.script.Ast;
import FdEndCode.*;

class BulletPatterns {
	public function new() {
		final aimPlayer = [
			aim().shotSpeed(5),
			loop([
				fire(),
				wait(8)
			])
		];

		final spiral = [
			shot.velocity.set(5, 180),
			loop([
				fire(),
				shot.direction.add(12),
				wait(1)
			])
		];

		final fireWithPattern = [
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

		final fireBound = [
			shot.position.set(5, 180),
			rep(4, [
				rep(12, [
					fire(loop([
						distance.add(4),
						bearing.add(1),
						wait(1)
					])).bind(),
					shot.bearing.add(30),
				]),
				wait(30)
			]),
			end(VANISH) // Here the origin of children is set to (0, 0)
		];

		final everyFrameTest = [
			shot.velocity.set(5, 180),
			everyFrame(shot.direction.add(4)),
			loop([
				fire(),
				wait(8)
			])
		];

		final asyncTest = [
			shot.velocity.set(5, 180),
			async(loop([
				fire(),
				wait(8)
			])),
			loop([
				fire(),
				shot.direction.add(32),
				wait(4)
			])
		];

		final parallelTest = [
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

		final vanishTest = [
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

		final randomTest = loop([
			shot.velocity.set(
				random.between(1, 4),
				180 + (random.angle.signed(45) * 1)
			),
			fire(),
			wait(2)
		]);

		final randomIntTest = loop([
			shot.velocity.set(
				5,
				180 + random.int.signed(4) * 30
			),
			rep(random.int.between(1, 5), [
				fire(),
				wait(random.int.between(1, 5) * 4)
			]),
			wait(16)
		]);

		final cnt = intVar("cnt");

		final localVarTest = [
			shot.velocity.set(5, 180),
			cnt.let(),
			loop([
				shot.direction.set(cnt * 20),
				fire(),
				wait(4),
				cnt.increment()
			])
		];

		final eventTest = loop([
			event(random.int.between(0, 10)),
			wait(60)
		]);

		final dumpTest = [
			shot.velocity.set(5, 180),
			cnt.let(),
			rep(2, [
				shot.direction.set(cnt * 20),
				fire(),
				debug(Dump),
				wait(4),
				cnt.increment()
			])
		];

		final bearingVar = angleVar("bearing");
		final rotationVar = angleVar("rotation");

		final transformTest = [
			rep(24, [
				fire([
					bearingVar.let(),
					rotationVar.let(),
					loop([
						position.set(150, bearingVar).rotate(rotationVar).scale(1.0, 0.3),
						wait(1),
						bearingVar.add(4),
						rotationVar.add(2)
					])
				]).bind(),
				wait(6)
			])
		];

		final sinCosTest = [
			rep(16, [
				fire([
					bearingVar.let(),
					loop([
						position.cartesian.set(
							300 * cos(bearingVar),
							60 * sin(bearingVar)
						),
						wait(1),
						bearingVar.add(4)
					])
				]).bind(),
				wait(4)
			])
		];

		final readActorProp = [
			shot.velocity.set(4, 180),
			loop([
				fire(),
				shot.velocity.set(shot.speed, 180 + random.angle.grouping(90)),
				wait(4)
			])
		];

		final testAst = test(readActorProp); // Change this for testing

		this.programPackage = compile(["test" => testAst]);
		this.testPattern = this.programPackage.getProgramByName("test");
	}

	public final programPackage: ProgramPackage;
	public final testPattern: Program;

	function test(ast: Ast): Ast {
		return [
			// position.cartesian.add(-120, 0),
			velocity.set(10, 180),
			speed.add(-10).frames(60),
			ast
		];
	}
}
