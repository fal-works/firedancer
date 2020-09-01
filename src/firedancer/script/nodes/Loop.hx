package firedancer.script.nodes;

/**
	Loops the provided `AstNode` endlessly.
**/
@:ripper_verified
class Loop extends AstNode implements ripper.Data {
	final node: AstNode;

	override inline function containsWait(): Bool {
		return this.node.containsWait();
	}

	override function toAssembly(context: CompileContext): AssemblyCode {
		if (!this.containsWait()) throw "Infinite loop must contain Wait.";

		final nextLabelIdStack = context.nextLabelIdStack;
		var nextLabelId = nextLabelIdStack.pop().unwrap();
		final labelId = nextLabelId++;
		nextLabelIdStack.push(nextLabelId);

		final code: AssemblyCode = [];
		code.push(Label(labelId));
		code.pushFromArray(this.node.toAssembly(context));
		code.push(GotoLabel(labelId));

		return code;
	}
}
