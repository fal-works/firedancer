package firedancer.script.expression.subtypes;

import firedancer.assembly.AssemblyCode;
import firedancer.assembly.Instruction;
import firedancer.assembly.Opcode.*;
import firedancer.assembly.ConstantOperand;

typedef FloatLikeRuntimeExpressionEnum = RuntimeExpressionEnum<FloatLikeConstant, FloatLikeExpressionData>;

/**
	Abstract over `FloatLikeRuntimeExpressionEnum`.
**/
@:notNull @:forward
abstract FloatLikeRuntimeExpression(
	FloatLikeRuntimeExpressionEnum
) from FloatLikeRuntimeExpressionEnum to FloatLikeRuntimeExpressionEnum {
	static extern inline final loadOpcode = general(LoadFloatCV);
	static extern inline final saveOpcode = general(SaveFloatV);

	static function createOperands(value: Float): Array<ConstantOperand>
		return [Float(value)];

	/**
		Creates an `AssemblyCode` that assigns `this` value to the current volatile float.
	**/
	public function loadToVolatile(context: CompileContext): AssemblyCode {
		return switch this {
			case Variable(loadV):
				new Instruction(loadV, []);

			case UnaryOperation(type, operand):
				final operandValue = operand.tryGetConstantOperandValue();
				if (operandValue.isSome()) {
					switch type.constantOperator {
						case Immediate(func):
							new Instruction(
								loadOpcode,
								[func(operandValue.unwrap()).toOperand()]
							);
						case Instruction(opcodeCV):
							new Instruction(opcodeCV, createOperands(operandValue.unwrap()));
						case None:
							[
								new Instruction(
									loadOpcode,
									createOperands(operandValue.unwrap())
								),
								new Instruction(type.runtimeOperator, [])
							];
					}
				} else {
					final code = operand.loadToVolatile(context);
					code.push(new Instruction(type.runtimeOperator, []));
					code;
				}

			case BinaryOperation(type, operandA, operandB):
				final code:AssemblyCode = [];
				final operateConstants = type.operateConstants;
				final operateVCV = type.operateVCV;
				final operateCVV = type.operateCVV;
				final operateVVV = type.operateVVV;

				final operandValueA = operandA.tryGetConstantOperandValue();
				final operandValueB = operandB.tryGetConstantOperandValue();

				if (operandValueA.isSome()) {
					final valA = operandValueA.unwrap();
					final operandsA = createOperands(valA);
					if (operandValueB.isSome()) {
						final valB = operandValueB.unwrap();
						if (operateConstants.isSome()) {
							final valueAB: FloatLikeConstant = operateConstants.unwrap()(
								valA,
								valB
							);
							code.pushInstruction(loadOpcode, [valueAB.toOperand()]);
						} else {
							final operandsB = createOperands(valB);
							code.pushInstruction(loadOpcode, operandsA);
							if (operateVCV.isSome())
								code.pushInstruction(operateVCV.unwrap(), operandsB);
							else {
								code.pushInstruction(saveOpcode);
								code.pushInstruction(loadOpcode, operandsB);
								code.pushInstruction(operateVVV, []);
							}
						}
					} else {
						if (operateCVV.isSome()) {
							code.pushFromArray(operandB.loadToVolatile(context));
							code.pushInstruction(operateCVV.unwrap(), operandsA);
						} else {
							code.pushInstruction(loadOpcode, operandsA);
							code.pushInstruction(saveOpcode);
							code.pushFromArray(operandB.loadToVolatile(context));
							code.pushInstruction(operateVVV);
						}
					}
				} else {
					if (operandValueB.isSome()) {
						final valB = operandValueB.unwrap();
						final operandsB = createOperands(valB);
						if (operateVCV.isSome()) {
							code.pushFromArray(operandA.loadToVolatile(context));
							code.pushInstruction(operateVCV.unwrap(), operandsB);
						} else {
							code.pushFromArray(operandA.loadToVolatile(context));
							code.pushInstruction(saveOpcode);
							code.pushInstruction(loadOpcode, operandsB);
							code.pushInstruction(operateVVV);
						}
					} else {
						code.pushFromArray(operandA.loadToVolatile(context));
						code.pushInstruction(saveOpcode);
						code.pushFromArray(operandB.loadToVolatile(context));
						code.pushInstruction(operateVVV);
					}
				}

				code;

			case Custom(loadToVolatile):
				loadToVolatile(context);
		}
	}

	public extern inline function toEnum(): FloatLikeRuntimeExpressionEnum
		return this;
}
