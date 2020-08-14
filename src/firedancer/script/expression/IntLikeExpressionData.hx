package firedancer.script.expression;

import firedancer.assembly.Opcode;
import firedancer.assembly.Opcode.*;
import firedancer.assembly.Instruction;
import firedancer.assembly.AssemblyCode;
import firedancer.assembly.ConstantOperand;
import firedancer.script.expression.FloatLikeExpressionData;
import firedancer.script.expression.subtypes.IntLikeRuntimeExpression;
import firedancer.script.expression.subtypes.IntLikeConstant;
import firedancer.script.expression.subtypes.SimpleUnaryOperator;
import firedancer.script.expression.subtypes.SimpleBinaryOperator;
import firedancer.script.expression.subtypes.FloatLikeRuntimeExpression;

enum IntLikeExpressionEnum {
	Constant(value: IntLikeConstant);
	Runtime(expression: IntLikeRuntimeExpression);
}

/**
	Expression representing any float value.
**/
@:structInit
class IntLikeExpressionData implements ExpressionData {
	public static extern inline function create(
		data: IntLikeExpressionEnum
	): IntLikeExpressionData {
		return { data: data };
	}

	public final data: IntLikeExpressionEnum;

	public function toFloatExpression(): FloatExpression
		return this.toFloatLikeExpressionData(FloatExpression.constantFactor);

	public function toAngleExpression(): AngleExpression
		return this.toFloatLikeExpressionData(AngleExpression.constantFactor);

	/**
		Creates an `AssemblyCode` that assigns `this` value to the current volatile float.
	**/
	public function loadToVolatile(context: CompileContext): AssemblyCode {
		return switch this.data {
			case Constant(value):
				new Instruction(general(LoadIntCV), [value.toOperand()]);
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

	public function tryGetConstantOperandValue(): Maybe<Int> {
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
		return if (value.isSome()) Maybe.from(Int(value.unwrap())) else Maybe.none();
	}

	public function unaryOperation(
		type: SimpleUnaryOperator<Int>
	): IntLikeExpressionData {
		return create(Runtime(IntLikeRuntimeExpressionEnum.UnaryOperation(
			type,
			this
		)));
	}

	public function binaryOperation(
		type: SimpleBinaryOperator<Int>,
		otherOperand: IntLikeExpressionData
	): IntLikeExpressionData {
		return create(Runtime(IntLikeRuntimeExpressionEnum.BinaryOperation(
			type,
			this,
			otherOperand
		)));
	}

	public function unaryMinus(): IntLikeExpressionData {
		return unaryOperation({
			constantOperator: Immediate(v -> -v),
			runtimeOperator: calc(MinusIntV)
		});
	}

	public function add(other: IntLikeExpressionData): IntLikeExpressionData {
		return binaryOperation({
			operateConstants: (a, b) -> a + b,
			operateVCV: calc(AddIntVCV),
			operateCVV: calc(AddIntVCV),
			operateVVV: calc(AddIntVVV)
		}, other);
	}

	public function subtract(other: IntLikeExpressionData): IntLikeExpressionData {
		return binaryOperation({
			operateConstants: (a, b) -> a - b,
			operateVCV: calc(SubIntVCV),
			operateCVV: calc(SubIntCVV),
			operateVVV: calc(SubIntVVV)
		}, other);
	}

	public function multiply(other: IntLikeExpressionData): IntLikeExpressionData {
		return binaryOperation({
			operateConstants: (a, b) -> a * b,
			operateVCV: calc(MultIntVCV),
			operateCVV: calc(MultIntVCV),
			operateVVV: calc(MultIntVVV)
		}, other);
	}

	public function divide(other: IntLikeExpressionData): IntLikeExpressionData {
		return binaryOperation({
			operateConstants: (a, b) -> Ints.divide(a, b),
			operateVCV: calc(DivIntVCV),
			operateCVV: calc(DivIntCVV),
			operateVVV: calc(DivIntVVV)
		}, other);
	}

	public function modulo(other: IntLikeExpressionData): IntLikeExpressionData {
		return binaryOperation({
			operateConstants: (a, b) -> a % b,
			operateVCV: calc(ModIntVCV),
			operateCVV: calc(ModIntCVV),
			operateVVV: calc(ModIntVVV)
		}, other);
	}

	public extern inline function toEnum()
		return this.data;

	function toFloatLikeExpressionData(constantFactor: Float): FloatLikeExpressionData {
		final constant = this.tryGetConstantOperandValue();

		final loadAsFloat: (context:CompileContext) -> AssemblyCode = if (constant.isSome()) {
			context -> new Instruction(
				general(LoadFloatCV),
				[Float(constantFactor * constant.unwrap())]
			);
		} else {
			context -> [
				this.loadToVolatile(context),
				[new Instruction(calc(CastIntToFloatVV), [])],
				if (constantFactor == 1.0) [] else [
					new Instruction(calc(MultFloatVCV), [Float(constantFactor)])
				]
			].flatten();
		}

		final data = FloatLikeExpressionEnum.Runtime(FloatLikeRuntimeExpressionEnum.Custom(loadAsFloat));

		return FloatLikeExpressionData.create(data);
	}
}
