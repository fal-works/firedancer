import firedancer.vm.ProgramPackage;
import firedancer.script.Api.*;
import firedancer.script.ApiEx.*;
import firedancer.script.Ast;

class BulletPatterns {
	public static function get(patternName: String): Maybe<ProgramPackage> {
		return Maybe.from(switch patternName {
			case "default": defaultPattern();
			case "spiral": spiral();
			case "aim": aimPlayer();
			case "parallel": parallelTest();
			case "vanish": vanishTest();
			case "random": randomTest();
			case "sin-cos": sinCos();
			case "transform": transform();
			case "radial": radialTest();
			case "nway-dup": nwayDup();
			default: null;
		});
	}

	public static function defaultPattern(): ProgramPackage
		return nwayDup();

	public static function radialTest(): ProgramPackage {
		final main = loop([
			shot.velocity.set(4, 0),
			radial(fire(), { ways: 36 }),
			wait(60)
		]);

		final text = "loop([
  shot.velocity.set(4, 0),
  radial(fire(), { ways: 36 }),
  wait(60)
]);";

		return asMain(main, text);
	}

	public static function aimPlayer(): ProgramPackage {
		final main = [
			aim().shotSpeed(5),
			loop([
				fire(),
				wait(8)
			])
		];

		final text = "[
  aim().shotSpeed(5),
  loop([
    fire(),
    wait(8)
  ])
];";

		return asMain(main, text);
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

		final text = "[
  shot.velocity.set(5, 180),
  loop([
    fire(),
    shot.direction.add(12),
    wait(1)
  ])
];";

		return asMain(main, text);
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
			rep(
				4,
				[
					rep(
						12,
						[
							fire(
								loop(
									[
										distance.add(4),
										bearing.add(1),
										wait(1)
									]
								)
							).bind(),
							shot.bearing.add(30),
						]
					),
					wait(30)
				]
			),
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

		final text = "[
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
];";

		return asMain(main, text);
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

		final text = "[
  shot.velocity.set(5, 180),
  loop([
    fire([
      wait(30),
      vanish()
    ]),
    shot.direction.add(12),
    wait(1)
  ])
];";

		return asMain(main, text);
	}

	public static function randomTest(): ProgramPackage {
		final main = loop([
			shot.velocity.set(
				random.between(1, 4),
				180 + (random.angle.grouping(90))
			),
			fire(),
			wait(2)
		]);

		final text = "loop([
  shot.velocity.set(
    random.between(1, 4),
    180 + (random.angle.grouping(90)) // 180 ± 45
  ),
  fire(),
  wait(2)
]);";

		return asMain(main, text);
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


	public static function sinCos(): ProgramPackage {
		final varBearing = angleVar("bearing");

		final main = [
			rep(16, [
				fire([
					varBearing.let(),
					loop([
						position.cartesian.set(
							300 * cos(varBearing),
							60 * sin(varBearing)
						),
						wait(1),
						varBearing.add(4)
					])
				]).bind(),
				wait(4)
			])
		];

		final text = 'final varBearing = angleVar("bearing");

[
  rep(16, [
    fire([
      varBearing.let(),
      loop([
        position.cartesian.set(
          300 * cos(varBearing),
          60 * sin(varBearing)
        ),
        wait(1),
        varBearing.add(4)
      ])
    ]).bind(),
    wait(4)
  ])
];';

		return asMain(main, text);
	}

	public static function transform(): ProgramPackage {
		final varBearing = angleVar("bearing");
		final varRotation = angleVar("rotation");

		final main = [
			rep(24, [
				fire([
					varBearing.let(),
					varRotation.let(),
					loop([
						position.set(150, varBearing).rotate(varRotation).scale(1.0, 0.3),
						wait(1),
						varBearing.add(4),
						varRotation.add(2)
					])
				]).bind(),
				wait(6)
			])
		];

		final text = 'final varBearing = angleVar("bearing");
final varRotation = angleVar("rotation");

[
  rep(24, [
    fire([
      varBearing.let(),
      varRotation.let(),
      loop([
        position.set(150, varBearing)
          .rotate(varRotation)
          .scale(1.0, 0.3),
        wait(1),
        varBearing.add(4),
        varRotation.add(2)
      ])
    ]).bind(),
    wait(6)
  ])
];';

		return asMain(main, text);
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

	public static function nwayDup(): ProgramPackage {
		final main = [
			shot.velocity.set(4, 180),
			loop([
				nWay(fire(), {
					ways: 5,
					angle: 90 }).dup({
					count: 8,
					intervalFrames: 4,
					shotSpeedChange: 8,
					shotDirectionRange: { start: -6, end: 6 }
				}),
				wait(30)
			])
		];

		final text = "[
  shot.velocity.set(4, 180),
  loop([
    nWay(fire(), { ways: 5, angle: 90 }).dup({
      count: 8,
      intervalFrames: 4,
      shotSpeedChange: 8,
      shotDirectionRange: { start: -6, end: 6 }
    }),
    wait(30)
  ])
];";

		return asMain(main, text);
	}

	static function asMain(ast: Ast, script: String = ""): ProgramPackage {
		Dom.script(script);

		final assembly = compileToAssembly(["main" => ast], true);

		Dom.assembly(assembly.toString());

		final programPackage = assembly.assemble();

		Dom.program(programPackage.toString());

		return assembly.assemble();
	}
}
