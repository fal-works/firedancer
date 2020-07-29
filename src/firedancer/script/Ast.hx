package firedancer.script;

import firedancer.script.nodes.List;

/**
	AST (abstract syntax tree) that represents a bullet hell pattern.
**/
@:notNull @:forward
abstract Ast(AstNode) from AstNode to AstNode {
	/**
		Converts `nodes` to `Ast`.
	**/
	@:from public static inline function fromArray(nodes: Array<AstNode>): Ast
		return new List(nodes);

	/**
		Converts `nodes` to `Ast`.
	**/
	@:from static inline function fromStdArray(nodes: std.Array<AstNode>): Ast
		return fromArray(nodes);
}
