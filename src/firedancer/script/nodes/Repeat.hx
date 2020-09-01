package firedancer.script.nodes;

import firedancer.script.expression.IntExpression;

/**
	Repeats the provided `AstNode`.
**/
@:ripper_verified
class Repeat extends AstNode implements ripper.Data {
	final node: AstNode;
	final repetitionCount: IntExpression;

	override inline function containsWait(): Bool {
		return this.node.containsWait();
	}

	override function toAssembly(context: CompileContext): AssemblyCode {
		final count = this.repetitionCount;
		final body = this.node.toAssembly(context);
		final code = loop(context, body, count);

		return code;
	}
}
