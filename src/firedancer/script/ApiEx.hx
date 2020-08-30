package firedancer.script;

import firedancer.script.expression.IntExpression;
import firedancer.script.expression.FloatExpression;
import firedancer.script.expression.AngleExpression;
import firedancer.script.nodes.*;

/**
	Built-in shorthands/aliases using `Api` functions.
**/
class ApiEx {
	/**
		Shorthand for repeating `ast` changing the shot direction until it circles around.
	**/
	public static function radial(ast: Ast, params: { ways: IntExpression }): Ast {
		final loopCount = Api.intVar("__loopCnt");
		final shotDirectionChangeRate = Api.angleVar("__sDirChgRt");

		return [
			loopCount.let(params.ways),
			shotDirectionChangeRate.let(360 / loopCount),
			Api.rep(loopCount, [
				ast,
				Api.shot.direction.add(shotDirectionChangeRate)
			])
		];
	}

	/**
		Shorthand for `dup()` with `shotDirectionRange`.

		This:

		```
		nWay(fire(), { ways: 3, angle: 30 })
		```

		is the same as:

		```
		dup(fire(), {
			count: 3,
			shotDirectionRange: { start: -15, end: 15 }
		})
		```
	**/
	public static function nWay(
		ast: Ast,
		params: { ways: IntExpression, angle: AngleExpression }
	): Duplicate {
		return Api.dup(ast, {
			count: params.ways,
			shotDirectionRange: { start: -params.angle / 2, end: params.angle / 2 }
		});
	}

	/**
		Alias for `dup()` with `shotSpeedChange`.
	**/
	public static function line(
		ast: Ast,
		params: { count: IntExpression, shotSpeedChange: FloatExpression }
	): Duplicate {
		return Api.dup(ast, {
			count: params.count,
			shotSpeedChange: params.shotSpeedChange
		});
	}
}
