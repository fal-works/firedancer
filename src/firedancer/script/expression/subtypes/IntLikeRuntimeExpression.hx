package firedancer.script.expression.subtypes;

import firedancer.assembly.AssemblyCode;
import firedancer.assembly.Instruction;

typedef IntLikeRuntimeExpressionEnum = RuntimeExpressionEnum<IntLikeConstant, IntLikeExpressionData>;

/**
	Abstract over `IntLikeRuntimeExpressionEnum`.
**/
@:notNull @:forward
abstract IntLikeRuntimeExpression(
	IntLikeRuntimeExpressionEnum
) from IntLikeRuntimeExpressionEnum to IntLikeRuntimeExpressionEnum {
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
			final code:AssemblyCode = [];
			code.pushFromArray(operandExprB.loadToVolatile(context));
			code.push(Push(Int(Reg)));
			code.pushFromArray(operandExprA.loadToVolatile(context));
			code.push(Save(Int(Reg)));
			code.push(Pop(Int));
			code.push(instruction);
			code;

		case Custom(loadToVolatile):
			loadToVolatile(context);
		}
	}

	public extern inline function toEnum(): IntLikeRuntimeExpressionEnum
		return this;
}
