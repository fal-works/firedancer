package firedancer.script.expression;

import firedancer.assembly.Opcode;
import firedancer.assembly.AssemblyStatement;
import firedancer.assembly.AssemblyCode;
import firedancer.script.expression.subtypes.FloatLikeConstant;
import firedancer.script.expression.subtypes.FloatLikeRuntimeExpression;

/**
	Expression representing any float value.
**/
@:using(firedancer.script.expression.FloatLikeExpressionEnum.FloatLikeExpressionExtensionEnum)
enum FloatLikeExpressionEnum {
	Constant(value: FloatLikeConstant);
	Runtime(expression: FloatLikeRuntimeExpression);
}

class FloatLikeExpressionExtensionEnum {
	/**
		Creates an `AssemblyCode` that assigns `this` value to the current volatile float.
	**/
	public static function loadToVolatileFloat(
		_this: FloatLikeExpressionEnum
	): AssemblyCode {
		return switch _this {
			case Constant(value):
				new AssemblyStatement(LoadFloatCV, [value]);
			case Runtime(expression):
				expression.loadToVolatileFloat();
		}
	}

	/**
		Creates an `AssemblyCode` that runs either `constantOpcode` or `volatileOpcode`
		receiving `this` value as argument.
	**/
	public static function use(
		_this: FloatLikeExpressionEnum,
		constantOpcode: Opcode,
		volatileOpcode: Opcode
	): AssemblyCode {
		return switch _this {
			case Constant(value):
				new AssemblyStatement(constantOpcode, [value]);
			case Runtime(expression):
				final code = expression.loadToVolatileFloat();
				code.push(new AssemblyStatement(volatileOpcode, []));
				code;
		}
	}

	public static function divide(
		_this: FloatLikeExpressionEnum,
		divisor: Float
	): FloatLikeExpressionEnum {
		return switch _this {
			case Constant(value): FloatLikeExpressionEnum.Constant(value / divisor);
			case Runtime(_): throw "Not yet implemented.";
		}
	}
}
