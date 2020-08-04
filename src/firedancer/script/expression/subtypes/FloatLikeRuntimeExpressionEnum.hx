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
		Any function that takes a float value and returns another float.

		This can only be set if the result can be calculated in compile-time.
	**/
	public final operateConstantFloat: Maybe<(v: Float) -> Float>;

	/**
		Any `Opcode` that operates a given constant float and assigns the result to the volatile float.
	**/
	public final operateFloatCV: Maybe<Opcode>;

	/**
		Any `Opcode` that operates the volatile float and reassigns the result to the volatile float.
	**/
	public final operateFloatVV: Opcode;

	function new(
		operateFloatVV: Opcode,
		?operateConstantFloat: Float->Float,
		?operateFloatCV: Opcode
	) {
		this.operateConstantFloat = Maybe.from(operateConstantFloat);
		this.operateFloatCV = Maybe.from(operateFloatCV);
		this.operateFloatVV = operateFloatVV;
	}
}

@:structInit
class FloatBinaryOperatorType {
	/**
		Any function that takes two float values and returns another float.

		This can only be set if the result can be calculated in compile-time.
	**/
	public final operateConstantFloats: Maybe<(a: Float, b: Float) -> Float>;

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

	function new(
		operateFloatsVVV: Opcode,
		?operateConstantFloats: Float->Float->Float,
		?operateFloatsVCV: Opcode,
		?operateFloatsCVV: Opcode
	) {
		this.operateConstantFloats = Maybe.from(operateConstantFloats);
		this.operateFloatsVCV = Maybe.from(operateFloatsVCV);
		this.operateFloatsCVV = Maybe.from(operateFloatsCVV);
		this.operateFloatsVVV = operateFloatsVVV;
	}
}
