package firedancer.script.expression;

import firedancer.assembly.Opcode;
import firedancer.assembly.Opcode.*;
import firedancer.assembly.Instruction;
import firedancer.assembly.AssemblyCode;
import firedancer.assembly.ConstantOperand;
import firedancer.script.expression.subtypes.FloatLikeConstant;
import firedancer.script.expression.subtypes.FloatLikeRuntimeExpression;
import firedancer.script.expression.subtypes.SimpleUnaryOperator;
import firedancer.script.expression.subtypes.SimpleBinaryOperator;

/**
	Expression representing any float value.
**/
enum FloatLikeExpressionEnum {
	Constant(value: FloatLikeConstant);
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
	public function loadToVolatile(context: CompileContext): AssemblyCode {
		return switch this.data {
			case Constant(value):
				new Instruction(general(LoadFloatCV), [value.toOperand()]);
			case Runtime(expression):
				expression.loadToVolatile(context);
		}
	}

	/**
		Creates an `AssemblyCode` that runs either `constantOpcode` or `volatileOpcode`
		receiving `this` value as argument.
	**/
	public function use(context: CompileContext, constantOpcode: Opcode, volatileOpcode: Opcode): AssemblyCode {
		final constantOperand = tryGetConstantOperand();

		return if (constantOperand.isSome()) {
			new Instruction(constantOpcode, [constantOperand.unwrap()]);
		} else [
			loadToVolatile(context),
			[new Instruction(volatileOpcode, [])]
		].flatten();
	}

	public function tryGetConstantOperandValue(): Maybe<Float> {
		switch this.data {
			case Constant(value):
				return Maybe.from(value.toOperandValue());
			case Runtime(expression):
				switch expression.toEnum() {
					case UnaryOperation(type, operand):
						final value = operand.tryGetConstantOperandValue();
						if (value.isSome()) {
							switch type.constantOperator {
								case Immediate(func):
									return Maybe.from(func(value.unwrap()).raw());
								default:
							}
						}
					case BinaryOperation(type, operandA, operandB):
						final valueA = operandA.tryGetConstantOperandValue();
						final valueB = operandB.tryGetConstantOperandValue();
						if (valueA.isSome() && valueB.isSome() && type.operateConstants.isSome()) {
							final operate = type.operateConstants.unwrap();
							return Maybe.from(operate(
								valueA.unwrap(),
								valueB.unwrap()
							).raw());
						}
					default:
				}
		}

		return Maybe.none();
	}

	public function tryGetConstantOperand(): Maybe<ConstantOperand> {
		final value = tryGetConstantOperandValue();
		return if (value.isSome()) Maybe.from(Float(value.unwrap())) else Maybe.none();
	}

	public function unaryOperation(
		type: SimpleUnaryOperator<FloatLikeConstant>
	): FloatLikeExpressionData {
		return create(Runtime(FloatLikeRuntimeExpressionEnum.UnaryOperation(
			type,
			this
		)));
	}

	public function binaryOperation(
		type: SimpleBinaryOperator<FloatLikeConstant>,
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
				final otherValue = other.tryGetConstantOperandValue();
				if (otherValue.isSome()) {
					// multiply by the reciprocal: rt / c => rt * (1 / c)
					other = create(Constant(1.0 / otherValue.unwrap()));
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
