package firedancer.script.expression.subtypes;

import firedancer.assembly.Opcode;

@:structInit
class GenericBinaryOperator<T, U, V> {
	/**
		Any function that takes two constant values and returns another constant value.

		This can only be set if the result can be calculated in compile-time.
	**/
	public final operateConstants: Maybe<(a: T, b: U) -> V>;

	/**
		Any `Opcode` that operates the two below and reassigns the result to the volatile value.
		1. The current volatile value
		2. The given constant value
	**/
	public final operateVCV: Maybe<Opcode>;

	/**
		Any `Opcode` that operates the two below and reassigns the result to the volatile value.
		1. The given constant value
		2. The current volatile value
	**/
	public final operateCVV: Maybe<Opcode>;

	/**
		Any `Opcode` that operates the two below and reassigns the result to the volatile value.
		1. The last saved volatile value
		2. The current volatile value
	**/
	public final operateVVV: Opcode;

	/**
		`true` if the operands can be swapped.
	**/
	public final commutative: Bool;

	function new(
		operateVVV: Opcode,
		?operateConstants: T->U->V,
		?operateVCV: Opcode,
		?operateCVV: Opcode,
		commutative = false
	) {
		this.operateConstants = Maybe.from(operateConstants);
		this.operateVCV = Maybe.from(operateVCV);
		this.operateCVV = Maybe.from(operateCVV);
		this.operateVVV = operateVVV;
		this.commutative = commutative;
	}
}
