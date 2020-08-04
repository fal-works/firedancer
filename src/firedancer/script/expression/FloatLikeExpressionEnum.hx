package firedancer.script.expression;

import firedancer.assembly.Opcode;
import firedancer.assembly.Opcode.*;
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
				new AssemblyStatement(general(LoadFloatCV), [value]);
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

	public static function add(
		_this: FloatLikeExpressionEnum,
		other: FloatLikeExpressionEnum
	): FloatLikeExpressionEnum {
		switch _this {
			case Constant(valueA):
				switch other {
					case Constant(valueB):
						return Constant(valueA + valueB);
					case Runtime(_):
				}
			case Runtime(_):
		}

		return Runtime(FloatLikeRuntimeExpressionEnum.BinaryOperator({
			operateFloatsVCV: general(AddFloatVCV),
			operateFloatsCVV: general(AddFloatVCV),
			operateFloatsVVV: general(AddFloatVVV)
		}, _this, other));
	}

	public static function subtract(
		_this: FloatLikeExpressionEnum,
		other: FloatLikeExpressionEnum
	): FloatLikeExpressionEnum {
		switch _this {
			case Constant(valueA):
				switch other {
					case Constant(valueB):
						return Constant(valueA - valueB);
					case Runtime(_):
				}
			case Runtime(_):
		}

		return Runtime(FloatLikeRuntimeExpressionEnum.BinaryOperator({
			operateFloatsVCV: general(SubFloatVCV),
			operateFloatsCVV: general(SubFloatCVV),
			operateFloatsVVV: general(SubFloatVVV)
		}, _this, other));
	}

	public static function multiply(
		_this: FloatLikeExpressionEnum,
		other: FloatLikeExpressionEnum
	): FloatLikeExpressionEnum {
		switch _this {
			case Constant(valueA):
				switch other {
					case Constant(valueB):
						return Constant(valueA * valueB);
					case Runtime(_):
				};
			case Runtime(_):
		}

		return Runtime(FloatLikeRuntimeExpressionEnum.BinaryOperator({
			operateFloatsVCV: general(MultFloatVCV),
			operateFloatsCVV: general(MultFloatVCV),
			operateFloatsVVV: general(MultFloatVVV)
		}, _this, other));
	}

	public static function divide(
		_this: FloatLikeExpressionEnum,
		other: FloatLikeExpressionEnum
	): FloatLikeExpressionEnum {
		// TODO: refactor

		switch _this {
			case Constant(valueA):
				switch other {
					case Constant(valueB):
						return Constant(valueA / valueB);
					case Runtime(_):
				};
			case Runtime(_):
				switch other {
					case Constant(valueB):
						// multiply the reciprocal
						return Runtime(FloatLikeRuntimeExpressionEnum.BinaryOperator(
							{
								operateFloatsVCV: general(MultFloatVCV),
								operateFloatsVVV: general(DivFloatVVV)
							},
							_this,
							Constant(FloatLikeConstant.fromFloat(1.0) / valueB)
						));
					case Runtime(_):
				}
		}

		return Runtime(FloatLikeRuntimeExpressionEnum.BinaryOperator({
			operateFloatsCVV: general(DivFloatCVV),
			operateFloatsVVV: general(DivFloatVVV)
		}, _this, other));
	}
}
