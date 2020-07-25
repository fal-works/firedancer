package firedancer.script.expression;

import firedancer.types.Azimuth;
import firedancer.assembly.Opcode;
import firedancer.assembly.AssemblyStatement;
import firedancer.assembly.AssemblyCode;

/**
	Expression representing any 2D vector.
**/
@:using(firedancer.script.expression.VecExpression.VecExpressionExtension)
enum VecExpression {
	CartesianConstant(x: Float, y: Float);
	CartesianExpression(x: FloatArgument, y: FloatArgument);
	PolarConstant(length: Float, angle: Azimuth);
	PolarExpression(length: FloatArgument, angle: AzimuthExpression);
}

class VecExpressionExtension {
	/**
		Creates an `AssemblyCode` that runs either `constantOpcode` or `volatileOpcode`
		receiving `this` value as argument.
	**/
	public static function use(
		_this: VecExpression,
		constantOpcode: Opcode,
		volatileOpcode: Opcode
	): AssemblyCode {
		return switch _this {
			case CartesianConstant(x, y):
				new AssemblyStatement(constantOpcode, [Vec(x, y)]);
			case PolarConstant(length, angle):
				new AssemblyStatement(constantOpcode, [Vec(length * angle.cos(), length * angle.sin())]);
			case CartesianExpression(x, y):
				[
					x.loadToVolatile(),
					y.loadToVolatile(),
					[new AssemblyStatement(volatileOpcode, [])]
				].flatten();
			case PolarExpression(length, angle):
				// TODO: add opcode `PolarToCartesian` or something
				throw "Not yet implemented.";
		}
	}
}
