package firedancer.script.nodes;

/**
	Runs any pattern in another thread.
**/
@:ripper_verified
class Async extends AstNode implements ripper.Data {
	public final pattern: Ast;

	override public inline function containsWait(): Bool
		return false;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final programId = context.setCode(pattern.toAssembly(context));

		return [UseThread(programId, Null)];
	}
}
