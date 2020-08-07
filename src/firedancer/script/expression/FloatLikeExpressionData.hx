package firedancer.script.expression;

import firedancer.assembly.Opcode;
import firedancer.assembly.Opcode.*;
import firedancer.assembly.AssemblyStatement;
import firedancer.assembly.AssemblyCode;
import firedancer.script.expression.subtypes.FloatLikeConstant;
import firedancer.script.expression.subtypes.FloatLikeRuntimeExpression;
import firedancer.script.expression.subtypes.UnaryOperator;
import firedancer.script.expression.subtypes.BinaryOperator;

/**
	Expression representing any float value.
**/
enum FloatLikeExpressionEnum {
	/**
		@param factor The factor by which the constant values should be multiplied when writing into `AssemblyCode`.
	**/
	Constant(value: FloatLikeConstant, factor: Float);

	Runtime(expression: FloatLikeRuntimeExpression);
}

/**
	Wrapper of `FloatLikeExpressionEnum`.
**/
@:structInit
class FloatLikeExpressionData implements ExpressionData {
	public static extern inline function create(
		data: FloatLikeExpressionEnum
	): FloatLikeExpressionData {
		return { data: data };
	}

	/**
		The enum instance.
	**/
	public final data: FloatLikeExpressionEnum;

	/**
		Creates an `AssemblyCode` that assigns `this` value to the current volatile float.
	**/
	public function loadToVolatile(): AssemblyCode {
		return switch this.data {
			case Constant(value, factor):
				new AssemblyStatement(calc(LoadFloatCV), [value.toOperand(factor)]);
			case Runtime(expression):
				expression.loadToVolatile();
		}
	}

	/**
		Creates an `AssemblyCode` that runs either `constantOpcode` or `volatileOpcode`
		receiving `this` value as argument.
	**/
	public function use(constantOpcode: Opcode, volatileOpcode: Opcode): AssemblyCode {
		return switch this.data {
			case Constant(value, factor):
				new AssemblyStatement(constantOpcode, [value.toOperand(factor)]);
			case Runtime(expression):
				final code = expression.loadToVolatile();
				code.push(new AssemblyStatement(volatileOpcode, []));
				code;
		}
	}

	public function unaryOperation(type: UnaryOperator<Float>): FloatLikeExpressionData {
		return create(Runtime(FloatLikeRuntimeExpressionEnum.UnaryOperation(
			type,
			this
		)));
	}

	public function binaryOperation(
		type: BinaryOperator<Float>,
		otherOperand: FloatLikeExpressionData
	): FloatLikeExpressionData {
		return create(Runtime(FloatLikeRuntimeExpressionEnum.BinaryOperation(
			type,
			this,
			otherOperand
		)));
	}

	public function unaryMinus(): FloatLikeExpressionData {
		return unaryOperation({
			constantOperator: Immediate(v -> -v),
			runtimeOperator: calc(MinusFloatV)
		});
	}

	public function add(other: FloatLikeExpressionData): FloatLikeExpressionData {
		return binaryOperation({
			operateConstants: (a, b) -> a + b,
			operateVCV: calc(AddFloatVCV),
			operateCVV: calc(AddFloatVCV),
			operateVVV: calc(AddFloatVVV)
		}, other);
	}

	public function subtract(other: FloatLikeExpressionData): FloatLikeExpressionData {
		return binaryOperation({
			operateConstants: (a, b) -> a - b,
			operateVCV: calc(SubFloatVCV),
			operateCVV: calc(SubFloatCVV),
			operateVVV: calc(SubFloatVVV)
		}, other);
	}

	public function multiply(other: FloatExpression): FloatLikeExpressionData {
		return binaryOperation({
			operateConstants: (a, b) -> a * b,
			operateVCV: calc(MultFloatVCV),
			operateCVV: calc(MultFloatVCV),
			operateVVV: calc(MultFloatVVV)
		}, other);
	}

	public function divide(other: FloatExpression): FloatLikeExpressionData {
		switch this.data {
			case Constant(_):
			case Runtime(_):
				switch other.data {
					case Constant(valueB, factor):
						if (factor != FloatExpression.constantFactor)
							throw 'Detected FloatExpression with factor: $factor (which should be ${FloatExpression.constantFactor})';

						// multiply by the reciprocal: rt / c => rt * (1 / c)
						other = create(Constant(1.0 / valueB, factor));

					case Runtime(_):
				}
		}

		return binaryOperation({
			operateConstants: (a, b) -> a / b,
			operateVCV: calc(MultFloatVCV), // multiply by the reciprocal
			operateCVV: calc(DivFloatCVV),
			operateVVV: calc(DivFloatVVV)
		}, other);
	}

	public function modulo(other: FloatLikeExpressionData): FloatLikeExpressionData {
		return binaryOperation({
			operateConstants: (a, b) -> a % b,
			operateVCV: calc(ModFloatVCV),
			operateCVV: calc(ModFloatCVV),
			operateVVV: calc(ModFloatVVV)
		}, other);
	}

	public extern inline function toEnum(): FloatLikeExpressionEnum
		return this.data;
}
