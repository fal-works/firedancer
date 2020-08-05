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
	public function loadToVolatileFloat(): AssemblyCode {
		return switch this {
			case Variable(loadV):
				new AssemblyStatement(loadV, []);

			case UnaryOperator(type, operand):
				switch operand {
					case Constant(value):
						switch type.constantOperator {
							case Immediate(func):
								new AssemblyStatement(
									general(LoadFloatCV),
									[Float(func(value.toFloat()))]
								);
							case Instruction(opcodeCV):
								new AssemblyStatement(opcodeCV, [value]);
							case None:
								[
									new AssemblyStatement(general(LoadFloatCV), [value]),
									new AssemblyStatement(type.operateVV, [])
								];
						}
					case Runtime(expression):
						final code = expression.loadToVolatileFloat();
						code.push(new AssemblyStatement(type.operateVV, []));
						code;
				};

			case BinaryOperator(type, operandA, operandB):
				final code:AssemblyCode = [];
				final operateConstantFloats = type.operateConstantFloats;
				final operateFloatsVCV = type.operateFloatsVCV;
				final operateFloatsCVV = type.operateFloatsCVV;
				final operateFloatsVVV = type.operateFloatsVVV;
				switch operandA {
					case Constant(valueA):
						switch operandB {
							case Constant(valueB):
								if (operateConstantFloats.isSome()) {
									final valueAB = operateConstantFloats.unwrap()(
										valueA.toFloat(),
										valueB.toFloat()
									);
									code.pushStatement(general(LoadFloatCV), [Float(valueAB)]);
								} else {
									code.pushStatement(general(LoadFloatCV), [valueA]);
									if (operateFloatsVCV.isSome())
										code.pushStatement(operateFloatsVCV.unwrap(), [valueB]);
									else {
										code.pushStatement(general(SaveFloatV));
										code.pushStatement(general(LoadFloatCV), [valueB]);
										code.pushStatement(operateFloatsVVV, []);
									}
								}
							case Runtime(expressionB):
								if (operateFloatsCVV.isSome()) {
									code.pushFromArray(expressionB.loadToVolatileFloat());
									code.pushStatement(operateFloatsCVV.unwrap(), [valueA]);
								} else {
									code.pushStatement(general(LoadFloatCV), [valueA]);
									code.pushStatement(general(SaveFloatV));
									code.pushFromArray(expressionB.loadToVolatileFloat());
									code.pushStatement(operateFloatsVVV);
								}
						};
					case Runtime(expressionA):
						switch operandB {
							case Constant(valueB):
								if (operateFloatsVCV.isSome()) {
									code.pushFromArray(expressionA.loadToVolatileFloat());
									code.pushStatement(operateFloatsVCV.unwrap(), [valueB]);
								} else {
									code.pushFromArray(expressionA.loadToVolatileFloat());
									code.pushStatement(general(SaveFloatV));
									code.pushStatement(general(LoadFloatCV), [valueB]);
									code.pushStatement(operateFloatsVVV);
								}
							case Runtime(expressionB):
								code.pushFromArray(expressionA.loadToVolatileFloat());
								code.pushStatement(general(SaveFloatV));
								code.pushFromArray(expressionB.loadToVolatileFloat());
								code.pushStatement(operateFloatsVVV);
						};
				};
				code;
		}
	}

	public extern inline function toEnum(): FloatLikeRuntimeExpressionEnum
		return this;
}
