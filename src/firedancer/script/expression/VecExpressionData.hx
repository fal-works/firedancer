package firedancer.script.expression;

import sneaker.exception.NotOverriddenException;
import firedancer.types.Azimuth;
import firedancer.assembly.AssemblyStatement.create as statement;
import firedancer.assembly.AssemblyCode;
import firedancer.assembly.ConstantOperand;
import firedancer.assembly.Opcode;
import firedancer.assembly.Opcode.*;

/**
	Underlying type of `VecExpression`.
**/
class VecExpressionData implements ExpressionData {
	final divisor: Maybe<FloatExpression> = Maybe.none();

	public function new(?divisor: FloatExpression) {
		this.divisor = Maybe.from(divisor);
	}

	public function tryGetConstantOperandValue(): Maybe<{x: Float, y: Float }>
		throw new NotOverriddenException();

	public function tryGetConstantOperand(): Maybe<ConstantOperand> {
		final value = tryGetConstantOperandValue();
		return if (value.isSome()) {
			final val = value.unwrap();
			Maybe.from(Vec(val.x, val.y));
		} else Maybe.none();
	}

	public function divide(divisor: FloatExpression): VecExpressionData
		throw new NotOverriddenException();

	public function divideByFloat(divisor: Float): VecExpressionData
		throw new NotOverriddenException();

	public function loadToVolatile(): AssemblyCode
		throw new NotOverriddenException();

	/**
		Creates an `AssemblyCode` that runs either `processConstantVector` or `processVolatileVector`
		receiving `this` value as argument.
		@param processConstantVector Any `Opcode` that uses a constant vector.
		@param processVolatileVector Any `Opcode` that uses the volatile vector.
	**/
	public function use(
		processConstantVector: Opcode,
		processVolatileVector: Opcode
	): AssemblyCode {
		final const = tryGetConstantOperand();
		return if (const.isSome()) {
			statement(processConstantVector, [const.unwrap()]);
		} else {
			final code = loadToVolatile();
			code.push(statement(processVolatileVector));
			code;
		}
	}
}

@:structInit
class CartesianVecExpressionData extends VecExpressionData {
	public final x: FloatExpression;
	public final y: FloatExpression;

	public function new(
		x: FloatExpression,
		y: FloatExpression,
		?divisor: FloatExpression
	) {
		super(divisor);
		this.x = x;
		this.y = y;
	}

	override public function tryGetConstantOperandValue(): Maybe<{x: Float, y: Float }> {
		final xConstant = x.tryGetConstantOperandValue();
		if (xConstant.isNone()) return Maybe.none();

		final yConstant = y.tryGetConstantOperandValue();
		if (yConstant.isNone()) return Maybe.none();

		final xVal = xConstant.unwrap();
		final yVal = yConstant.unwrap();

		if (divisor.isNone())
			return Maybe.from({ x: xVal, y: yVal });
		else {
			final divisorValue = divisor.unwrap().tryGetConstantOperandValue();
			if (divisorValue.isNone()) return Maybe.none();
			final divVal = divisorValue.unwrap();
			return Maybe.from({ x: xVal / divVal, y: yVal / divVal });
		}
	}

	override public function divide(divisor: FloatExpression): CartesianVecExpressionData {
		if (this.divisor.isSome()) divisor = this.divisor.unwrap() * divisor;
		return new CartesianVecExpressionData(x, y, divisor);
	}

	override public function divideByFloat(divisor: Float): CartesianVecExpressionData
		return divide(divisor);

	override public function loadToVolatile(): AssemblyCode {
		final x = this.x;
		final y = this.y;
		final divisor = this.divisor;

		final xConstant = x.tryGetConstantOperandValue();
		final yConstant = y.tryGetConstantOperandValue();

		if (xConstant.isSome() && yConstant.isSome()) {
			final xVal = xConstant.unwrap();
			final yVal = yConstant.unwrap();

			if (divisor.isNone()) {
				// cVec
				return statement(calc(LoadVecCV), [Vec(xVal, yVal)]);
			} else {
				final divisorConstant = divisor.unwrap().tryGetConstantOperandValue();

				if (divisorConstant.isSome()) {
					// cVec / cDiv
					final divVal = divisorConstant.unwrap();
					return statement(
						calc(LoadVecCV),
						[Vec(xVal / divVal, yVal / divVal)]
					);
				} else {
					// cVec / rDiv
					return [
						[statement(calc(LoadVecCV), [Vec(xVal, yVal)])],
						divisor.unwrap().loadToVolatile(),
						[statement(calc(DivFloatVVV))]
					].flatten();
				}
			}
		}

		final loadVecWithoutDivisor = [
			x.loadToVolatile(),
			[statement(calc(SaveFloatV))],
			y.loadToVolatile(),
			[statement(calc(CastCartesianVV))]
		].flatten();

		if (divisor.isNone()) {
			// rVec
			return loadVecWithoutDivisor;
		} else {
			final divisorConstant = divisor.unwrap().tryGetConstantOperandValue();

			if (divisorConstant.isSome()) {
				// rVec / cDiv
				final divVal = divisorConstant.unwrap();
				final multiplier = 1.0 / divVal;
				return [
					loadVecWithoutDivisor,
					[statement(calc(MultVecVCV), [Float(multiplier)])]
				].flatten();
			} else {
				// rVec / rDiv
				return [
					loadVecWithoutDivisor,
					divisor.unwrap().loadToVolatile(),
					[statement(calc(DivVecVVV))]
				].flatten();
			}
		}
	}
}

