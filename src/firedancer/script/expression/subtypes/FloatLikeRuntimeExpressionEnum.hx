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
		@param operand The operand float-like expression.
	**/
	UnaryOperator(type: FloatUnaryOperatorType, operand: FloatLikeExpressionEnum);
}

@:structInit
class FloatUnaryOperatorType {
	/**
		Any `Opcode` that operates a given constant float and assigns the result to the volatile float.
	**/
	public final operateFloatCV: Opcode;

	/**
		Any `Opcode` that operates the volatile float and reassigns the result to the volatile float.
	**/
	public final operateFloatVV: Opcode;
}
