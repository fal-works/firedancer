package firedancer.script.expression;

import firedancer.types.Azimuth;
import firedancer.script.expression.VecExpressionData;

/**
	Expression representing any 2D vector.
**/
@:notNull @:forward @:transitive
abstract VecExpression(VecExpressionData) from VecExpressionData to VecExpressionData {
	@:from static function fromCartesianConstants(
		args: { x: Float, y: Float }
	): VecExpression {
		final data: VecExpressionData = new CartesianVecExpressionData(
			args.x,
			args.y
		);
		return data;
	}

	@:from static function fromCartesianExpressions(
		args: { x: FloatExpression, y: FloatExpression }
	): VecExpression {
		final data: VecExpressionData = new CartesianVecExpressionData(
			args.x,
			args.y
		);
		return data;
	}

	@:from static function fromPolarConstants(
		args: { length: Float, angle: Azimuth }
	): VecExpression {
		final data: VecExpressionData = new PolarVecExpressionData(
			args.length,
			args.angle.toAngle()
		);
		return data;
	}

	@:from static function fromPolarExpressionss(
		args: { length: FloatExpression, angle: AngleExpression }
	): VecExpression {
		final data: VecExpressionData = new PolarVecExpressionData(
			args.length,
			args.angle
		);
		return data;
	}

	@:to public function toString(): String
		return this.toString();

	@:op(A / B) extern inline function divide(divisor: FloatExpression): VecExpression
		return this.divide(divisor);

	@:op(A / B) extern inline function divideByFloat(divisor: Float): VecExpression
		return this.divideByFloat(divisor);

	@:op(A / B) extern inline function dividebyInt(divisor: Int): VecExpression
		return divideByFloat(divisor);
}
