package firedancer.ast.nodes;

import firedancer.bytecode.internal.Constants.*;

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

	public function toAssembly(): AssemblyCode {
		if (!this.containsWait()) throw "Infinite loop must contain Wait.";

		final body = this.node.toAssembly();

		final jumpBackBytecodeLength = 2 * LEN32;
		final jumpBack = statement(
			Jump,
			[Int(-jumpBackBytecodeLength - body.bytecodeLength().int())]
		);

		body.push(jumpBack);
		return body;
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

	override public function toAssembly(): AssemblyCode {
		final count = this.loopCount;
		final body = this.node.toAssembly();
		final bodyLength = body.bytecodeLength().int();

		if (this.isInlined) {
			return [for (i in 0...count) body.copy()].flatten();
		}

		final pushCount = statement(PushInt, [Int(count.int())]);
		final countDownJumpBytecodeLength = 2 * LEN32;
		final jumpBackBytecodeLength = 2 * LEN32;
		final countDownJump = statement(
			CountDownJump,
			[Int(bodyLength + jumpBackBytecodeLength)]
		);
		final jumpBack = statement(Jump, [
			Int(-jumpBackBytecodeLength - bodyLength - countDownJumpBytecodeLength)
		]);

		return [
			[pushCount, countDownJump],
			body,
			[jumpBack]
		].flatten();
	}
}
