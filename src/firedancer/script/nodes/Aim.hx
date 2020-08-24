package firedancer.script.nodes;

import firedancer.script.expression.AngleExpression;
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

	override public inline function containsWait(): Bool
		return false;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final bearingToTarget = AngleExpression.fromEnum(Runtime(Variable(LoadBearingToTargetR)));
		final node = new SetActorProperty(ShotVelocity, if (speed.isSome()) {
			SetVector({ length: speed.unwrap(), angle: bearingToTarget });
		} else {
			SetAngle(bearingToTarget);
		});

		return node.toAssembly(context);
	}
}
