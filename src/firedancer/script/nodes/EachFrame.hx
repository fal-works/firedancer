package firedancer.script.nodes;

/**
	Injects any `Ast` in every frame within the current node list being compiled.
**/
@:ripper_verified
class EachFrame extends AstNode {
	public function new(astToBeInjected: Ast)
		this.type = EachFrame(astToBeInjected);

	override public inline function containsWait(): Bool
		return false;

	override public inline function toAssembly(context: CompileContext): AssemblyCode
		return [];
}
