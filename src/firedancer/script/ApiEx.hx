package firedancer.script;

import firedancer.script.expression.IntExpression;
import firedancer.script.expression.AngleExpression;
import firedancer.script.nodes.*;

/**
	Built-in shorthands/aliases using `Api` functions.
**/
class ApiEx {
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
}
