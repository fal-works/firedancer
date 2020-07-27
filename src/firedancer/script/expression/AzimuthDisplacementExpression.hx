package firedancer.script.expression;

import firedancer.assembly.Opcode;
import firedancer.assembly.AssemblyCode;
import firedancer.types.AzimuthDisplacement;

/**
	Expression representing any `AzimuthDisplacementExpression` value.
**/
@:using(firedancer.script.expression.AzimuthDisplacementExpression.AzimuthDisplacementExpressionExtension)
enum AzimuthDisplacementExpression {
	Constant(value: AzimuthDisplacement);

	/**
		@param loadV `Opcode` for loading the value to the current volatile float.
	**/
	Variable(loadV: Opcode);
}

class AzimuthDisplacementExpressionExtension {
	/**
		Converts `this` to `FloatArgument`.
	**/
	public static inline function toFloat(_this: AzimuthDisplacementExpression): FloatArgument {
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
		_this: AzimuthDisplacementExpression,
		constantOpcode: Opcode,
		volatileOpcode: Opcode
	): AssemblyCode {
		return _this.toFloat().use(constantOpcode, volatileOpcode);
	}
}
