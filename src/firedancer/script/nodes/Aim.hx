package firedancer.script.nodes;

import firedancer.script.expression.FloatExpression;

/**
	Sets actor's shot direction to the bearing to the target position.
**/
@:ripper_verified
class Aim extends AstNode implements ripper.Data {
	var speed: Maybe<FloatExpression> = Maybe.none();

	/**
		Sets shot speed.
	**/
	public inline function shotSpeed(speed: FloatExpression): Aim {
		this.speed = Maybe.from(speed);
		return this;
	}

	override inline function containsWait(): Bool
		return false;

	override function toAssembly(context: CompileContext): AssemblyCode {
		final node = new SetActorProperty(ShotVelocity, if (speed.isSome()) {
			SetVector({ length: speed.unwrap(), angle: Api.shot.angleToTarget });
		} else {
			SetAngle(Api.shot.angleToTarget);
		});

		return node.toAssembly(context);
	}
}
