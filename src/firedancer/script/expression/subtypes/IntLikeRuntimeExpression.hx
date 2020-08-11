package firedancer.script.expression.subtypes;

import firedancer.assembly.AssemblyCode;
import firedancer.assembly.AssemblyStatement;
import firedancer.assembly.Opcode.*;
import firedancer.assembly.ConstantOperand;

typedef IntLikeRuntimeExpressionEnum = RuntimeExpressionEnum<IntLikeConstant, IntLikeExpressionData>;

/**
	Abstract over `IntLikeRuntimeExpressionEnum`.
**/
@:notNull @:forward
abstract IntLikeRuntimeExpression(
	IntLikeRuntimeExpressionEnum
) from IntLikeRuntimeExpressionEnum to IntLikeRuntimeExpressionEnum {
	static extern inline final loadOpcode = general(LoadIntCV);
	static extern inline final saveOpcode = general(SaveIntV);

	static function createOperands(value: Int): Array<ConstantOperand>
		return [Int(value)];

	/**
		Creates an `AssemblyCode` that assigns `this` value to the current volatile float.
	**/
	public function loadToVolatile(): AssemblyCode {
		return switch this {
			case Variable(loadV):
				new AssemblyStatement(loadV, []);

			case UnaryOperation(type, operand):
				final operandValue = operand.tryGetConstantOperandValue();
				if (operandValue.isSome()) {
					switch type.constantOperator {
						case Immediate(func):
							new AssemblyStatement(
								loadOpcode,
								[func(operandValue.unwrap()).toOperand()]
							);
						case Instruction(opcodeCV):
							new AssemblyStatement(opcodeCV, createOperands(operandValue.unwrap()));
						case None:
							[
								new AssemblyStatement(
									loadOpcode,
									createOperands(operandValue.unwrap())
								),
								new AssemblyStatement(type.runtimeOperator, [])
							];
					}
				} else {
					final code = operand.loadToVolatile();
					code.push(new AssemblyStatement(type.runtimeOperator, []));
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
							final valueAB: IntLikeConstant = operateConstants.unwrap()(
								valA,
								valB
							);
							code.pushStatement(loadOpcode, [valueAB.toOperand()]);
						} else {
							final operandsB = createOperands(valB);
							code.pushStatement(loadOpcode, operandsA);
							if (operateVCV.isSome())
								code.pushStatement(operateVCV.unwrap(), operandsB);
							else {
								code.pushStatement(saveOpcode);
								code.pushStatement(loadOpcode, operandsB);
								code.pushStatement(operateVVV, []);
							}
						}
					} else {
						if (operateCVV.isSome()) {
							code.pushFromArray(operandB.loadToVolatile());
							code.pushStatement(operateCVV.unwrap(), operandsA);
						} else {
							code.pushStatement(loadOpcode, operandsA);
							code.pushStatement(saveOpcode);
							code.pushFromArray(operandB.loadToVolatile());
							code.pushStatement(operateVVV);
						}
					}
				} else {
					if (operandValueB.isSome()) {
						final valB = operandValueB.unwrap();
						final operandsB = createOperands(valB);
						if (operateVCV.isSome()) {
							code.pushFromArray(operandA.loadToVolatile());
							code.pushStatement(operateVCV.unwrap(), operandsB);
						} else {
							code.pushFromArray(operandA.loadToVolatile());
							code.pushStatement(saveOpcode);
							code.pushStatement(loadOpcode, operandsB);
							code.pushStatement(operateVVV);
						}
					} else {
						code.pushFromArray(operandA.loadToVolatile());
						code.pushStatement(saveOpcode);
						code.pushFromArray(operandB.loadToVolatile());
						code.pushStatement(operateVVV);
					}
				}

				code;

			case Custom(loadToVolatile):
				loadToVolatile;
		}
	}

	public extern inline function toEnum(): IntLikeRuntimeExpressionEnum
		return this;
}
