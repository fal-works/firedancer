package firedancer.script;

import firedancer.assembly.AssemblyCode;

/**
	A node of AST (abstract syntax tree) that represents a bullet hell pattern.
**/
interface AstNode {
	/**
		@return `true` if `this` or any descendant node contains `Wait` element.
	**/
	function containsWait(): Bool;

	/**
		Converts the AST starting from `this` node to code in a virtual assembly language.
	**/
	function toAssembly(): AssemblyCode;
}
