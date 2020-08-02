package firedancer.script.expression.subtypes;

import firedancer.types.Angle;

/**
	Constant expression of any float-like type.
**/
enum FloatLikeConstantEnum {
	Float(value: Float);
	Angle(value: Angle);
}
