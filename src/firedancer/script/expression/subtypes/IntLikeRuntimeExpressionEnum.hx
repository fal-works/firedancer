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
	UnaryOperator(
		type: IntUnaryOperatorType,
		operand: IntLikeExpressionEnum
	);

	/**
		@param type Type that determines which `Opcode` to use.
		@param operandA The first int-like expression to be operated.
		@param operandB The second int-like expression to be operated.
	**/
	BinaryOperator(
		type: IntBinaryOperatorType,
		operandA: IntLikeExpressionEnum,
		operandB: IntLikeExpressionEnum
	);
}

@:structInit
class IntUnaryOperatorType {
	public final constantOperator: IntConstantUnaryOperator;

	/**
		Any `Opcode` that operates the volatile int and reassigns the result to the volatile int.
	**/
	public final operateVV: Opcode;
}

enum IntConstantUnaryOperator {
	/**
		Calculates immediately in compile-time.
		@param func Any function that takes a int value and returns another int.
	**/
	Immediate(func: (v: Int) -> Int);

	/**
		Applies a single instruction.
		@param opcodeCV Any `Opcode` that operates a given constant int and assigns the result to the volatile int.
	**/
	Instruction(opcodeCV: Opcode);

	/**
		Uses `IntUnaryOperatorType.operateVV`.
	**/
	None;
}

@:structInit
class IntBinaryOperatorType {
	/**
		Any function that takes two int values and returns another int.

		This can only be set if the result can be calculated in compile-time.
	**/
	public final operateConstants: Maybe<(a: Int, b: Int) -> Int>;

	/**
		Any `Opcode` that operates the two below and reassigns the result to the volatile int.
		1. The current volatile int
		2. The given constant int
	**/
	public final operateVCV: Maybe<Opcode>;

	/**
		Any `Opcode` that operates the two below and reassigns the result to the volatile int.
		1. The given constant int
		2. The current volatile int
	**/
	public final operateCVV: Maybe<Opcode>;

	/**
		Any `Opcode` that operates the two below and reassigns the result to the volatile int.
		1. The last saved volatile int
		2. The current volatile int
	**/
	public final operateVVV: Opcode;

	function new(
		operateVVV: Opcode,
		?operateConstants: Int->Int->Int,
		?operateVCV: Opcode,
		?operateCVV: Opcode
	) {
		this.operateConstants = Maybe.from(operateConstants);
		this.operateVCV = Maybe.from(operateVCV);
		this.operateCVV = Maybe.from(operateCVV);
		this.operateVVV = operateVVV;
	}
}
