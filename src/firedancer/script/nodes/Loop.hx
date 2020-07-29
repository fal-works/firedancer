package firedancer.script.nodes;

/**
	Repeats the provided `AstNode`.
**/
@:ripper_verified
class Loop implements ripper.Data implements AstNode {
	public final node: AstNode;

	public inline function count(count: UInt): FiniteLoop {
		return new FiniteLoop(this.node, count);
	}

	public inline function containsWait(): Bool {
		return this.node.containsWait();
	}

	public function toAssembly(context: CompileContext): AssemblyCode {
		if (!this.containsWait()) throw "Infinite loop must contain Wait.";

		final code = this.node.toAssembly(context);
		code.push(jumpBack(code.bytecodeLength()));

		return code;
	}
}

@:ripper_verified
class FiniteLoop extends Loop {
	public final loopCount: UInt;
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

		final code = if (this.isInlined) {
			loopUnrolled(0...count, _ -> body);
		} else {
			loop(body, count);
		}

		return code;
	}
}
