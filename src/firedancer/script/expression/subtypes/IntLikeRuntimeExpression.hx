package firedancer.script.expression.subtypes;

import firedancer.assembly.AssemblyCode;

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
		case Inst(loadV):
			'Inst(${loadV.toString()})';
		case UnaryOperation(_, operand):
			'UnOp(${operand.toString()})';
		case BinaryOperation(_, operandA, operandB):
			'BiOp(${operandA.toString()}, ${operandB.toString()})';
		case Custom(_):
			"Custom";
		}
	}

	/**
		Creates an `AssemblyCode` that assigns `this` value to the int register.
	**/
	public function load(context: CompileContext): AssemblyCode {
		return switch this {
		case Inst(loadV):
			loadV;

		case UnaryOperation(instruction, operandExpr):
			final code = operandExpr.load(context);
			code.push(instruction);
			code;

		case BinaryOperation(instruction, operandExprA, operandExprB):
			final code:AssemblyCode = [];
			code.pushFromArray(operandExprB.load(context));
			code.push(Push(Int(Reg)));
			code.pushFromArray(operandExprA.load(context));
			code.push(Save(Int(Reg)));
			code.push(Pop(Int));
			code.push(instruction);
			code;

		case Custom(load):
			load(context);
		}
	}

	public extern inline function toEnum(): IntLikeRuntimeExpressionEnum
		return this;
}
