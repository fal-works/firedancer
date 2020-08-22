package firedancer.script.expression.subtypes;

import firedancer.assembly.AssemblyCode;
import firedancer.assembly.Instruction;

typedef FloatLikeRuntimeExpressionEnum = RuntimeExpressionEnum<FloatLikeConstant, FloatLikeExpressionData>;

/**
	Abstract over `FloatLikeRuntimeExpressionEnum`.
**/
@:notNull @:forward
abstract FloatLikeRuntimeExpression(
	FloatLikeRuntimeExpressionEnum
) from FloatLikeRuntimeExpressionEnum to FloatLikeRuntimeExpressionEnum {
	@:to public function toString(): String {
		return switch this {
			case Variable(loadV):
				'Var(${loadV.toString()})';
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
				loadV;

			case UnaryOperation(instruction, operandExpr):
				final code = operandExpr.loadToVolatile(context);
				code.push(instruction);
				code;

			case BinaryOperation(instruction, operandExprA, operandExprB):
				final code: AssemblyCode = [];
				code.pushFromArray(operandExprB.loadToVolatile(context));
				code.push(Push(Float(Reg)));
				code.pushFromArray(operandExprA.loadToVolatile(context));
				code.push(Save(Float(Reg)));
				code.push(Pop(Float));
				code.push(instruction);
				code;

			case Custom(loadToVolatile):
				loadToVolatile(context);
		}
	}

	public extern inline function toEnum(): FloatLikeRuntimeExpressionEnum
		return this;
}
