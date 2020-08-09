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
	public var isInlined: Bool = false;

	public function new(node: AstNode)
		super(node);

	public inline function inlined(): FiniteLoop {
		this.isInlined = true;
		return this;
	}

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final count = this.loopCount;
		final body = this.node.toAssembly(context);

		final countValue = count.tryGetConstantOperandValue();

		final code = if (countValue.isSome() && this.isInlined) {
			loopUnrolled(0...countValue.unwrap(), _ -> body);
		} else {
			loop(body, count);
		}

		return code;
	}
}
