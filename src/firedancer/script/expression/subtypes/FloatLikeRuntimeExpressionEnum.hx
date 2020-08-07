package firedancer.script.expression.subtypes;

import firedancer.assembly.Opcode;

/**
	Expression of any float-like type that has to be evaluated in runtime.
**/
enum FloatLikeRuntimeExpressionEnum {
	/**
		@param loadV `Opcode` for loading the value to the current volatile float.
	**/
	Variable(loadV: Opcode);

	/**
		@param type Type that determines which `Opcode` to use.
		@param operand A float-like expression to be operated.
	**/
	UnaryOperation(
		type: UnaryOperator<Float>,
		operand: FloatLikeExpressionData
	);

	/**
		@param type Type that determines which `Opcode` to use.
		@param operandA The first float-like expression to be operated.
		@param operandB The second float-like expression to be operated.
	**/
	BinaryOperation(
		type: BinaryOperator<Float>,
		operandA: FloatLikeExpressionData,
		operandB: FloatLikeExpressionData
	);
}