@:structInit
class PolarVecExpressionData extends VecExpressionData {
	public final length: FloatExpression;
	public final angle: AngleExpression;

	public function new(
		length: FloatExpression,
		angle: AngleExpression,
		?divisor: FloatExpression
	) {
		super(divisor);
		this.length = length;
		this.angle = angle;
	}

	override public function tryGetConstantOperandValue(): Maybe<{x: Float, y: Float }> {
		final lengthConstant = length.tryGetConstantOperandValue();
		if (lengthConstant.isNone()) return Maybe.none();

		final angleConstant = angle.tryGetConstantOperandValue();
		if (angleConstant.isNone()) return Maybe.none();

		final lenVal = lengthConstant.unwrap();
		final angVal = angleConstant.unwrap();
		final vec = Azimuth.fromRadians(angVal).toVec2D(lenVal);

		if (divisor.isNone()) {
			return Maybe.from({ x: vec.x, y: vec.y });
		} else {
			final divisorValue = divisor.unwrap().tryGetConstantOperandValue();
			if (divisorValue.isNone()) return Maybe.none();
			final divVal = divisorValue.unwrap();
			return Maybe.from({ x: vec.x / divVal, y: vec.y / divVal });
		}
	}

	override public function divide(divisor: FloatExpression): PolarVecExpressionData {
		if (this.divisor.isSome()) divisor = this.divisor.unwrap() * divisor;
		return new PolarVecExpressionData(length, angle, divisor);
	}

	override public function divideByFloat(divisor: Float): PolarVecExpressionData
		return divide(divisor);

	override public function loadToVolatile(): AssemblyCode {
		var length = this.length;
		final angle = this.angle;

		final lengthConstant = length.tryGetConstantOperandValue();
		final angleConstant = angle.tryGetConstantOperandValue();

		if (lengthConstant.isSome() && angleConstant.isSome()) {
			final lenVal = lengthConstant.unwrap();
			final angVal = angleConstant.unwrap();
			final vec = Azimuth.fromRadians(angVal).toVec2D(lenVal);

			if (divisor.isNone()) {
				// cVec
				return statement(calc(LoadVecCV), [Vec(vec.x, vec.y)]);
			} else {
				final divisorConstant = divisor.unwrap().tryGetConstantOperandValue();

				if (divisorConstant.isSome()) {
					// cVec / cDiv
					final divVal = divisorConstant.unwrap();
					return statement(
						calc(LoadVecCV),
						[Vec(vec.x / divVal, vec.y / divVal)]
					);
				} else {
					// cVec / rDiv
					return [
						[statement(calc(LoadVecCV), [Vec(vec.x, vec.y)])],
						divisor.unwrap().loadToVolatile(),
						[statement(calc(DivFloatVVV))]
					].flatten();
				}
			}
		}

		final loadVecWithoutDivisor = [
			length.loadToVolatile(),
			[statement(calc(SaveFloatV))],
			angle.loadToVolatile(),
			[statement(calc(CastPolarVV))]
		].flatten();

		if (divisor.isNone()) {
			// rVec
			return loadVecWithoutDivisor;
		} else {
			final divisorConstant = divisor.unwrap().tryGetConstantOperandValue();

			if (divisorConstant.isSome()) {
				// rVec / cDiv
				final divVal = divisorConstant.unwrap();
				final multiplier = 1.0 / divVal;
				return [
					loadVecWithoutDivisor,
					[statement(calc(MultVecVCV), [Float(multiplier)])]
				].flatten();
			} else {
				// rVec / rDiv
				return [
					loadVecWithoutDivisor,
					divisor.unwrap().loadToVolatile(),
					[statement(calc(DivVecVVV))]
				].flatten();
			}
		}
	}
}
