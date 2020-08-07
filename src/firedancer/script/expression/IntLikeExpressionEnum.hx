package firedancer.script.expression;

import firedancer.assembly.Opcode;
import firedancer.assembly.Opcode.*;
import firedancer.assembly.AssemblyStatement;
import firedancer.assembly.AssemblyCode;
import firedancer.script.expression.subtypes.IntLikeConstant;
import firedancer.script.expression.subtypes.IntLikeRuntimeExpression;

/**
	Expression representing any float value.
**/
@:using(firedancer.script.expression.IntLikeExpressionEnum.IntLikeExpressionExtensionEnum)
enum IntLikeExpressionEnum {
	Constant(value: IntLikeConstant);
	Runtime(expression: IntLikeRuntimeExpression);
}

class IntLikeExpressionExtensionEnum {
	/**
		Creates an `AssemblyCode` that assigns `this` value to the current volatile float.
	**/
	public static function loadToVolatile(
		_this: IntLikeExpressionEnum
	): AssemblyCode {
		return switch _this {
			case Constant(value):
				new AssemblyStatement(
					calc(LoadIntCV),
					[value.toOperand()]
				);
			case Runtime(expression):
				expression.loadToVolatile();
		}
	}

	/**
		Creates an `AssemblyCode` that runs either `constantOpcode` or `volatileOpcode`
		receiving `this` value as argument.
	**/
	public static function use(
		_this: IntLikeExpressionEnum,
		constantOpcode: Opcode,
		volatileOpcode: Opcode
	): AssemblyCode {
		return switch _this {
			case Constant(value):
				new AssemblyStatement(
					constantOpcode,
					[value.toOperand()]
				);
			case Runtime(expression):
				final code = expression.loadToVolatile();
				code.push(new AssemblyStatement(volatileOpcode, []));
				code;
		}
	}

	public static function unaryMinus(
		_this: IntLikeExpressionEnum
	): IntLikeExpressionEnum {
		return Runtime(IntLikeRuntimeExpressionEnum.UnaryOperator({
			constantOperator: Immediate(v -> -v),
			operateVV: calc(MinusIntV)
		}, _this));
	}

	public static function add(
		_this: IntLikeExpressionEnum,
		other: IntLikeExpressionEnum
	): IntLikeExpressionEnum {
		return Runtime(IntLikeRuntimeExpressionEnum.BinaryOperator({
			operateConstants: (a, b) -> a + b,
			operateVCV: calc(AddIntVCV),
			operateCVV: calc(AddIntVCV),
			operateVVV: calc(AddIntVVV)
		}, _this, other));
	}

	public static function subtract(
		_this: IntLikeExpressionEnum,
		other: IntLikeExpressionEnum
	): IntLikeExpressionEnum {
		return Runtime(IntLikeRuntimeExpressionEnum.BinaryOperator({
			operateConstants: (a, b) -> a - b,
			operateVCV: calc(SubIntVCV),
			operateCVV: calc(SubIntCVV),
			operateVVV: calc(SubIntVVV)
		}, _this, other));
	}

	public static function multiply(
		_this: IntLikeExpressionEnum,
		other: IntLikeExpressionEnum
	): IntLikeExpressionEnum {
		return Runtime(IntLikeRuntimeExpressionEnum.BinaryOperator({
			operateConstants: (a, b) -> a * b,
			operateVCV: calc(MultIntVCV),
			operateCVV: calc(MultIntVCV),
			operateVVV: calc(MultIntVVV)
		}, _this, other));
	}

	public static function divide(
		_this: IntLikeExpressionEnum,
		other: IntLikeExpressionEnum
	): IntLikeExpressionEnum {
		return Runtime(IntLikeRuntimeExpressionEnum.BinaryOperator({
			operateConstants: (a, b) -> Ints.divide(a, b),
			operateVCV: calc(DivIntVCV),
			operateCVV: calc(DivIntCVV),
			operateVVV: calc(DivIntVVV)
		}, _this, other));
	}

	public static function modulo(
		_this: IntLikeExpressionEnum,
		other: IntLikeExpressionEnum
	): IntLikeExpressionEnum {
		return Runtime(IntLikeRuntimeExpressionEnum.BinaryOperator({
			operateConstants: (a, b) -> a % b,
			operateVCV: calc(ModIntVCV),
			operateCVV: calc(ModIntCVV),
			operateVVV: calc(ModIntVVV)
		}, _this, other));
	}
}
