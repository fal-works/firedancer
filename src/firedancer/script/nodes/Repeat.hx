package firedancer.script.nodes;

import firedancer.script.expression.IntExpression;

/**
	Repeats the provided `AstNode`.
**/
@:ripper_verified
class Repeat extends AstNode implements ripper.Data {
	public final node: AstNode;
	public final repetitionCount: IntExpression;
	public var unrolling: Bool = false;

	override public inline function containsWait(): Bool {
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

	override public function toAssembly(context: CompileContext): AssemblyCode {
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
