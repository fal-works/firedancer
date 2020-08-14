package firedancer.script.expression.subtypes;

import firedancer.assembly.Immediate;

/**
	Value that represents an int-like constant.
**/
@:notNull
abstract IntLikeConstant(haxe.Int32) from Int from haxe.Int32{
	public inline function raw(): haxe.Int32
		return this;

	@:op(-A) function unaryMinus(): IntLikeConstant;

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
		Converts `this` to `Int` for writing into `AssemblyCode`.
	**/
	public extern inline function toImmediateValue(): Int
		return this;

	/**
		Converts `this` to `Immediate`.
	**/
	public extern inline function toImmediate(): Immediate
		return Int(this);
}
