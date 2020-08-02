package firedancer.script.expression.subtypes;

import firedancer.assembly.AssemblyCode;
import firedancer.assembly.AssemblyStatement;

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
						new AssemblyStatement(type.operateFloatCV, [value]);
					case Runtime(expression):
						final code = expression.loadToVolatileFloat();
						code.push(new AssemblyStatement(type.operateFloatVV, []));
						code;
				};
			case BinaryOperator(type, operandA, operandB):
				final code: AssemblyCode = [];
				final operateFloatsVCV = type.operateFloatsVCV;
				final operateFloatsVVV = type.operateFloatsVVV;
				switch operandA {
					case Constant(valueA):
						switch operandB {
							case Constant(valueB):
								code.pushStatement(LoadFloatCV, [valueA]);
								if (operateFloatsVCV.isSome())
									code.pushStatement(operateFloatsVCV.unwrap(), [valueB]);
								else {
									code.pushStatement(LoadFloatCV, [valueB]);
									code.pushStatement(operateFloatsVVV, []);
								}
							case Runtime(expressionB):
								if (operateFloatsVCV.isSome()) {
									code.pushFromArray(expressionB.loadToVolatileFloat());
									code.pushStatement(operateFloatsVCV.unwrap(), [valueA]);
								} else {
									code.pushStatement(LoadFloatCV, [valueA]);
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
									code.pushStatement(LoadFloatCV, [valueB]);
									code.pushStatement(operateFloatsVVV);
								}
							case Runtime(expressionB):
								code.pushFromArray(expressionA.loadToVolatileFloat());
								code.pushStatement(PushFloatV);
								code.pushFromArray(expressionB.loadToVolatileFloat());
								code.pushStatement(PeekFloat, [Int(0)]);
								code.pushStatement(operateFloatsVVV);
						};
				};
				code;
		}
	}

	public extern inline function toEnum(): FloatLikeRuntimeExpressionEnum
		return this;
}
