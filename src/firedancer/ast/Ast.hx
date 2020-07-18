package firedancer.ast;

import firedancer.assembly.AssemblyCode;
import firedancer.assembly.AssemblyStatement.create as statement;
import firedancer.bytecode.Bytecode;
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
	/**
		Converts `Ast` to `Bytecode` words.
	**/
	public static inline function toAssembly(ast: Ast): AssemblyCode {
		return switch ast {
			case Wait(frames):
				[statement(PushInt, [Int(frames)]), statement(CountDown)];
			case SetPosition(x, y):
				statement(SetPositionConst, [Vec(x, y)]);
			case SetVelocity(vx, vy):
				statement(SetVelocityConst, [Vec(vx, vy)]);
			case List(nodes):
				nodes.map(node -> node.toAssembly()).flatten();
		}
	}

	/**
		Compiles `Ast` into `Bytecode`.
	**/
	public static inline function compile(ast: Ast): Bytecode
		return toAssembly(ast).compile();
}
