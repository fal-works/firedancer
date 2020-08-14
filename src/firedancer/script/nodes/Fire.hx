package firedancer.script.nodes;

import firedancer.bytecode.types.FireArgument;

/**
	Emits a new actor.
**/
@:ripper_verified
class Fire extends AstNode implements ripper.Data {
	final pattern: Maybe<Ast>;
	var bindPosition = false;
	var fireCode(default, null): Int = 0;

	/**
		Binds the position of the actor being fired to the position of the actor that fires it.
	**/
	public inline function bind(): Fire {
		this.bindPosition = true;
		return this;
	}

	/**
		Specifies the fire code value (which is `0` at default) to any user-defined value.

		This does not affect the FiredancerVM directly, but you can use the value
		to branch the process in your own `Emitter` class
		(e.g. switch graphics of the actor to be emitted).
	**/
	public inline function code(fireCode: Int): Fire {
		this.fireCode = fireCode;
		return this;
	}

	override public inline function containsWait(): Bool
		return false;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final fireArgument: Maybe<FireArgument> = if (this.pattern.isNone()) {
			Maybe.none();
		} else {
			final programId = context.setCode(this.pattern.unwrap().toAssembly(context));
			Maybe.from(FireArgument.from(programId, this.bindPosition));
		};

		return [fire(fireArgument, this.fireCode)];
	}
}
