package firedancer.script.nodes;

/**
	Inserts a comment to the assembly code.
**/
@:ripper_verified
class Comment extends AstNode implements ripper.Data {
	final text: String;

	override public inline function containsWait(): Bool
		return false;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		return [Comment(text)];
	}
}
