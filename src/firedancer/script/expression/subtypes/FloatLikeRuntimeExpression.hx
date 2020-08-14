package firedancer.script.expression.subtypes;

import firedancer.assembly.AssemblyCode;
import firedancer.assembly.Instruction;
import firedancer.assembly.Opcode;
import firedancer.assembly.Immediate;

typedef FloatLikeRuntimeExpressionEnum = RuntimeExpressionEnum<FloatLikeConstant, FloatLikeExpressionData>;

/**
	Abstract over `FloatLikeRuntimeExpressionEnum`.
**/
@:notNull @:forward
abstract FloatLikeRuntimeExpression(
	FloatLikeRuntimeExpressionEnum
) from FloatLikeRuntimeExpressionEnum to FloatLikeRuntimeExpressionEnum {
	static extern inline final loadOpcode = Opcode.general(LoadFloatCV);
	static extern inline final saveOpcode = Opcode.general(SaveFloatV);

	static function createImmediates(value: Float): Array<Immediate>
		return [Float(value)];

	/**
		Creates an `AssemblyCode` that assigns `this` value to the current volatile float.
	**/
	public function loadToVolatile(context: CompileContext): AssemblyCode {
		return switch this {
			case Variable(loadV):
				new Instruction(loadV, []);

			case UnaryOperation(type, operandExpr):
				final constant = operandExpr.tryGetConstant();
				if (constant.isSome()) {
					switch type.constantOperator {
						case Immediate(func):
							new Instruction(
								loadOpcode,
								[func(constant.unwrap()).toImmediate()]
							);
						case Instruction(opcodeCV):
							new Instruction(opcodeCV, createImmediates(constant.unwrap()));
						case None:
							[
								new Instruction(
									loadOpcode,
									createImmediates(constant.unwrap())
								),
								new Instruction(type.runtimeOperator, [])
							];
					}
				} else {
					final code = operandExpr.loadToVolatile(context);
					code.push(new Instruction(type.runtimeOperator, []));
					code;
				}

			case BinaryOperation(type, operandExprA, operandExprB):
				final code:AssemblyCode = [];
				final operateConstants = type.operateConstants;
				final operateVCV = type.operateVCV;
				final operateCVV = type.operateCVV;
				final operateVVV = type.operateVVV;

				final constantA = operandExprA.tryGetConstant();
				final constantB = operandExprB.tryGetConstant();

				if (constantA.isSome()) {
					final valA = constantA.unwrap();
					final operandsA = createImmediates(valA);
					if (constantB.isSome()) {
						final valB = constantB.unwrap();
						if (operateConstants.isSome()) {
							final valueAB: FloatLikeConstant = operateConstants.unwrap()(
								valA,
								valB
							);
							code.pushInstruction(loadOpcode, [valueAB.toImmediate()]);
						} else {
							final operandsB = createImmediates(valB);
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
							code.pushFromArray(operandExprB.loadToVolatile(context));
							code.pushInstruction(operateCVV.unwrap(), operandsA);
						} else {
							code.pushInstruction(loadOpcode, operandsA);
							code.pushInstruction(saveOpcode);
							code.pushFromArray(operandExprB.loadToVolatile(context));
							code.pushInstruction(operateVVV);
						}
					}
				} else {
					if (constantB.isSome()) {
						final valB = constantB.unwrap();
						final operandsB = createImmediates(valB);
						if (operateVCV.isSome()) {
							code.pushFromArray(operandExprA.loadToVolatile(context));
							code.pushInstruction(operateVCV.unwrap(), operandsB);
						} else {
							code.pushFromArray(operandExprA.loadToVolatile(context));
							code.pushInstruction(saveOpcode);
							code.pushInstruction(loadOpcode, operandsB);
							code.pushInstruction(operateVVV);
						}
					} else {
						code.pushFromArray(operandExprA.loadToVolatile(context));
						code.pushInstruction(saveOpcode);
						code.pushFromArray(operandExprB.loadToVolatile(context));
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
