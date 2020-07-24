package firedancer.script;

import firedancer.bytecode.Bytecode;
import firedancer.script.nodes.List;

/**
	AST (abstract syntax tree) that represents a bullet hell pattern.
**/
@:notNull @:forward
abstract Ast(AstNode) from AstNode to AstNode {
	/**
		Converts `nodes` to `Ast`.
	**/
	@:from public static inline function fromArray(nodes: std.Array<AstNode>): Ast
		return new List(nodes);

	/**
		Compiles `this` into `Bytecode`.
	**/
	public inline function compile(): Bytecode
		return this.toAssembly().compile();
}
