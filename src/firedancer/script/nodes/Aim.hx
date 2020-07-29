package firedancer.script.nodes;

import firedancer.script.expression.FloatExpression;
import firedancer.script.expression.FloatArgument;
import firedancer.script.expression.AzimuthExpression;

/**
	Sets actor's shot direction to the bearing to the target position.
**/
@:ripper_verified
class Aim extends AstNode implements ripper.Data {
	var speed: Maybe<FloatExpression> = Maybe.none();

	/**
		Sets shot speed.
	**/
	public inline function shotSpeed(speed: FloatArgument): Aim {
		this.speed = Maybe.from(speed);
		return this;
	}

	override public inline function containsWait(): Bool
		return false;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final bearingToTarget = AzimuthExpression.Variable(LoadBearingToTargetV);
		final node = new OperateActor(ShotVelocity, if (speed.isSome()) {
			SetVector({ length: speed.unwrap(), angle: bearingToTarget });
		} else SetAngle(bearingToTarget));

		return node.toAssembly(context);
	}
}
