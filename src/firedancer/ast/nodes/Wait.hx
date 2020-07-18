package firedancer.ast.nodes;

import firedancer.types.NInt;

/**
	Waits for a specific number of frames.
**/
class Wait implements ripper.Data implements AstNode {
	public final frames: NInt;

	public function toAssembly(): AssemblyCode
		return [statement(PushInt, [Int(frames)]), statement(CountDown)];
}
