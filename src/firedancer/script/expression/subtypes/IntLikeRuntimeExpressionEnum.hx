package firedancer.script.expression.subtypes;

import firedancer.assembly.Opcode;

/**
	Expression of any int-like type that has to be evaluated in runtime.
**/
enum IntLikeRuntimeExpressionEnum {
	/**
		@param loadV `Opcode` for loading the value to the current volatile int.
	**/
	Variable(loadV: Opcode);

	/**
		@param type Type that determines which `Opcode` to use.
		@param operand An int-like expression to be operated.
	**/
	UnaryOperation(
		type: UnaryOperator<Int>,
		operand: IntLikeExpressionData
	);

	/**
		@param type Type that determines which `Opcode` to use.
		@param operandA The first int-like expression to be operated.
		@param operandB The second int-like expression to be operated.
	**/
	BinaryOperation(
		type: BinaryOperator<Int>,
		operandA: IntLikeExpressionData,
		operandB: IntLikeExpressionData
	);
}
