package firedancer.script.nodes;

/**
	Emits a new actor.
**/
@:ripper_verified
class Fire extends AstNode implements ripper.Data {
	public final pattern: Maybe<Ast>;
	public var fireType(default, null): Int = 0;

	public inline function type(fireType: Int): Fire {
		this.fireType = fireType;
		return this;
	}

	override public inline function containsWait(): Bool
		return false;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final bytecodeId = if (this.pattern.isNone()) -1 else {
			context.setCode(pattern.unwrap().toAssembly(context));
		};

		return [fire(bytecodeId, fireType)];
	}
}
