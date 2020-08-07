package firedancer.script.expression.subtypes;

import firedancer.assembly.AssemblyCode;
import firedancer.assembly.AssemblyStatement;
import firedancer.assembly.Opcode.*;

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

			case UnaryOperator(type, operand):
				switch operand {
					case Constant(value):
						switch type.constantOperator {
							case Immediate(func):
								new AssemblyStatement(
									calc(LoadIntCV),
									[Int(func(value))]
								);
							case Instruction(opcodeCV):
								new AssemblyStatement(opcodeCV, [Int(value)]);
							case None:
								[
									new AssemblyStatement(
										calc(LoadIntCV),
										[Int(value)]
									),
									new AssemblyStatement(type.operateVV, [])
								];
						}
					case Runtime(expression):
						final code = expression.loadToVolatile();
						code.push(new AssemblyStatement(type.operateVV, []));
						code;
				};

			case BinaryOperator(type, operandA, operandB):
				final code:AssemblyCode = [];
				final operateConstants = type.operateConstants;
				final operateVCV = type.operateVCV;
				final operateCVV = type.operateCVV;
				final operateVVV = type.operateVVV;
				switch operandA {
					case Constant(valueA):
						final operandsA = [valueA.toOperand()];
						switch operandB {
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
						switch operandB {
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
