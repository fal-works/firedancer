package firedancer.script;

import sneaker.exception.NotOverriddenException;
import firedancer.assembly.AssemblyCode;
import firedancer.script.nodes.Duplicate;
import firedancer.script.expression.IntExpression;

/**
	A node of AST (abstract syntax tree) that represents a bullet hell pattern.
**/
class AstNode {
	var nodeType(default, null): AstNodeType = Other;

	/**
		Duplicates `this` pattern. Same effect as `Api.dup()`.
		@param count The repetition count. If the evaluated value is `0` or less, the result is unspecified.
	**/
	public inline function dup(count: IntExpression, params: DuplicateParameters): Duplicate
		return Api.dup(count, params, this);

	/**
		Checks that `this` node contains any `Wait` element or kind of that.

		Used for detecting infinite loops, however note that this cannot detect
		zero or negative runtime value of waiting frames.

		@return `true` if `this` or any descendant node contains `Wait` element or kind of that.
	**/
	function containsWait(): Bool
		throw new NotOverriddenException();

	/**
		Converts the AST starting from `this` node into code in a virtual assembly language.
	**/
	function toAssembly(context: CompileContext): AssemblyCode
		throw new NotOverriddenException();
}

enum AstNodeType {
	EachFrame(astToBeInjected: Ast);
	Other;
}
