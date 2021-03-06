package firedancer.script.nodes;

/**
	Runs the first pattern in the current thread and each subsequent one in a separate thread.
	Then waits until all patterns are completed.
**/
@:ripper_verified
class Parallel extends AstNode implements ripper.Data {
	final array: Array<Ast>;

	override inline function containsWait(): Bool
		return false;

	override function toAssembly(context: CompileContext): AssemblyCode {
		var nodes = this.array.copy();
		final mainNode = nodes.shift();
		if (mainNode.isNone()) return [];

		final main = mainNode.unwrap().toAssembly(context);
		final invokeSub: AssemblyCode = nodes.map(node -> {
			final programId = context.setCode(node.toAssembly(context));
			return UseThread(programId, Int(Stack));
		});
		final awaitSub: AssemblyCode = nodes.map(_ -> AwaitThread);

		return [
			invokeSub,
			main,
			awaitSub
		].flatten();
	}
}
