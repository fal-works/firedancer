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
		Set velocity to `(x, y)`.
	**/
	SetVelocity(x: Float, y: Float);

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
				[Opcode(PushInt), Int(frames), Opcode(CountDown)];
			case SetVelocity(x, y):
				[
					Opcode(SetVelocity),
					Float(x),
					Float(y)
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
