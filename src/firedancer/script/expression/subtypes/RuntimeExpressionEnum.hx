package firedancer.script.expression.subtypes;

import firedancer.assembly.AssemblyCode;
import firedancer.assembly.Instruction;

/**
	Expression that has to be evaluated in runtime.
**/
enum RuntimeExpressionEnum<C, E> {
	/**
		@param loadV `Instruction` for loading the value to the current volatile value.
	**/
	Variable(loadV: Instruction);

	/**
		@param operand An expression to be operated.
	**/
	UnaryOperation(
		instruction: Instruction,
		operand: E
	);

	/**
		@param operandA The first expression to be operated.
		@param operandB The second expression to be operated.
	**/
	BinaryOperation(
		instruction: Instruction,
		operandA: E,
		operandB: E
	);

	Custom(loadToVolatile: (context: CompileContext) -> AssemblyCode);
}
