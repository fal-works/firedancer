package firedancer.script.nodes;

/**
	Emits a new actor.
**/
@:ripper_verified
class Fire implements ripper.Data implements AstNode {
	public final pattern: Maybe<Ast>;

	public inline function containsWait(): Bool
		return false;

	public function toAssembly(context: CompileContext): AssemblyCode {
		final bytecodeId = if (this.pattern.isNone()) -1 else {
			context.setCode(pattern.unwrap().toAssembly(context));
		};

		return [fire(bytecodeId)];
	}
}
