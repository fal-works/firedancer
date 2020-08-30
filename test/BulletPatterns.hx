import firedancer.vm.ProgramPackage;
import firedancer.script.Api.*;
import firedancer.script.ApiEx.*;
import firedancer.script.Ast;

class BulletPatterns {
	public static function aimPlayer(): ProgramPackage {
		final main = [
			aim().shotSpeed(5),
			loop([
				fire(),
				wait(8)
			])
		];

		return asMain(main);
	}

	public static function spiral(): ProgramPackage {
		final main = [
			shot.velocity.set(5, 180),
			loop([
				fire(),
				shot.direction.add(12),
				wait(1)
			])
		];

		return asMain(main);
	}

	public static function fireWithPattern(): ProgramPackage {
		final main = [
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

		return asMain(main);
	}

	public static function fireBound(): ProgramPackage {
		final main = [
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
			vanish() // Here the origin of children is set to (0, 0)
		];

		return asMain(main);
	}

	public static function everyFrameTest(): ProgramPackage {
		final main = [
			shot.velocity.set(5, 180),
			everyFrame(shot.direction.add(4)),
			loop([
				fire(),
				wait(8)
			])
		];

		return asMain(main);
	}

	public static function asyncTest(): ProgramPackage {
		final main = [
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

		return asMain(main);
	}
	public static function parallelTest(): ProgramPackage {
		final main = [
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

		return asMain(main);
	}

	public static function vanishTest(): ProgramPackage {
		final main = [
			shot.velocity.set(5, 180),
			loop([
				fire([
					wait(30),
					vanish()
				]),
				shot.direction.add(12),
				wait(1)
			])
		];

		return asMain(main);
	}

	public static function randomTest(): ProgramPackage {
		final main = [
			shot.velocity.set(
				random.between(1, 4),
				180 + (random.angle.signed(45) * 1)
			),
			fire(),
			wait(2)
		];

		return asMain(main);
	}

	public static function randomIntTest(): ProgramPackage {
		final main = [
			shot.velocity.set(
				5,
				180 + random.int.signed(4) * 30
			),
			rep(random.int.between(1, 5), [
				fire(),
				wait(random.int.between(1, 5) * 4)
			]),
			wait(16)
		];

		return asMain(main);
	}

	public static function localVar(): ProgramPackage {
		final cnt = intVar("cnt");

		final main = [
			shot.velocity.set(5, 180),
			cnt.let(),
			loop([
				shot.direction.set(cnt * 20),
				fire(),
				wait(4),
				cnt.increment()
			])
		];

		return asMain(main);
	}

	public static function eventTest(): ProgramPackage {
		final main = [
			event(random.int.between(0, 10)),
			wait(60)
		];

		return asMain(main);
	}

	public static function dump(): ProgramPackage {
		final cnt = intVar("cnt");

		final main = [
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

		return asMain(main);
	}


	public static function transform(): ProgramPackage {
		final bearingVar = angleVar("bearing");
		final rotationVar = angleVar("rotation");

		final main = [
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

		return asMain(main);
	}

	public static function sinCos(): ProgramPackage {
		final bearingVar = angleVar("bearing");

		final main = [
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

		return asMain(main);
	}

	public static function readActor(): ProgramPackage {
		final main = [
			shot.velocity.set(4, 180),
			loop([
				fire(),
				shot.velocity.set(shot.speed, 180 + random.angle.grouping(90)),
				wait(4)
			])
		];

		return asMain(main);
	}

	public static function dupTest(): ProgramPackage {
		final main = [
			shot.velocity.set(4, 180),
			loop([
				comment("start nway & dup --------------------------------"),
				nWay(fire(), { ways: 5, angle: 90 }).dup({
					count: 8,
					intervalFrames: 4,
					shotSpeedChange: 8,
					shotDirectionRange: { start: -6, end: 6 }
				}),
				comment("end nway & dup ----------------------------------"),
				wait(30)
			])
		];

		return asMain(main);
	}

	static function asMain(ast: Ast): ProgramPackage
		return compile(["main" => ast]);
}
