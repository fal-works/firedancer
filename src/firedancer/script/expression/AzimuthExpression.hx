package firedancer.script.expression;

import firedancer.assembly.Opcode;
import firedancer.assembly.AssemblyCode;
import firedancer.types.Azimuth;

/**
	Expression representing any `Azimuth` value.
**/
@:using(firedancer.script.expression.AzimuthExpression.AzimuthExpressionExtension)
enum AzimuthExpression {
	Constant(value: Azimuth);

	/**
		@param loadV `Opcode` for loading the value to the current volatile float.
	**/
	Variable(loadV: Opcode);
}

class AzimuthExpressionExtension {
	/**
		Converts `this` to `FloatArgument`.
	**/
	public static inline function toFloat(_this: AzimuthExpression): FloatArgument {
		return switch _this {
			case Constant(value): value.toRadians();
			case Variable(loadV): FloatExpression.Variable(loadV);
		}
	}

	/**
		Creates an `AssemblyCode` that runs either `constantOpcode` or `volatileOpcode`
		receiving `this` value as argument.
	**/
	public static function use(
		_this: AzimuthExpression,
		constantOpcode: Opcode,
		volatileOpcode: Opcode
	): AssemblyCode {
		return _this.toFloat().use(constantOpcode, volatileOpcode);
	}
}
