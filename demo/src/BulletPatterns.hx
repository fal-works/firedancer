import firedancer.vm.ProgramPackage;
import firedancer.script.Api.*;
import firedancer.script.ApiEx.*;
import firedancer.script.Ast;

class BulletPatterns {
	public static function get(patternName: String): Maybe<ProgramPackage> {
		return Maybe.from(switch patternName {
		case "default": firedancerDemo();
		case "control-flow": controlFlow();
		case "move": move();
		case "move-2": move2();
		case "shot-speed": shotSpeed();
		case "shot-direction": shotDirection();
		case "shot-position": shotPosition();
		case "nway-radial-line": nwayRadialLine();
		case "random": randomDemo();
		case "aim": aimDemo();
		case "parallel": parallelDemo();
		case "fire-with-pattern": fireWithPattern();
		case "bind-position": bindPosition();
		case "vanish": vanishDemo();
		case "variables": variables();
		case "sin-cos": sinCos();
		case "transform": transform();
		case "nway-whip": nWayWhip();
		case "laundry": laundry();
		case "pods": pods();
		case "static-geometric": staticGeometric();
		case "flower": flower();
		case "seeds": seeds();
		default: null;
		});
	}

	public static function defaultPattern(): ProgramPackage
		return firedancerDemo();

	public static function firedancerDemo(): ProgramPackage {
		final main = [
			shot.speed.set(3),
			parallel([
				loop([
					radial(2, nWay(7, { angle: 30 })),
					shot.direction.add(30),
					wait(15)
				]),
				[
					shot.direction.add(90),
					loop([
						radial(2, line(7, {
							shotSpeedChange: 1.2 })),
						shot.direction.add(30),
						wait(15)
					])
				]
			])
		];

		final text = "[
	shot.speed.set(3),
	parallel([
		[
			loop([
				radial(2, nWay(7, { angle: 30 })),
				shot.direction.add(30),
				wait(15)
			])
		],
		[
			shot.direction.add(90),
			loop([
				radial(2, line(7, { shotSpeedChange: 1.2 })),
				shot.direction.add(30),
				wait(15)
			])
		]
	])
];";

		return asMain(main, text);
	}

	public static function controlFlow(): ProgramPackage {
		final main = [
			// Elements in an array are executed sequentially
			shot.velocity.set(4, 180), // (see other examples)
			loop([
				// infinite loop
				wait(60), // wait 60 frames = 1 second
				rep(8, [
					// repeat 8 times
					fire(), // emit a new actor (= bullet, enemy etc.)
					wait(10)
				])
			])
		];

		final text = "// Elements in an array are executed sequentially.

[
	shot.velocity.set(4, 180), // (see other examples)
	loop([ // infinite loop
		wait(60), // wait 60 frames = 1 second
		rep(8, [ // repeat 8 times
			fire(), // emit a new actor (= bullet, enemy etc.)
			wait(10)
		])
	])
];";

		return asMain(main, text);
	}

	public static function move(): ProgramPackage {
		final main = loop([
			velocity.set(8, 180), // polar coords (length, angle) at default
			wait(30),
			velocity.add(16, 0), // you can either set or add
			wait(30),
			speed.set(0), // set/add length or angle independently
			wait(60)
		]);

		final text = "/*
	Terminology:
		position = { r: distance, θ: bearing }
		velocity = { r: speed,  θ: direction }

	Angle values are in degrees, north-based and clockwise.
*/

loop([
	velocity.set(8, 180), // polar coords (length, angle) at default
	wait(30),
	velocity.add(16, 0), // you can either set or add
	wait(30),
	speed.set(0), // set/add length or angle independently
	wait(30),
	fire(),
	wait(30)
]);";

		return asMain(main, text);
	}

	public static function move2(): ProgramPackage {
		final main = loop([
			velocity.set(16, 180).frames(60), // change gradually
			speed.set(0),
			wait(30),
			velocity.cartesian.set(0, -16), // cartesian coords
			speed.set(0).frames(60),
			wait(30),
		]);

		final text = "loop([
	velocity.set(16, 180).frames(60), // change gradually
	speed.set(0),
	wait(30),
	velocity.cartesian.set(0, -16), // cartesian coords
	speed.set(0).frames(60),
	wait(30),
]);";

		return asMain(main, text);
	}

	public static function shotSpeed(): ProgramPackage {
		final main = loop([
			shot.velocity.set(3, 180),
			rep(20, [
				fire(),
				shot.speed.add(0.5),
				wait(4)
			]),
			wait(60)
		]);

		final text = "loop([
	shot.velocity.set(5, 180),
	rep(30, [
		fire(),
		shot.speed.add(1),
		wait(1)
	]),
	wait(60)
]);";

		return asMain(main, text);
	}

	public static function shotDirection(): ProgramPackage {
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

	public static function shotPosition(): ProgramPackage {
		final main = loop([
			shot.velocity.set(6, 180), // { speed: 6, direction: 180 }
			shot.position.set(150, 180), // { distance: 150, bearing: 180 }
			loop([
				fire(),
				shot.bearing.add(8),
				wait(2)
			])
		]);

		final text = "loop([
			shot.velocity.set(6, 180), // { speed: 6, direction: 180 }
			shot.position.set(150, 180), // { distance: 150, bearing: 180 }
			loop([
				fire(),
				shot.bearing.add(8),
				wait(2)
			])
		]);";

		return asMain(main, text);
	}

	public static function nwayRadialLine(): ProgramPackage {
		final main = loop([
			shot.velocity.set(4, 180),
			nWay(10, { angle: 90 }),
			wait(60),
			radial(36),
			wait(60),
			line(10, { shotSpeedChange: 10 }),
			wait(60)
		]);

		final text = "loop([
	shot.velocity.set(4, 180),
	nWay(10, { angle: 90 }),
	wait(60),
	radial(36),
	wait(60),
	line(10, { shotSpeedChange: 10 }),
	wait(60)
]);

