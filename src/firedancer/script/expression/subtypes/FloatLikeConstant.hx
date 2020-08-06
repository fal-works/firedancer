package firedancer.script.expression.subtypes;

import firedancer.assembly.ConstantOperand;
import firedancer.types.Angle;

/**
	Value that represents a float-like constant.
**/
@:notNull
abstract FloatLikeConstant(Float) from Float to Float {
	/**
		Casts `Angle` to `FloatLikeConstant`.
	**/
	@:from static extern inline function fromAngle(value: Angle): FloatLikeConstant
		return value.toDegrees();

	@:op(-A) function unaryMinus(): FloatLikeConstant {
		return -this;
	}

	@:op(A + B) static function add(
		a: FloatLikeConstant,
		b: FloatLikeConstant
	): FloatLikeConstant;

	@:op(A - B) static function subtract(
		a: FloatLikeConstant,
		b: FloatLikeConstant
	): FloatLikeConstant;

	@:op(A * B) static function multiply(
		a: FloatLikeConstant,
		b: FloatLikeConstant
	): FloatLikeConstant;

	@:op(A / B) static function divide(
		a: FloatLikeConstant,
		b: FloatLikeConstant
	): FloatLikeConstant;

	/**
		Converts `this` to `Float` for writing into `AssemblyCode`.
		@param factor The scale factor for multiplying `this` (e.g. the degrees-to-radians factor).
	**/
	public extern inline function toOperandValue(factor: Float): Float
		return factor * this;

	/**
		Converts `this` to `ConstantOperand`.
		@param factor The scale factor for multiplying `this` (e.g. the degrees-to-radians factor).
	**/
	public extern inline function toOperand(factor: Float): ConstantOperand
		return Float(toOperandValue(factor));
}
