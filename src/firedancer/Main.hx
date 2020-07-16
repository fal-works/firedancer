package firedancer;

import firedancer.types.NInt;
import firedancer.ast.Ast;
import firedancer.ast.AstList;
import firedancer.bytecode.Bytecode;

class Main {
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
	public static inline function wait(frames: NInt): Ast
		return Wait(frames);

	/**
		Compiles `Ast` or `AstList` into `Bytecode`.
	**/
	public static function compile(astList: AstList): Bytecode
		return astList.toAst().compile();
}

private class Velocity {
	public function new() {}

	/**
		Sets velocity to `(vx, vy)`.
	**/
	public inline function set(vx: Float, vy: Float): Ast
		return SetVelocity(vx, vy);
}

private class Shot {
	public function new() {}

	/**
		Provides functions for operating shot velocity.
	**/
	public final velocity = new ShotVelocity();
}

private class ShotVelocity {
	public function new() {}

	/**
		Sets shot velocity to `(vx, vy)`.
	**/
	public inline function set(vx: Float, vy: Float): Ast
		throw "Not yet implemented."; // TODO: implement
}
