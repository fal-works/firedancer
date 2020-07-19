package firedancer;

import sneaker.print.Printer.println;
import firedancer.types.NInt;
import firedancer.ast.Ast;
import firedancer.ast.nodes.*;
import firedancer.ast.nodes.OperateVecConst;
import firedancer.bytecode.Bytecode;

class Main {
	/**
		Provides functions for operating position.
	**/
	public static final position = new Position();

	/**
		Provides functions for operating velocity.
	**/
	public static final velocity = new Velocity();

	/**
		Provides functions for operating shot position/velocity.
	**/
	public static final shot = new Shot();

	/**
		Waits `frames`.
	**/
	public static inline function wait(frames: NInt)
		return new Wait(frames);

	/**
		Repeats the given pattern.
		Use `count()` to make a finite loop. Otherwise the loop runs endlessly.
	**/
	public static inline function loop(ast: Ast): Loop
		return new Loop(ast);

	/**
		Compiles `Ast` or `AstNode` into `Bytecode`.
	**/
	public static inline function compile(ast: Ast): Bytecode {
		final code = ast.toAssembly();
		#if debug
		println('[COMPILED]\n${code.toString()}\n');
		#end
		return code.compile();
	}
}

private class Position {
	public function new() {}

	/**
		Sets position to `(x, y)`.
	**/
	public inline function set(x: Float, y: Float)
		return new SetPositionConst(x, y);
}

private class Velocity {
	public function new() {}

	/**
		Sets velocity to `(vx, vy)`.
	**/
	public inline function set(vx: Float, vy: Float)
		return new SetVelocityConst(vx, vy);
}

private class Shot {
	public function new() {}

	/**
		Provides functions for operating shot position.
	**/
	public final position = new ShotPosition();

	/**
		Provides functions for operating shot velocity.
	**/
	public final velocity = new ShotVelocity();
}

private class ShotPosition {
	public function new() {}

	/**
		Sets shot position to `(x, y)`.
	**/
	public inline function set(x: Float, y: Float)
		throw "Not yet implemented."; // TODO: implement
}

private class ShotVelocity {
	public function new() {}

	/**
		Sets shot velocity to `(vx, vy)`.
	**/
	public inline function set(vx: Float, vy: Float)
		throw "Not yet implemented."; // TODO: implement
}
