package firedancer.script.expression.subtypes;

import firedancer.assembly.ConstantOperand;

/**
	Value that represents an int-like constant.
**/
@:notNull
abstract IntLikeConstant(haxe.Int32) from Int from haxe.Int32 to haxe.Int32 {
	public extern inline function toInt(): Int
		return this;

	@:op(-A) function unaryMinus(): IntLikeConstant {
		return -this;
	}

	@:op(A + B) static function add(
		a: IntLikeConstant,
		b: IntLikeConstant
	): IntLikeConstant;

	@:op(A - B) static function subtract(
		a: IntLikeConstant,
		b: IntLikeConstant
	): IntLikeConstant;

	@:op(A * B) static function multiply(
		a: IntLikeConstant,
		b: IntLikeConstant
	): IntLikeConstant;

	@:op(A / B) static function divide(
		a: IntLikeConstant,
		b: IntLikeConstant
	): IntLikeConstant;

	/**
		Converts `this` to `ConstantOperand`.
	**/
	public extern inline function toOperand(): ConstantOperand
		return Int(this);
}
