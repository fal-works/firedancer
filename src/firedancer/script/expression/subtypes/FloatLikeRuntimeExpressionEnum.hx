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
	UnaryOperator(
		type: FloatUnaryOperatorType,
		operand: FloatLikeExpressionEnum
	);

	/**
		@param type Type that determines which `Opcode` to use.
		@param operandA The first float-like expression to be operated.
		@param operandB The second float-like expression to be operated.
	**/
	BinaryOperator(
		type: FloatBinaryOperatorType,
		operandA: FloatLikeExpressionEnum,
		operandB: FloatLikeExpressionEnum
	);
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

@:structInit
class FloatBinaryOperatorType {
	/**
		Any `Opcode` that operates the two below and reassigns the result to the volatile float.
		1. The current volatile float
		2. The given constant float
	**/
	public final operateFloatsVCV: Maybe<Opcode>;

	/**
		Any `Opcode` that operates the two below and reassigns the result to the volatile float.
		1. The given constant float
		2. The current volatile float
	**/
	public final operateFloatsCVV: Maybe<Opcode>;

	/**
		Any `Opcode` that operates the two below and reassigns the result to the volatile float.
		1. The last saved volatile float
		2. The current volatile float
	**/
	public final operateFloatsVVV: Opcode;

	function new(operateFloatsVVV: Opcode, ?operateFloatsVCV: Opcode, ?operateFloatsCVV: Opcode) {
		this.operateFloatsVCV = Maybe.from(operateFloatsVCV);
		this.operateFloatsCVV = Maybe.from(operateFloatsCVV);
		this.operateFloatsVVV = operateFloatsVVV;
	}
}
