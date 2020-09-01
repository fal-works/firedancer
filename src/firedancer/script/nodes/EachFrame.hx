package firedancer.script.nodes;

/**
	Injects any `Ast` in every frame within the current node list being compiled.
**/
@:ripper_verified
class EachFrame extends AstNode {
	public function new(astToBeInjected: Ast)
		this.nodeType = EachFrame(astToBeInjected);

	override inline function containsWait(): Bool
		return false;

	override inline function toAssembly(context: CompileContext): AssemblyCode
		return [];
}
