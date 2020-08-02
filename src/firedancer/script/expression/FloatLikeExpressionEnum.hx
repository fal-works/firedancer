package firedancer.script.expression;

import reckoner.Geometry;
import firedancer.script.expression.subtypes.FloatLikeRuntimeExpressionEnum;
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
	public static function toAzimuthExpression(
		_this: FloatLikeExpressionEnum
	): AzimuthExpression {
		return switch _this {
			case Constant(value):
				value.toAzimuth();
			default:
				_this;
		};
	}

	/**
		Creates an `AssemblyCode` that assigns `this` value to the current volatile float.
	**/
	public static function loadToVolatileFloat(
		_this: FloatLikeExpressionEnum,
		type: FloatLikeExpressionType
	): AssemblyCode {
		return switch _this {
			case Constant(value):
				switch type {
					case Azimuth: value += Geometry.MINUS_HALF_PI;
					case Default:
				}
				new AssemblyStatement(LoadFloatCV, [value]);
			case Runtime(expression):
				final code = expression.loadToVolatileFloat();
				switch type {
					case Azimuth:
						code.pushStatement(AddFloatVCV, [Float(Geometry.MINUS_HALF_PI)]);
					case Default:
				}
				code;
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

	public static function add(
		_this: FloatLikeExpressionEnum,
		other: FloatLikeExpressionEnum
	): FloatLikeExpressionEnum {
		return switch _this {
			case Constant(valueA):
				switch other {
					case Constant(valueB):
						FloatLikeExpressionEnum.Constant(valueA + valueB);
					case Runtime(_):
						FloatLikeExpressionEnum.Runtime(FloatLikeRuntimeExpressionEnum.BinaryOperator(
							{
								operateFloatsVCV: AddFloatVCV,
								operateFloatsVVV: AddFloatVVV
							},
							_this,
							other
						));
				}
			case Runtime(_):
				FloatLikeExpressionEnum.Runtime(FloatLikeRuntimeExpressionEnum.BinaryOperator(
					{ operateFloatsVCV: AddFloatVCV, operateFloatsVVV: AddFloatVVV },
					_this,
					other
				));
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
