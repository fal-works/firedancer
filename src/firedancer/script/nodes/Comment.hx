package firedancer.script.nodes;

/**
	Inserts a comment to the assembly code.
**/
@:ripper_verified
class Comment extends AstNode implements ripper.Data {
	final text: String;

	override inline function containsWait(): Bool
		return false;

	override function toAssembly(context: CompileContext): AssemblyCode {
		return [Comment(text)];
	}
}
