package firedancer.script.expression;

import sneaker.exception.NotOverriddenException;
import firedancer.types.Azimuth;
import firedancer.assembly.Instruction.create as instruction;
import firedancer.assembly.AssemblyCode;
import firedancer.assembly.Immediate;
import firedancer.assembly.Opcode;
import firedancer.assembly.operation.GeneralOperation;
import firedancer.assembly.operation.CalcOperation;

/**
	Underlying type of `VecExpression`.
**/
class VecExpressionData implements ExpressionData {
	final divisor: Maybe<FloatExpression> = Maybe.none();

	public function new(?divisor: FloatExpression) {
		this.divisor = Maybe.from(divisor);
	}

	public function tryGetConstant(): Maybe<{x: Float, y: Float }>
		throw new NotOverriddenException();

	public function tryMakeImmediate(): Maybe<Immediate> {
		final constant = tryGetConstant();
		return if (constant.isSome()) {
			final val = constant.unwrap();
			Maybe.from(Vec(val.x, val.y));
		} else Maybe.none();
	}

	public function divide(divisor: FloatExpression): VecExpressionData
		throw new NotOverriddenException();

	public function divideByFloat(divisor: Float): VecExpressionData
		throw new NotOverriddenException();

	public function loadToVolatile(context: CompileContext): AssemblyCode
		throw new NotOverriddenException();

