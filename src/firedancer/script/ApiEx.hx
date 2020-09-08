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
		@param ast `fire()` at default.
	**/
	public static function radial(ways: IntExpression, ?ast: Ast): Ast {
		final loopCount = Api.intVar("__loopCnt");
		final shotDirectionChangeRate = Api.angleVar("__sDirChgRt");

		if (ast == null) ast = Api.fire();

		return [
			loopCount.let(ways),
			shotDirectionChangeRate.let((360.0 : AngleExpression) / loopCount),
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

		@param ways The numer of ways. If the evaluated value is `0` or less, the result is unspecified.
		@param ast `fire()` at default.
	**/
	public static function nWay(
		ways: IntExpression,
		params: { angle: AngleExpression },
		?ast: Ast
	): Duplicate {
		final angle = params.angle;

		return Api.dup(
			ways,
			{ shotDirectionRange: { start: -angle / 2, end: angle / 2 } },
			ast
		);
	}

	/**
		Alias for `dup()` with `shotSpeedChange`.
		@param count The repetition count. If the evaluated value is `0` or less, the result is unspecified.
		@param ast `fire()` at default.
	**/
	public static function line(
		count: IntExpression,
		params: { shotSpeedChange: FloatExpression },
		?ast: Ast
	): Duplicate {
		return Api.dup(
			count,
			{ shotSpeedChange: params.shotSpeedChange },
			ast
		);
	}
}
