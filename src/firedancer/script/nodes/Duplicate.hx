package firedancer.script.nodes;

import firedancer.script.expression.IntExpression;
import firedancer.script.expression.FloatExpression;
import firedancer.script.expression.AngleExpression;

/**
	Duplicates the provided `AstNode` with some duplication parameters,
	and then resets all changes made during the duplication.
**/
class Duplicate extends AstNode {
	public final node: AstNode;
	public final params: DuplicateParameters;

	public function new(node: AstNode, params: DuplicateParameters) {
		this.node = node;
		this.params = params;
	}

	override public inline function containsWait(): Bool {
		return this.node.containsWait() || this.params.intervalFrames != null;
	}

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final params = this.params;
		final preparation: Array<AstNode> = [];
		final interval: Array<AstNode> = [];
		final completion: Array<AstNode> = [];

		final varCount = Api.intVar("__loopCount");
		preparation.push(varCount.let(params.count - 1));

		if (params.intervalFrames != null) {
			interval.push(Api.wait(params.intervalFrames));
		}

		if (params.shotDistanceChange != null) {
			final shotDistanceChange = params.shotDistanceChange;
			final varInitialShotDistance = Api.floatVar("__initialShotDistance");
			final varShotDistanceChangeRate = Api.floatVar("__shotDistanceChangeRate");
			preparation.push(varInitialShotDistance.let(Api.shot.distance));
			preparation.push(
				varShotDistanceChangeRate.let(shotDistanceChange / varCount)
			);
			interval.push(Api.shot.distance.add(varShotDistanceChangeRate));
			completion.push(Api.shot.distance.set(varInitialShotDistance));
		}

		if (params.shotBearingRange != null) {
			final range: AngleRange = params.shotBearingRange;
			final varInitialShotBearing = Api.angleVar("__initialShotBearing");
			final varShotBearingChangeRate = Api.angleVar("__shotBearingChangeRate");
			preparation.push(varInitialShotBearing.let(Api.shot.bearing));
			preparation.push(Api.shot.bearing.add(range.start));
			preparation.push(
				varShotBearingChangeRate.let((range.end - range.start) / varCount)
			);
			interval.push(Api.shot.bearing.add(varShotBearingChangeRate));
			completion.push(Api.shot.bearing.set(varInitialShotBearing));
		}

		if (params.shotSpeedChange != null) {
			final shotSpeedChange = params.shotSpeedChange;
			final varInitialShotSpeed = Api.floatVar("__initialShotSpeed");
			final varShotSpeedChangeRate = Api.floatVar("__shotSpeedChangeRate");
			preparation.push(varInitialShotSpeed.let(Api.shot.speed));
			preparation.push(varShotSpeedChangeRate.let(shotSpeedChange / varCount));
			interval.push(Api.shot.speed.add(varShotSpeedChangeRate));
			completion.push(Api.shot.speed.set(varInitialShotSpeed));
		}

		if (params.shotDirectionRange != null) {
			final range: AngleRange = params.shotDirectionRange;
			final varInitialShotDirection = Api.angleVar("__initialShotDirection");
			final varShotDirectionChangeRate = Api.angleVar("__shotDirectionChangeRate");
			preparation.push(varInitialShotDirection.let(Api.shot.direction));
			preparation.push(Api.shot.direction.add(range.start));
			preparation.push(
				varShotDirectionChangeRate.let((range.end - range.start) / varCount)
			);
			interval.push(Api.shot.direction.add(varShotDirectionChangeRate));
			completion.push(Api.shot.direction.set(varInitialShotDirection));
		}

		final rep = Api.rep(varCount, [
			[this.node],
			interval
		].flatten());

		final totalAst: Ast = preparation.concat([rep, this.node]).concat(completion);

		return totalAst.toAssembly(context);
	}
}

private typedef AngleRange = { start: AngleExpression, end: AngleExpression };

typedef DuplicateParameters = {
	/**
		The repetition count. If the evaluated value is `0` or less, the result is unspecified.
	**/
	final count: IntExpression;

	/**
		Number of interval frames to wait.
	**/
	final ?intervalFrames: IntExpression;

	/**
		The total change of the shot distance, relative from the current value.
	**/
	final ?shotDistanceChange: FloatExpression;

	/**
		The `start`/`end` values of the shot bearing, relative from the current value.
	**/
	final ?shotBearingRange: AngleRange;

	/**
		The total change of the shot speed, relative from the current value.
	**/
	final ?shotSpeedChange: FloatExpression;

	/**
		The `start`/`end` values of the shot direction, relative from the current value.
	**/
	final ?shotDirectionRange: AngleRange;
};
