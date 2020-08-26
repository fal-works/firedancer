package firedancer.script.expression.subtypes;

import reckoner.Geometry.DEGREES_TO_RADIANS;
import firedancer.vm.Geometry;
import firedancer.types.Angle;

/**
	The underlying type of `FloatLikeConstant`.
**/
@:structInit
class FloatLikeConstantData {
	public static function fromFloat(value: Float): FloatLikeConstantData
		return { value: value, factor: 1.0 };

	public static function fromAngle(value: Angle): FloatLikeConstantData
		return { value: value.toDegrees(), factor: DEGREES_TO_RADIANS };

	/**
		The non-scaled value.
	**/
	public final value: Float;

	/**
		The scale factor for multiplying `this` (e.g. the degrees-to-radians factor).
	**/
	public final factor: Float;

	/**
		@return The non-scaled value of `this`.
	**/
	public inline function raw(): Float
		return this.value;

	public function unaryMinus(): FloatLikeConstantData {
		return { value: -value, factor: factor };
	}

	public function sin(): FloatLikeConstantData {
		return { value: Geometry.sin(value * factor), factor: 1.0 };
	}

	public function cos(): FloatLikeConstantData {
		return { value: Geometry.cos(value * factor), factor: 1.0 };
	}

	public function add(other: FloatLikeConstantData): FloatLikeConstantData {
		if (this.factor != other.factor)
			throw "Cannot add constants with different factors.";

		return { value: this.value + other.value, factor: this.factor };
	}

	public function subtract(other: FloatLikeConstantData): FloatLikeConstantData {
		if (this.factor != other.factor)
			throw "Cannot subtract constant from another with different factor.";

		return { value: this.value - other.value, factor: this.factor };
	}

	public function multiply(other: FloatLikeConstantData): FloatLikeConstantData {
		if (this.factor != 1.0 && other.factor != 1.0)
			throw "Cannot multiply scaled constant by another scaled one.";

		return { value: this.value * other.value, factor: this.factor };
	}

	public function divide(other: FloatLikeConstantData): FloatLikeConstantData {
		if (other.factor != 1.0)
			throw "Cannot divide constant by another scaled one.";

		return { value: this.value / other.value, factor: this.factor };
	}

	public function modulo(other: FloatLikeConstantData): FloatLikeConstantData {
		if (other.factor != 1.0)
			throw "Cannot perform modulo operation with a scaled divisor.";

		return { value: this.value % other.value, factor: this.factor };
	}

	/**
		Converts `this` to `Float` for writing into `AssemblyCode`.
	**/
	public function toImmediateValue(): Float
		return factor * value;

	public function toString(): String
		return '{v:$value,f:$factor}';
}
