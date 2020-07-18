package firedancer.ast;

import firedancer.bytecode.Bytecode;

/**
	AST (abstract syntax tree) that represents a bullet hell pattern.
**/
@:notNull @:forward
abstract Ast(AstNode) from AstNode {
	/**
		Converts `nodes` to `Ast`.
	**/
	@:from public static inline function fromArray(nodes: std.Array<AstNode>): Ast
		return AstNode.List(nodes);

	/**
		Compiles `this` into `Bytecode`.
	**/
	public inline function compile(): Bytecode
		return this.toAssembly().compile();
}
