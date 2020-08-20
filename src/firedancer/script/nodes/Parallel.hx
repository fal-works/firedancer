package firedancer.script.nodes;

/**
	Runs the first pattern in the current thread and each subsequent one in a separate thread.
	Then waits until all patterns are completed.
**/
@:ripper_verified
class Parallel extends AstNode implements ripper.Data {
	public final array: Array<Ast>;

	override public inline function containsWait(): Bool
		return false;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final mainNode = array.shift();
		if (mainNode.isNone()) return [];

		final main = mainNode.unwrap().toAssembly(context);
		final invokeSub: AssemblyCode = array.map(node -> {
			final programId = context.setCode(node.toAssembly(context));
			return UseThread(programId, Stack);
		});
		final awaitSub: AssemblyCode = array.map(_ -> AwaitThread);

		return [
			invokeSub,
			main,
			awaitSub
		].flatten();
	}
}
