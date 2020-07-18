package firedancer.ast;

import firedancer.bytecode.Bytecode;
import firedancer.bytecode.WordArray;
import firedancer.types.NInt;

/**
	AST (abstract syntax tree) that represents a bullet hell pattern.
**/
@:using(firedancer.ast.Ast.AstExtension)
enum Ast {
	/**
		Waits `frames`.
	**/
	Wait(frames: NInt);

	/**
		Set position to `(x, y)`.
	**/
	SetPosition(x: Float, y: Float);

	/**
		Set velocity to `(vx, vy)`.
	**/
	SetVelocity(vx: Float, vy: Float);

	/**
		Runs `astList` sequentially.
	**/
	List(astList: AstList);
}

class AstExtension {
	static final toWordArrayCallback = toWordArray;

	/**
		Converts `Ast` to `Bytecode` words.
	**/
	public static inline function toWordArray(ast: Ast): WordArray {
		return switch ast {
			case Wait(frames):
				[
					Opcode(PushInt),
					Int(frames),
					Opcode(CountDown)
				];
			case SetPosition(x, y):
				[
					Opcode(SetPositionC),
					Float(x),
					Float(y)
				];
			case SetVelocity(vx, vy):
				[
					Opcode(SetVelocityC),
					Float(vx),
					Float(vy)
				];
			case List(nodes):
				nodes.map(toWordArrayCallback).flatten();
		}
	}

	/**
		Compiles `Ast` into `Bytecode`.
	**/
	public static inline function compile(ast: Ast): Bytecode
		return toWordArray(ast).toBytecode();
}
