package firedancer.script.expression.subtypes;

import firedancer.assembly.AssemblyCode;
import firedancer.assembly.Instruction;
import firedancer.assembly.Opcode;
import firedancer.assembly.OpcodeExtension;
import firedancer.assembly.Immediate;

typedef IntLikeRuntimeExpressionEnum = RuntimeExpressionEnum<IntLikeConstant, IntLikeExpressionData>;

/**
	Abstract over `IntLikeRuntimeExpressionEnum`.
**/
@:notNull @:forward
abstract IntLikeRuntimeExpression(
	IntLikeRuntimeExpressionEnum
) from IntLikeRuntimeExpressionEnum to IntLikeRuntimeExpressionEnum {
	static extern inline final loadOpcode = Opcode.general(LoadIntCV);
	static extern inline final saveOpcode = Opcode.general(SaveIntV);
	static extern inline final pushOpcode = Opcode.general(PushIntV);
	static extern inline final popOpcode = Opcode.general(PopInt);

	static function createImmediates(value: Int): Array<Immediate>
		return [Int(value)];

	@:to public function toString(): String {
		return switch this {
			case Variable(loadV):
				'Var(${OpcodeExtension.toString(loadV)})';
			case UnaryOperation(_, operand):
				'UnOp(${operand.toString()})';
			case BinaryOperation(_, operandA, operandB):
				'BiOp(${operandA.toString()}, ${operandB.toString()})';
			case Custom(_):
				"Custom";
		}
	}

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
				final commutative = type.commutative;

				final constantA = operandExprA.tryGetConstant();
				final constantB = operandExprB.tryGetConstant();

				if (constantA.isSome()) {
					final valA = constantA.unwrap();
					final operandsA = createImmediates(valA);
					if (constantB.isSome()) {
						// A: const, B: const
						final valB = constantB.unwrap();
						if (operateConstants.isSome()) {
							final valueAB: IntLikeConstant = operateConstants.unwrap()(
								valA,
								valB
							);
							code.pushInstruction(loadOpcode, [valueAB.toImmediate()]);
						} else {
							final operandsB = createImmediates(valB);
							if (operateVCV.isSome()) {
								code.pushInstruction(loadOpcode, operandsA);
								code.pushInstruction(operateVCV.unwrap(), operandsB);
							} else if(commutative && operateCVV.isSome()) {
								code.pushInstruction(loadOpcode, operandsB);
								code.pushInstruction(operateCVV.unwrap(), operandsA);
							} else {
								code.pushInstruction(loadOpcode, operandsA);
								code.pushInstruction(saveOpcode);
								code.pushInstruction(loadOpcode, operandsB);
								code.pushInstruction(operateVVV, []);
							}
						}
					} else {
						// A: const, B: runtime
						if (operateCVV.isSome()) {
							code.pushFromArray(operandExprB.loadToVolatile(context));
							code.pushInstruction(operateCVV.unwrap(), operandsA);
						} else if (commutative && operateVCV.isSome()) {
							code.pushFromArray(operandExprB.loadToVolatile(context));
							code.pushInstruction(operateVCV.unwrap(), operandsA);
						} else if (commutative) {
							code.pushFromArray(operandExprB.loadToVolatile(context));
							code.pushInstruction(saveOpcode);
							code.pushInstruction(loadOpcode, operandsA);
							code.pushInstruction(operateVVV);
						} else {
							code.pushFromArray(operandExprB.loadToVolatile(context));
							code.pushInstruction(pushOpcode);
							code.pushInstruction(loadOpcode, operandsA);
							code.pushInstruction(saveOpcode);
							code.pushInstruction(popOpcode);
							code.pushInstruction(operateVVV);

							// If operandExprB does not use the buffer register, the below also works:
							// code.pushInstruction(loadOpcode, operandsA);
							// code.pushInstruction(saveOpcode);
							// code.pushFromArray(operandExprB.loadToVolatile(context));
							// code.pushInstruction(operateVVV);
						}
					}
				} else {
					if (constantB.isSome()) {
						// A: runtime, B: const
						final valB = constantB.unwrap();
						final operandsB = createImmediates(valB);
						if (operateVCV.isSome()) {
							code.pushFromArray(operandExprA.loadToVolatile(context));
							code.pushInstruction(operateVCV.unwrap(), operandsB);
						} else if (commutative && operateCVV.isSome()) {
							code.pushFromArray(operandExprA.loadToVolatile(context));
							code.pushInstruction(operateCVV.unwrap(), operandsB);
						} else {
							code.pushFromArray(operandExprA.loadToVolatile(context));
							code.pushInstruction(saveOpcode);
							code.pushInstruction(loadOpcode, operandsB);
							code.pushInstruction(operateVVV);
						}
					} else {
						// A: runtime, B: runtime
						code.pushFromArray(operandExprB.loadToVolatile(context));
						code.pushInstruction(pushOpcode);
						code.pushFromArray(operandExprA.loadToVolatile(context));
						code.pushInstruction(saveOpcode);
						code.pushInstruction(popOpcode);
						code.pushInstruction(operateVVV);

						// If operandExprB does not use the buffer register, the below also works:
						// code.pushFromArray(operandExprA.loadToVolatile(context));
						// code.pushInstruction(saveOpcode);
						// code.pushFromArray(operandExprB.loadToVolatile(context));
						// code.pushInstruction(operateVVV);
					}
				}

				code;

			case Custom(loadToVolatile):
				loadToVolatile(context);
		}
	}

	public extern inline function toEnum(): IntLikeRuntimeExpressionEnum
		return this;
}
