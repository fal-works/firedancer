package firedancer.script;

import firedancer.vm.DebugCode;
import firedancer.vm.ProgramPackage;
import firedancer.assembly.AssemblyCodePackage;
import firedancer.script.nodes.*;
import firedancer.script.nodes.Duplicate;
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
	public static function wait(frames: IntExpression): Wait
		return new Wait(frames);

	/**
		Loops a given pattern endlessly.
	**/
	public static function loop(ast: Ast): Loop
		return new Loop(ast);

	/**
		Repeats a given pattern `count` times.
	**/
	public static function rep(count: IntExpression, ast: Ast): Repeat
		return new Repeat(ast, count);

	/**
		Duplicates a given pattern.
		@param count The repetition count. If the evaluated value is `0` or less, the result is unspecified.
		@param ast `fire()` at default.
	**/
	public static function dup(
		count: IntExpression,
		params: DuplicateParameters,
		?ast: Ast
	): Duplicate {
		if (ast == null) ast = fire();

		return new Duplicate(ast, count, params);
	}

	/**
		Emits a new actor with a pattern represented by the given `ast`.
	**/
	public static function fire(?ast: Ast): Fire {
		return new Fire(Maybe.from(ast));
	}

	/**
		Sets shot direction to the bearing to the target position.
	**/
	public static function aim(): Aim {
		return new Aim();
	}

	/**
		Runs `ast` every frame within the current node list.
	**/
	public static function everyFrame(ast: Ast): EachFrame {
		return new EachFrame(ast);
	}

	/**
		Runs any pattern in another thread.

		The initial shot position/veocity are the same as that in the current thread,
		but any change to shot position/velocity does not affect other threads.
	**/
	public static function async(ast: Ast): Async {
		return new Async(ast);
	}

	/**
		Runs the first pattern in the current thread and each subsequent one in a separate thread.
		Then waits until all patterns are completed.

		Any change to shot position/velocity made in a thread does not affect other threads.
	**/
	public static function parallel(asts: Array<Ast>): Parallel {
		return new Parallel(asts);
	}

	/**
		Ends running the bullet pattern with a specific end code.

		Normally the VM returns a default end code `0`.
		`end()` is useful for returning another end code so that you can
		branch the process according to that value.

		@param endCode The value to be returned from the VM.
		`0` for the default behavior, `-1` for killing the actor, or any other value for user-defined behaviors.
		@see `vanish()`
	**/
	public static function end(endCode: Int): End {
		return new End(endCode);
	}

	/**
		Calls `end()` with a special end code `-1`, which should kill the actor itself.
	**/
	public static function vanish(): End
		return end(-1);

	/**
		Refers to a local variable with `name` and interprets it as an integer.
		@param name Any string.
		However avoid using names which begins with double underscores `__` as they may be reserved for internal use.
	**/
	public static function intVar(name: String): IntLocalVariableExpression
		return new IntLocalVariableExpression(name);

	/**
		Refers to a local variable with `name` and interprets it as a float.
		@param name Any string.
		However avoid using names which begins with double underscores `__` as they may be reserved for internal use.
	**/
	public static function floatVar(name: String): FloatLocalVariableExpression
		return new FloatLocalVariableExpression(name);

	/**
		Refers to a local variable with `name` and interprets it as an angle.
		@param name Any string.
		However avoid using names which begins with double underscores `__` as they may be reserved for internal use.
	**/
	public static function angleVar(name: String): AngleLocalVariableExpression
		return new AngleLocalVariableExpression(name);

	/**
		Calculates the trigonometric sine of `angle`.
	**/
	public static function sin(angle: AngleExpression): FloatExpression
		return angle.sin();

	/**
		Calculates the trigonometric cosine of `angle`.
	**/
	public static function cos(angle: AngleExpression): FloatExpression
		return angle.cos();

	/**
		Invokes a global event.
		@see `firedancer.types.EventHandler`
	**/
	public static function event(globalEventCode: IntExpression): Event
		return new Event(Global, globalEventCode);

	/**
		Invokes a local event.
		@see `firedancer.types.EventHandler`
	**/
	public static function localEvent(localEventCode: IntExpression): Event
		return new Event(Global, localEventCode);

	/**
		Runs debug process specified by `debugCode`.
	**/
	public static function debug(debugCode: DebugCode): Debug
		return new Debug(debugCode);

	/**
		Inserts a comment.

		This is only used for debugging the assembly code.
		It has no effect when running the pattern because comments are removed when assembling into bytecode.
	**/
	public static function comment(text: String): Comment
		return new Comment(text);

	/**
		Creates an `AssemblyCodePackage` instance that contains all `AssemblyCode` compiled.
	**/
	@:access(firedancer.script.AstNode)
	public static function compileToAssembly(
		namedAstMap: Map<String, Ast>,
		optimize = true
	): AssemblyCodePackage {
		final compileContext = new CompileContext();

		for (name => ast in namedAstMap) {
			final assemblyCode = ast.toAssembly(compileContext);
			compileContext.setNamedCode(assemblyCode, name);
		}

		var pkg = compileContext.createPackage();
		if (optimize) pkg = pkg.optimize();

		#if debug
		pkg.printAll();
		#end

		return pkg;
	}

	/**
		Creates a `ProgramPackage` instance that contains all `Program` compiled & assembled.
	**/
	public static function compile(
		namedAstMap: Map<String, Ast>,
		optimize = true
	): ProgramPackage {
		return compileToAssembly(namedAstMap, optimize).assemble();
	}
}
