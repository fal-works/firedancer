package firedancer.script;

import haxe.EnumFlags;
import sneaker.exception.NotOverriddenException;
import firedancer.assembly.AssemblyCode;

/**
	A node of AST (abstract syntax tree) that represents a bullet hell pattern.
**/
class AstNode {
	public var type(default, null): AstNodeType = Other;

	/**
		@return `true` if `this` or any descendant node contains `Wait` element.
	**/
	public function containsWait(): Bool
		throw new NotOverriddenException();

	/**
		Converts the AST starting from `this` node into code in a virtual assembly language.
	**/
	public function toAssembly(context: CompileContext): AssemblyCode
		throw new NotOverriddenException();
}

enum AstNodeType {
	EachFrame(astToBeInjected: Ast);
	Other;
}
