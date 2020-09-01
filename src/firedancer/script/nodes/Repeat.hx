package firedancer.script.nodes;

import firedancer.script.expression.IntExpression;

/**
	Repeats the provided `AstNode`.
**/
@:ripper_verified
class Repeat extends AstNode implements ripper.Data {
	final node: AstNode;
	final repetitionCount: IntExpression;
	var unrolling: Bool = false;

	override inline function containsWait(): Bool {
		return this.node.containsWait();
	}

	/**
		Unrolls `this` loop if the loop count is a constant.
		@return `this`
	**/
	public inline function unroll(): Repeat {
		this.unrolling = true;
		return this;
	}

	override function toAssembly(context: CompileContext): AssemblyCode {
		final count = this.repetitionCount;
		final body = this.node.toAssembly(context);

		final constant = count.tryGetConstant();

		final code = if (constant.isSome() && this.unrolling) {
			loopUnrolled(0...constant.unwrap(), _ -> body);
		} else {
			loop(context, body, count);
		}

		return code;
	}
}
