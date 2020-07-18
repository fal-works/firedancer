package firedancer.ast;

import firedancer.assembly.AssemblyCode;

/**
	A node of AST (abstract syntax tree) that represents a bullet hell pattern.
**/
interface AstNode {
	function toAssembly(): AssemblyCode;
}
