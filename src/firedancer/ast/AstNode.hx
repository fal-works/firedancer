package firedancer.ast;

import firedancer.assembly.AssemblyCode;
import firedancer.assembly.AssemblyStatement.create as statement;
import firedancer.types.NInt;

/**
	A node of AST (abstract syntax tree) that represents a bullet hell pattern.
**/
@:using(firedancer.ast.AstNode.AstNodeExtension)
enum AstNode {
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
		Runs `nodes` sequentially.
	**/
	List(nodes: Array<AstNode>);
}

class AstNodeExtension {
	/**
		Converts `this` to code in a virtual assembly language.
	**/
	public static inline function toAssembly(node: AstNode): AssemblyCode {
		return switch node {
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
}