/*
	nWay() and line() are shorthands for dup() with limited parameters.
*/
";

		return asMain(main, text);
	}

	public static function aimDemo(): ProgramPackage {
		final main = [
			shot.speed.set(8),
			loop([
				shot.position.set(150, random.angle.between(0, 360)),
				aim(), // sets shot direction to the angle to the target
				line(8, { shotSpeedChange: 6 }),
				wait(10)
			])
		];

		final text = "[
	shot.speed.set(8),
	loop([
		shot.position.set(150, random.angle.between(0, 360)),
		aim(), // sets shot direction to the angle to the target
		line(8, { shotSpeedChange: 6 }),
		wait(10)
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

		final text = "[
	shot.velocity.set(5, 180),
	loop([
		fire([
			wait(30),
			direction.add(-120)
		]),
		shot.direction.add(36),
		wait(8)
	])
];";

		return asMain(main, text);
	}

	public static function bindPosition(): ProgramPackage {
		final main = [
			shot.position.set(30, 180),
			loop([
				rep(12, [
					fire(loop([
						distance.add(4),
						bearing.add(1),
						wait(1)
					])).bind(),
					shot.bearing.add(30),
				]),
				wait(30)
			])
		];

		final text = "/*
	If you call bind() after fire(),
	the position of fired actor will be
	relative from the actor that fired it.
*/

[
	shot.position.set(30, 180),
	loop([
		rep(12, [
			fire(loop([
				distance.add(4),
				bearing.add(1),
				wait(1)
			])).bind(),
			shot.bearing.add(30),
		]),
		wait(30)
	])
];";

		return asMain(main, text);
	}

	public static function parallelDemo(): ProgramPackage {
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

		final text = "/*
	parallel() waits until all threads are completed, while
	async() does not.
*/

[
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

	public static function vanishDemo(): ProgramPackage {
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

	public static function randomDemo(): ProgramPackage {
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

	public static function variables(): ProgramPackage {
		final cnt = intVar("cnt");

		final main = [
			shot.velocity.set(5, 180),
			cnt.let(), // declare int variable "cnt"
			loop([
				shot.direction.set(cnt * 20),
				fire(),
				wait(4),
				cnt.increment()
			])
		];

		final text = '/*
	You can define any local variable with
	intVar(), floatVar() or angleVar().

	Each array behaves as a scope.
	Shadowing is allowed.

	You can change the assigned value by
	set(), add(), increment() or decrement()
	(the latter two are only for integer variables).
*/

final cnt = intVar("cnt");

[
	shot.velocity.set(5, 180),
	cnt.let(), // declare in the current scope
	loop([
		shot.direction.set(cnt * 20),
		fire(),
		wait(4),
		cnt.increment()
	])
];';

		return asMain(main, text);
	}

	public static function sinCos(): ProgramPackage {
		final varBearing = angleVar("bearing");

		final main = [
			shot.position.cartesian.set(270, 0),
			rep(16, [
				fire([
					varBearing.let(),
					loop([
						position.cartesian.set(
							270 * cos(varBearing),
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
	shot.position.cartesian.set(270, 0),
	rep(16, [
		fire([
			varBearing.let(),
			loop([
				position.cartesian.set(
					270 * cos(varBearing),
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
			shot.position.set(150, 90),
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

	public static function nWayWhip(): ProgramPackage {
		final main = [
			shot.velocity.set(4, 180),
			loop([
				nWay(5, { angle: 90 }).dup(8, {
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
		nWay(5, { angle: 90 }).dup(8, {
			intervalFrames: 4,
			shotSpeedChange: 8,
			shotDirectionRange: { start: -6, end: 6 }
		}),
		wait(30)
	])
];";

		return asMain(main, text);
	}

	public static function laundry(): ProgramPackage {
		final main = [
			shot.speed.set(12),
			parallel([
				loop([
					radial(10),
					shot.direction.add(8),
					wait(4)
				]),
				loop([
					radial(4),
					shot.direction.add(4),
					wait(2)
				]),
				loop([
					radial(4),
					shot.direction.add(-4),
					wait(2)
				])
			])
		];

		final text = "[
	shot.speed.set(12),
	parallel([
		loop([
			radial(10),
			shot.direction.add(8),
			wait(4)
		]),
		loop([
			radial(4),
			shot.direction.add(4),
			wait(2)
		]),
		loop([
			radial(4),
			shot.direction.add(-4),
			wait(2)
		])
	])
];";

		return asMain(main, text);
	}

	public static function pods(): ProgramPackage {
		final main = [
			shot.velocity.set(10, 0),
			radial(2, fire([
				shot.velocity.set(2, direction),
				speed.set(0).frames(30),
				loop([
					fire(),
					bearing.add(-3),
					shot.direction.add(12),
					wait(1)
				])
			]).bind())
		];

		final text = "[
	shot.velocity.set(10, 0),
	radial(2, fire([
		shot.velocity.set(2, direction),
		speed.set(0).frames(30),
		loop([
			fire(),
			bearing.add(-3),
			shot.direction.add(12),
			wait(1)
		])
	]).bind())
];";

		return asMain(main, text);
	}

	public static function staticGeometric(): ProgramPackage {
		final main = [
			shot.velocity.set(6, 0),
			loop([
				radial(8, fire([
					wait(20),
					shot.velocity.set(6, direction),
					nWay(2, { angle: 120 }),
					vanish()
				])),
				wait(4)
			])
		];

		final text ="[
	shot.velocity.set(6, 0),
	loop([
		radial(8, fire([
			wait(20),
			shot.velocity.set(6, direction),
			nWay(2, { angle: 120 }),
			vanish()
		])),
		wait(4)
	])
];";

		return asMain(main, text);
	}

	public static function flower(): ProgramPackage {
		final main = loop([
			shot.velocity.set(4, 180),
			shot.position.set(80, 180),
			dup(32, {shotBearingRange: {start: 0, end: 360}, shotDirectionRange: {start: 0, end: 360}}, [
				shot.direction.add(90),
				nWay(9, {angle: 90}, fire([
					speed.set(1).frames(30),
					parallel([direction.add(210).frames(60), speed.set(2).frames(60)])
				]))
			]),
			wait(240)
		]);

		final text = "loop([
	shot.velocity.set(4, 180),
	shot.position.set(80, 180),
	dup(
		32,
		{
			shotBearingRange: { start: 0, end: 360 },
			shotDirectionRange: { start: 0, end: 360 }
		},
		[
			shot.direction.add(90),
			nWay(9, { angle: 90 }, fire([
				speed.set(1).frames(30),
				parallel([
					direction.add(210).frames(60),
					speed.set(2).frames(60)
				])
			]))
		]
	),
	wait(240)
])";

		return asMain(main, text);
	}

	public static function seeds(): ProgramPackage {
		// You can freely structure your code within the Haxe syntax.

		final lineSeed = [
			shot.velocity.set(1, shot.angleToTarget),
			speed.set(1).frames(30),
			line(12, { shotSpeedChange: 6 }, fire([ wait(15), speed.add(5).frames(60) ])),
			vanish()
		];

		final nWaySeed = [
			speed.set(1).frames(30),
			shot.velocity.set(8, shot.angleToTarget),
			nWay(5, { angle: 150 }, fire(lineSeed)),
			vanish()
		];

		final main = loop([
			shot.velocity.set(random.between(6, 9), 90 + random.angle.grouping(90)),
			fire(nWaySeed),
			wait(30),
			shot.velocity.set(random.between(6, 9), 270 + random.angle.grouping(90)),
			fire(nWaySeed),
			wait(30)
		]);

		final text = "// You can freely structure your code within the Haxe syntax.

final lineSeed = [
	shot.velocity.set(1, shot.angleToTarget),
	speed.set(1).frames(30),
	line(12, { shotSpeedChange: 6 }, fire([ wait(15), speed.add(5).frames(60) ])),
	vanish()
];

final nWaySeed = [
	speed.set(1).frames(30),
	shot.velocity.set(8, shot.angleToTarget),
	nWay(5, { angle: 150 }, fire(lineSeed)),
	vanish()
];

loop([
	shot.velocity.set(random.between(6, 9), 90 + random.angle.grouping(90)),
	fire(nWaySeed),
	wait(30),
	shot.velocity.set(random.between(6, 9), 270 + random.angle.grouping(90)),
	fire(nWaySeed),
	wait(30)
]);";

		return asMain(main, text);
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

	public static function readActorTest(): ProgramPackage {
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

	public static function eventTest(): ProgramPackage {
		final main = [
			event(random.int.between(0, 10)),
			wait(60)
		];

		return asMain(main);
	}

	public static function dumpTest(): ProgramPackage {
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

	static function asMain(ast: Ast, script: String = ""): ProgramPackage {
		script = StringTools.replace(script, "\t", "  ");
		Dom.script(script);

		final assembly = compileToAssembly(["main" => ast], true);

		Dom.assembly(assembly.toString());

		final programPackage = assembly.assemble();

		Dom.program(programPackage.toString());

		return programPackage;
	}
}
