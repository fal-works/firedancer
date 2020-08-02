package firedancer.script.expression.subtypes;

enum VecConstantEnum {
	Cartesian(x: FloatLikeConstant, y: FloatLikeConstant);
	Polar(length: FloatLikeConstant, angle: FloatLikeConstant);
}
