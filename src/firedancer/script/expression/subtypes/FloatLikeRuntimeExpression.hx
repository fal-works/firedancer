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
	public function loadToVolatile(constantFactor: Float): AssemblyCode {
		return switch this {
			case Variable(loadV):
				new AssemblyStatement(loadV, []);

			case UnaryOperator(type, operand):
				switch operand.toEnum() {
					case Constant(value):
						final operandValue = value.toOperandValue(constantFactor);
						switch type.constantOperator {
							case Immediate(func):
								new AssemblyStatement(
									calc(LoadFloatCV),
									[Float(func(operandValue))]
								);
							case Instruction(opcodeCV):
								new AssemblyStatement(opcodeCV, [Float(operandValue)]);
							case None:
								[
									new AssemblyStatement(
										calc(LoadFloatCV),
										[Float(operandValue)]
									),
									new AssemblyStatement(type.operateVV, [])
								];
						}
					case Runtime(expression):
						final code = expression.loadToVolatile(constantFactor);
						code.push(new AssemblyStatement(type.operateVV, []));
						code;
				};

			case BinaryOperator(type, operandA, operandB):
				final code:AssemblyCode = [];
				final operateConstants = type.operateConstants;
				final operateVCV = type.operateVCV;
				final operateCVV = type.operateCVV;
				final operateVVV = type.operateVVV;
				switch operandA.toEnum() {
					case Constant(valueA):
						final operandsA = [valueA.toOperand(constantFactor)];
						switch operandB.toEnum() {
							case Constant(valueB):
								if (operateConstants.isSome()) {
									final valueAB: FloatLikeConstant = operateConstants.unwrap()(
										valueA,
										valueB
									);
									code.pushStatement(
										calc(LoadFloatCV),
										[valueAB.toOperand(constantFactor)]
									);
								} else {
									final operandsB = [valueB.toOperand(constantFactor)];
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
									code.pushFromArray(expressionB.loadToVolatile(constantFactor));
									code.pushStatement(operateCVV.unwrap(), operandsA);
								} else {
									code.pushStatement(calc(LoadFloatCV), operandsA);
									code.pushStatement(calc(SaveFloatV));
									code.pushFromArray(expressionB.loadToVolatile(constantFactor));
									code.pushStatement(operateVVV);
								}
						};
					case Runtime(expressionA):
						switch operandB.toEnum() {
							case Constant(valueB):
								final operandsB = [valueB.toOperand(constantFactor)];
								if (operateVCV.isSome()) {
									code.pushFromArray(expressionA.loadToVolatile(constantFactor));
									code.pushStatement(operateVCV.unwrap(), operandsB);
								} else {
									code.pushFromArray(expressionA.loadToVolatile(constantFactor));
									code.pushStatement(calc(SaveFloatV));
									code.pushStatement(calc(LoadFloatCV), operandsB);
									code.pushStatement(operateVVV);
								}
							case Runtime(expressionB):
								code.pushFromArray(expressionA.loadToVolatile(constantFactor));
								code.pushStatement(calc(SaveFloatV));
								code.pushFromArray(expressionB.loadToVolatile(constantFactor));
								code.pushStatement(operateVVV);
						};
				};
				code;
		}
	}

	public extern inline function toEnum(): FloatLikeRuntimeExpressionEnum
		return this;
}
