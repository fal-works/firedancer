package firedancer.script.nodes;

/**
	Emits a new actor.
**/
@:ripper_verified
class Fire implements ripper.Data implements AstNode {
	public final pattern: Maybe<AstNode>;

	public inline function containsWait(): Bool
		return false;

	public function toAssembly(): AssemblyCode {
		final bytecodeId = if (this.pattern.isNone()) -1 else
			-1; // TODO: determine and pass bytecode ID

		return [fire(bytecodeId)];
	}
}
