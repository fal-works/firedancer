package firedancer.script.expression.subtypes;

import firedancer.assembly.AssemblyCode;
import firedancer.assembly.Opcode;

/**
	Expression that has to be evaluated in runtime.
**/
enum RuntimeExpressionEnum<C, E> {
	/**
		@param loadV `Opcode` for loading the value to the current volatile value.
	**/
	Variable(loadV: Opcode);

	/**
		@param type Type that determines which `Opcode` to use.
		@param operand An expression to be operated.
	**/
	UnaryOperation(
		type: SimpleUnaryOperator<C>,
		operand: E
	);

	/**
		@param type Type that determines which `Opcode` to use.
		@param operandA The first expression to be operated.
		@param operandB The second expression to be operated.
	**/
	BinaryOperation(
		type: SimpleBinaryOperator<C>,
		operandA: E,
		operandB: E
	);

	Custom(loadToVolatile: (context: CompileContext) -> AssemblyCode);
}
