package firedancer.script.nodes;

import firedancer.types.NInt;

/**
	Waits for a specific number of frames.
**/
@:ripper_verified
class Wait implements ripper.Data implements AstNode {
	public final frames: NInt;

	public inline function containsWait(): Bool
		return true;

	public function toAssembly(): AssemblyCode
		return [pushInt(frames), countDownbreak()];
}
