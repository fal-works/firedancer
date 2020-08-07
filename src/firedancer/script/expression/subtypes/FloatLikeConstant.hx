package firedancer.script.expression.subtypes;

import firedancer.types.Angle;

/**
	Value that represents a float-like constant.
**/
@:notNull @:forward
abstract FloatLikeConstant(FloatLikeConstantData) from FloatLikeConstantData to FloatLikeConstantData {
	/**
		Casts `Float` to `FloatLikeConstant`.
	**/
	@:from static extern inline function fromFloat(value: Float): FloatLikeConstant
		return FloatLikeConstantData.fromFloat(value);

	/**
		Casts `Angle` to `FloatLikeConstant`.
	**/
	@:from static extern inline function fromAngle(value: Angle): FloatLikeConstant
		return FloatLikeConstantData.fromAngle(value);

	@:op(-A) inline function unaryMinus(): FloatLikeConstant
		return this.unaryMinus();

	@:op(A + B) static function add(
		a: FloatLikeConstant,
		b: FloatLikeConstant
	): FloatLikeConstant {
		return a.add(b);
	}

	@:op(A - B) static function subtract(
		a: FloatLikeConstant,
		b: FloatLikeConstant
	): FloatLikeConstant {
		return a.subtract(b);
	}

	@:op(A * B) static function multiply(
		a: FloatLikeConstant,
		b: FloatLikeConstant
	): FloatLikeConstant {
		return a.multiply(b);
	}

	@:op(A / B) static function divide(
		a: FloatLikeConstant,
		b: FloatLikeConstant
	): FloatLikeConstant {
		return a.divide(b);
	}

	@:op(A % B) static function modulo(
		a: FloatLikeConstant,
		b: FloatLikeConstant
	): FloatLikeConstant {
		return a.modulo(b);
	}
}
