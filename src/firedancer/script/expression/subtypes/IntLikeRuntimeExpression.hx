package firedancer.script.expression.subtypes;

import firedancer.assembly.AssemblyCode;
import firedancer.assembly.AssemblyStatement;
import firedancer.assembly.Opcode.*;

typedef IntLikeRuntimeExpressionEnum = RuntimeExpressionEnum<IntLikeConstant, IntLikeExpressionData>;

/**
	Abstract over `IntLikeRuntimeExpressionEnum`.
**/
@:notNull @:forward
abstract IntLikeRuntimeExpression(
	IntLikeRuntimeExpressionEnum
) from IntLikeRuntimeExpressionEnum to IntLikeRuntimeExpressionEnum {
	/**
		Creates an `AssemblyCode` that assigns `this` value to the current volatile float.
	**/
	public function loadToVolatile(): AssemblyCode {
		return switch this {
			case Variable(loadV):
				new AssemblyStatement(loadV, []);

			case UnaryOperation(type, operand):
				switch operand.toEnum() {
					case Constant(value):
						final operandValue = value.toOperandValue();
						switch type.constantOperator {
							case Immediate(func):
								new AssemblyStatement(
									calc(LoadIntCV),
									[func(operandValue).toOperand()]
								);
							case Instruction(opcodeCV):
								new AssemblyStatement(opcodeCV, [value.toOperand()]);
							case None:
								[
									new AssemblyStatement(
										calc(LoadIntCV),
										[value.toOperand()]
									),
									new AssemblyStatement(type.runtimeOperator, [])
								];
						}
					case Runtime(expression):
						final code = expression.loadToVolatile();
						code.push(new AssemblyStatement(type.runtimeOperator, []));
						code;
				};

			case BinaryOperation(type, operandA, operandB):
				final code:AssemblyCode = [];
				final operateConstants = type.operateConstants;
				final operateVCV = type.operateVCV;
				final operateCVV = type.operateCVV;
				final operateVVV = type.operateVVV;
				switch operandA.toEnum() {
					case Constant(valueA):
						final operandsA = [valueA.toOperand()];
						switch operandB.toEnum() {
							case Constant(valueB):
								if (operateConstants.isSome()) {
									final valueAB: IntLikeConstant = operateConstants.unwrap()(
										valueA,
										valueB
									);
									code.pushStatement(
										calc(LoadIntCV),
										[valueAB.toOperand()]
									);
								} else {
									final operandsB = [valueB.toOperand()];
									code.pushStatement(calc(LoadIntCV), operandsA);
									if (operateVCV.isSome())
										code.pushStatement(operateVCV.unwrap(), operandsB);
									else {
										code.pushStatement(calc(SaveIntV));
										code.pushStatement(calc(LoadIntCV), operandsB);
										code.pushStatement(operateVVV, []);
									}
								}
							case Runtime(expressionB):
								if (operateCVV.isSome()) {
									code.pushFromArray(expressionB.loadToVolatile());
									code.pushStatement(operateCVV.unwrap(), operandsA);
								} else {
									code.pushStatement(calc(LoadIntCV), operandsA);
									code.pushStatement(calc(SaveIntV));
									code.pushFromArray(expressionB.loadToVolatile());
									code.pushStatement(operateVVV);
								}
						};
					case Runtime(expressionA):
						switch operandB.toEnum() {
							case Constant(valueB):
								final operandsB = [valueB.toOperand()];
								if (operateVCV.isSome()) {
									code.pushFromArray(expressionA.loadToVolatile());
									code.pushStatement(operateVCV.unwrap(), operandsB);
								} else {
									code.pushFromArray(expressionA.loadToVolatile());
									code.pushStatement(calc(SaveIntV));
									code.pushStatement(calc(LoadIntCV), operandsB);
									code.pushStatement(operateVVV);
								}
							case Runtime(expressionB):
								code.pushFromArray(expressionA.loadToVolatile());
								code.pushStatement(calc(SaveIntV));
								code.pushFromArray(expressionB.loadToVolatile());
								code.pushStatement(operateVVV);
						};
				};
				code;
		}
	}

	public extern inline function toEnum(): IntLikeRuntimeExpressionEnum
		return this;
}
