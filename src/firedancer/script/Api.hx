package firedancer.script;

import firedancer.types.DebugCode;
import firedancer.bytecode.ProgramPackage;
import firedancer.script.nodes.*;
import firedancer.script.api_components.Position;
import firedancer.script.api_components.Velocity;
import firedancer.script.api_components.Shot;
import firedancer.script.api_components.Random;
import firedancer.script.expression.IntExpression;
import firedancer.script.expression.FloatExpression;
import firedancer.script.expression.AngleExpression;
import firedancer.script.expression.IntLocalVariableExpression;
import firedancer.script.expression.FloatLocalVariableExpression;
import firedancer.script.expression.AngleLocalVariableExpression;

class Api {
	/**
		Provides functions for operating position.
	**/
	public static final position = new Position();

	/**
		Provides functions for operating the length of position vector.
	**/
	public static final distance = new Distance();

	/**
		Provides functions for operating the angle of position vector.
	**/
	public static final bearing = new Bearing();

	/**
		Provides functions for operating velocity.
	**/
	public static final velocity = new Velocity();

	/**
		Provides functions for operating the length of velocity vector.
	**/
	public static final speed = new Speed();

	/**
		Provides functions for operating the angle of velocity vector.
	**/
	public static final direction = new Direction();

	/**
		Provides functions for operating shot position/velocity.
	**/
	public static final shot = new Shot();

	/**
		Provides functions for generating pseudorandom numbers.
	**/
	public static final random = new Random();

	/**
		Waits `frames`.
	**/
	public static inline function wait(frames: IntExpression): Wait
		return new Wait(frames);

	/**
		Loops a given pattern endlessly.
	**/
	public static inline function loop(ast: Ast): Loop
		return new Loop(ast);

	/**
		Repeats a given pattern `count` times.
	**/
	public static inline function rep(count: IntExpression, ast: Ast): Repeat
		return new Repeat(ast, count);

	/**
		Emits a new actor with a pattern represented by the given `ast`.
	**/
	public static inline function fire(?ast: Ast): Fire {
		return new Fire(Maybe.from(ast));
	}

	/**
		Sets shot direction to the bearing to the target position.
	**/
	public static inline function aim(): Aim {
		return new Aim();
	}

	/**
		Runs `ast` every frame within the current node list.
	**/
	public static inline function everyFrame(ast: Ast): EachFrame {
		return new EachFrame(ast);
	}

	/**
		Runs any pattern in another thread.

		The initial shot position/veocity are the same as that in the current thread,
		but any change to shot position/velocity does not affect other threads.
	**/
	public static inline function async(ast: Ast): Async {
		return new Async(ast);
	}

	/**
		Runs the first pattern in the current thread and each subsequent one in a separate thread.
		Then waits until all patterns are completed.

		Any change to shot position/velocity made in a thread does not affect other threads.
	**/
	public static inline function parallel(asts: Array<Ast>): Parallel {
		return new Parallel(asts);
	}

	/**
		Ends running the bullet pattern with a specific end code
		so that the end code is returned from the VM.

		Normally the VM returns a default end code `0`.
		`end()` is useful for returning another end code so that you can
		branch the process according to that value (for example: kill the actor if `1` is returned).
	**/
	public static inline function end(endCode: Int): End {
		return new End(endCode);
	}

	/**
		Refers to a local variable with `name` and interprets it as an integer.
	**/
	public static inline function intVar(name: String): IntLocalVariableExpression
		return new IntLocalVariableExpression(name);

	/**
		Refers to a local variable with `name` and interprets it as a float.
	**/
	public static inline function floatVar(name: String): FloatLocalVariableExpression
		return new FloatLocalVariableExpression(name);

	/**
		Refers to a local variable with `name` and interprets it as an angle.
	**/
	public static inline function angleVar(name: String): AngleLocalVariableExpression
		return new AngleLocalVariableExpression(name);

	/**
		Calculates the trigonometric sine of `angle`.
	**/
	public static inline function sin(angle: AngleExpression): FloatExpression
		return angle.sin();

	/**
		Calculates the trigonometric cosine of `angle`.
	**/
	public static inline function cos(angle: AngleExpression): FloatExpression
		return angle.cos();

	/**
		Invokes a global event.
		@see `firedancer.types.EventHandler`
	**/
	public static inline function event(globalEventCode: IntExpression): Event
		return new Event(Global, globalEventCode);

	/**
		Invokes a local event.
		@see `firedancer.types.EventHandler`
	**/
	public static inline function localEvent(localEventCode: IntExpression): Event
		return new Event(Global, localEventCode);

	/**
		Runs debug process specified by `debugCode`.
	**/
	public static function debug(debugCode: DebugCode): Debug
		return new Debug(debugCode);

	/**
		@return New `ProgramPackage` instance that contains all `Program` compiled.
	**/
	public static inline function compile(namedAstMap: Map<String, Ast>): ProgramPackage {
		final compileContext = new CompileContext();

		for (name => ast in namedAstMap) {
			final assemblyCode = ast.toAssembly(compileContext);
			compileContext.setNamedCode(assemblyCode, name);
		}

		return compileContext.createPackage();
	}
}
