package firedancer.script.nodes;

import firedancer.script.expression.IntExpression;

/**
	Repeats the provided `AstNode`.
**/
@:ripper_verified
class Loop extends AstNode implements ripper.Data {
	public final node: AstNode;

	public inline function count(count: IntExpression): FiniteLoop {
		return new FiniteLoop(this.node, count);
	}

	override public inline function containsWait(): Bool {
		return this.node.containsWait();
	}

	override public function toAssembly(context: CompileContext): AssemblyCode {
		if (!this.containsWait()) throw "Infinite loop must contain Wait.";

		final code = this.node.toAssembly(context);
		code.push(jumpBack(code.bytecodeLength()));

		return code;
	}
}

@:ripper_verified
class FiniteLoop extends Loop {
	public final loopCount: IntExpression;
	public var unrolling: Bool = false;

	public function new(node: AstNode)
		super(node);

	/**
		Unrolls `this` loop if the loop count is a constant.
		@return `this`
	**/
	public inline function unroll(): FiniteLoop {
		this.unrolling = true;
		return this;
	}

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final count = this.loopCount;
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
