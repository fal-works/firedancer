package firedancer.script.expression.subtypes;

import firedancer.types.Azimuth;
import firedancer.types.AzimuthDisplacement;

/**
	Constant expression of any float-like type.
**/
enum FloatLikeConstantEnum {
	Float(value: Float);
	Azimuth(value: Azimuth);
	AzimuthDisplacement(value: AzimuthDisplacement);
}