	/**
		Creates an `AssemblyCode` that runs either `processConstantVector` or `processVolatileVector`
		receiving `this` value as argument.
		@param processConstantVector Any `Opcode` that uses a constant vector.
		@param processVolatileVector Any `Opcode` that uses the volatile vector.
	**/
	public function use(
		context: CompileContext,
		processConstantVector: Opcode,
		processVolatileVector: Opcode
	): AssemblyCode {
		final immediate = tryMakeImmediate();
		return if (immediate.isSome()) {
			instruction(processConstantVector, [immediate.unwrap()]);
		} else {
			final code = loadToVolatile(context);
			code.push(instruction(processVolatileVector));
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

	override public function tryGetConstant(): Maybe<{x: Float, y: Float }> {
		final xConstant = x.tryGetConstant();
		if (xConstant.isNone()) return Maybe.none();

		final yConstant = y.tryGetConstant();
		if (yConstant.isNone()) return Maybe.none();

		final xVal = xConstant.unwrap();
		final yVal = yConstant.unwrap();

		if (divisor.isNone())
			return Maybe.from({ x: xVal, y: yVal });
		else {
			final divisorConstant = divisor.unwrap().tryGetConstant();
			if (divisorConstant.isNone()) return Maybe.none();
			final divVal = divisorConstant.unwrap();
			return Maybe.from({ x: xVal / divVal, y: yVal / divVal });
		}
	}

	override public function divide(divisor: FloatExpression): CartesianVecExpressionData {
		if (this.divisor.isSome()) divisor = this.divisor.unwrap() * divisor;
		return new CartesianVecExpressionData(x, y, divisor);
	}

	override public function divideByFloat(divisor: Float): CartesianVecExpressionData
		return divide(divisor);

	override public function loadToVolatile(context: CompileContext): AssemblyCode {
		final x = this.x;
		final y = this.y;
		final divisor = this.divisor;

		final xConstant = x.tryGetConstant();
		final yConstant = y.tryGetConstant();

		if (xConstant.isSome() && yConstant.isSome()) {
			final xVal = xConstant.unwrap();
			final yVal = yConstant.unwrap();

			if (divisor.isNone()) {
				// cVec
				return instruction(LoadVecCV, [Vec(xVal, yVal)]);
			} else {
				final divisorConstant = divisor.unwrap().tryGetConstant();

				if (divisorConstant.isSome()) {
					// cVec / cDiv
					final divVal = divisorConstant.unwrap();
					return instruction(
						LoadVecCV,
						[Vec(xVal / divVal, yVal / divVal)]
					);
				} else {
					// cVec / rDiv
					return [
						[instruction(LoadVecCV, [Vec(xVal, yVal)])],
						divisor.unwrap().loadToVolatile(context),
						[instruction(DivFloatVVV)]
					].flatten();
				}
			}
		}

		final loadVecWithoutDivisor = [
			x.loadToVolatile(context),
			[instruction(SaveFloatV)],
			y.loadToVolatile(context),
			[instruction(CastCartesianVV)]
		].flatten();

		if (divisor.isNone()) {
			// rVec
			return loadVecWithoutDivisor;
		} else {
			final divisorConstant = divisor.unwrap().tryGetConstant();

			if (divisorConstant.isSome()) {
				// rVec / cDiv
				final divVal = divisorConstant.unwrap();
				final multiplier = 1.0 / divVal;
				return [
					loadVecWithoutDivisor,
					[instruction(MultVecVCV, [Float(multiplier)])]
				].flatten();
			} else {
				// rVec / rDiv
				return [
					loadVecWithoutDivisor,
					divisor.unwrap().loadToVolatile(context),
					[instruction(DivVecVVV)]
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

	override public function tryGetConstant(): Maybe<{x: Float, y: Float }> {
		final lengthConstant = length.tryGetConstant();
		if (lengthConstant.isNone()) return Maybe.none();

		final angleConstant = angle.tryGetConstant();
		if (angleConstant.isNone()) return Maybe.none();

		final lenVal = lengthConstant.unwrap();
		final angVal = angleConstant.unwrap();
		final vec = Azimuth.fromRadians(angVal).toVec2D(lenVal);

		if (divisor.isNone()) {
			return Maybe.from({ x: vec.x, y: vec.y });
		} else {
			final divisorValue = divisor.unwrap().tryGetConstant();
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

	override public function loadToVolatile(context: CompileContext): AssemblyCode {
		var length = this.length;
		final angle = this.angle;

		final lengthConstant = length.tryGetConstant();
		final angleConstant = angle.tryGetConstant();

		if (lengthConstant.isSome() && angleConstant.isSome()) {
			final lenVal = lengthConstant.unwrap();
			final angVal = angleConstant.unwrap();
			final vec = Azimuth.fromRadians(angVal).toVec2D(lenVal);

			if (divisor.isNone()) {
				// cVec
				return instruction(LoadVecCV, [Vec(vec.x, vec.y)]);
			} else {
				final divisorConstant = divisor.unwrap().tryGetConstant();

				if (divisorConstant.isSome()) {
					// cVec / cDiv
					final divVal = divisorConstant.unwrap();
					return instruction(
						LoadVecCV,
						[Vec(vec.x / divVal, vec.y / divVal)]
					);
				} else {
					// cVec / rDiv
					return [
						[instruction(LoadVecCV, [Vec(vec.x, vec.y)])],
						divisor.unwrap().loadToVolatile(context),
						[instruction(DivFloatVVV)]
					].flatten();
				}
			}
		}

		final loadVecWithoutDivisor = [
			length.loadToVolatile(context),
			[instruction(SaveFloatV)],
			angle.loadToVolatile(context),
			[instruction(CastPolarVV)]
		].flatten();

		if (divisor.isNone()) {
			// rVec
			return loadVecWithoutDivisor;
		} else {
			final divisorConstant = divisor.unwrap().tryGetConstant();

			if (divisorConstant.isSome()) {
				// rVec / cDiv
				final divVal = divisorConstant.unwrap();
				final multiplier = 1.0 / divVal;
				return [
					loadVecWithoutDivisor,
					[instruction(MultVecVCV, [Float(multiplier)])]
				].flatten();
			} else {
				// rVec / rDiv
				return [
					loadVecWithoutDivisor,
					divisor.unwrap().loadToVolatile(context),
					[instruction(DivVecVVV)]
				].flatten();
			}
		}
	}
}
