package firedancer.script.expression;

import firedancer.assembly.Opcode;
import firedancer.assembly.AssemblyCode;
import firedancer.types.Azimuth;
import firedancer.script.expression.FloatExpression;

/**
	Expression representing any `Azimuth` value.
**/
@:using(firedancer.script.expression.AzimuthExpression.AzimuthExpressionExtension)
enum AzimuthExpression {
	Constant(value: Azimuth);
	Runtime(expression: AzimuthRuntimeExpression);
}

@:using(firedancer.script.expression.AzimuthExpression.AzimuthRuntimeExpressionExtension)
enum AzimuthRuntimeExpression {
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
			case Runtime(expression):
				switch expression {
					case Variable(loadV): FloatExpression.Runtime(Variable(loadV));
				}
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

class AzimuthRuntimeExpressionExtension {
	/**
		Converts `this` to `FloatRuntimeExpression`.
	**/
	public static inline function toFloat(
		_this: AzimuthRuntimeExpression
	): FloatRuntimeExpression {
		return switch _this {
			case Variable(loadV): Variable(loadV);
		}
	}
}
