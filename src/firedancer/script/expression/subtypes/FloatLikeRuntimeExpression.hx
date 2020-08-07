package firedancer.script.expression.subtypes;

import firedancer.assembly.AssemblyCode;
import firedancer.assembly.AssemblyStatement;
import firedancer.assembly.Opcode.*;

/**
	Abstract over `FloatLikeRuntimeExpressionEnum`.
**/
@:notNull @:forward
abstract FloatLikeRuntimeExpression(
	FloatLikeRuntimeExpressionEnum
) from FloatLikeRuntimeExpressionEnum to FloatLikeRuntimeExpressionEnum {
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
									calc(LoadFloatCV),
									[func(operandValue).toOperand()]
								);
							case Instruction(opcodeCV):
								new AssemblyStatement(opcodeCV, [Float(operandValue)]);
							case None:
								[
									new AssemblyStatement(
										calc(LoadFloatCV),
										[Float(operandValue)]
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
									final valueAB: FloatLikeConstant = operateConstants.unwrap()(
										valueA,
										valueB
									);
									code.pushStatement(
										calc(LoadFloatCV),
										[valueAB.toOperand()]
									);
								} else {
									final operandsB = [valueB.toOperand()];
									code.pushStatement(calc(LoadFloatCV), operandsA);
									if (operateVCV.isSome())
										code.pushStatement(operateVCV.unwrap(), operandsB);
									else {
										code.pushStatement(calc(SaveFloatV));
										code.pushStatement(calc(LoadFloatCV), operandsB);
										code.pushStatement(operateVVV, []);
									}
								}
							case Runtime(expressionB):
								if (operateCVV.isSome()) {
									code.pushFromArray(expressionB.loadToVolatile());
									code.pushStatement(operateCVV.unwrap(), operandsA);
								} else {
									code.pushStatement(calc(LoadFloatCV), operandsA);
									code.pushStatement(calc(SaveFloatV));
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
									code.pushStatement(calc(SaveFloatV));
									code.pushStatement(calc(LoadFloatCV), operandsB);
									code.pushStatement(operateVVV);
								}
							case Runtime(expressionB):
								code.pushFromArray(expressionA.loadToVolatile());
								code.pushStatement(calc(SaveFloatV));
								code.pushFromArray(expressionB.loadToVolatile());
								code.pushStatement(operateVVV);
						};
				};
				code;
		}
	}

	public extern inline function toEnum(): FloatLikeRuntimeExpressionEnum
		return this;
}
