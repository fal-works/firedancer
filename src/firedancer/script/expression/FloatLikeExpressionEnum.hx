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
		_this: FloatLikeExpressionEnum,
		constantFactor: Float
	): AssemblyCode {
		return switch _this {
			case Constant(value):
				new AssemblyStatement(
					calc(LoadFloatCV),
					[value.toOperand(constantFactor)]
				);
			case Runtime(expression):
				expression.loadToVolatileFloat(constantFactor);
		}
	}

	/**
		Creates an `AssemblyCode` that runs either `constantOpcode` or `volatileOpcode`
		receiving `this` value as argument.
	**/
	public static function use(
		_this: FloatLikeExpressionEnum,
		constantOpcode: Opcode,
		volatileOpcode: Opcode,
		constantFactor: Float
	): AssemblyCode {
		return switch _this {
			case Constant(value):
				new AssemblyStatement(
					constantOpcode,
					[value.toOperand(constantFactor)]
				);
			case Runtime(expression):
				final code = expression.loadToVolatileFloat(constantFactor);
				code.push(new AssemblyStatement(volatileOpcode, []));
				code;
		}
	}

	public static function unaryMinus(
		_this: FloatLikeExpressionEnum
	): FloatLikeExpressionEnum {
		return Runtime(FloatLikeRuntimeExpressionEnum.UnaryOperator({
			constantOperator: Immediate(v -> -v),
			operateVV: calc(MinusFloatV)
		}, _this));
	}

	public static function add(
		_this: FloatLikeExpressionEnum,
		other: FloatLikeExpressionEnum
	): FloatLikeExpressionEnum {
		return Runtime(FloatLikeRuntimeExpressionEnum.BinaryOperator({
			operateConstants: (a, b) -> a + b,
			operateVCV: calc(AddFloatVCV),
			operateCVV: calc(AddFloatVCV),
			operateVVV: calc(AddFloatVVV)
		}, _this, other));
	}

	public static function subtract(
		_this: FloatLikeExpressionEnum,
		other: FloatLikeExpressionEnum
	): FloatLikeExpressionEnum {
		return Runtime(FloatLikeRuntimeExpressionEnum.BinaryOperator({
			operateConstants: (a, b) -> a - b,
			operateVCV: calc(SubFloatVCV),
			operateCVV: calc(SubFloatCVV),
			operateVVV: calc(SubFloatVVV)
		}, _this, other));
	}

	public static function multiply(
		_this: FloatLikeExpressionEnum,
		other: FloatLikeExpressionEnum
	): FloatLikeExpressionEnum {
		return Runtime(FloatLikeRuntimeExpressionEnum.BinaryOperator({
			operateConstants: (a, b) -> a * b,
			operateVCV: calc(MultFloatVCV),
			operateCVV: calc(MultFloatVCV),
			operateVVV: calc(MultFloatVVV)
		}, _this, other));
	}

	public static function divide(
		_this: FloatLikeExpressionEnum,
		other: FloatLikeExpressionEnum
	): FloatLikeExpressionEnum {
		switch _this {
			case Constant(_):
			case Runtime(_):
				switch other {
					case Constant(valueB):
						// multiply by the reciprocal: rt / c => rt * (1 / c)
						other = Constant(1.0 / valueB);
					case Runtime(_):
				}
		}

		return Runtime(FloatLikeRuntimeExpressionEnum.BinaryOperator({
			operateConstants: (a, b) -> a / b,
			operateVCV: calc(MultFloatVCV), // multiply by the reciprocal
			operateCVV: calc(DivFloatCVV),
			operateVVV: calc(DivFloatVVV)
		}, _this, other));
	}

	public static function modulo(
		_this: FloatLikeExpressionEnum,
		other: FloatLikeExpressionEnum
	): FloatLikeExpressionEnum {
		return Runtime(FloatLikeRuntimeExpressionEnum.BinaryOperator({
			operateConstants: (a, b) -> a % b,
			operateVCV: calc(ModFloatVCV),
			operateCVV: calc(ModFloatCVV),
			operateVVV: calc(ModFloatVVV)
		}, _this, other));
	}
}
