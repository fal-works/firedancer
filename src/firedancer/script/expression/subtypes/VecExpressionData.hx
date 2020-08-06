package firedancer.script.expression.subtypes;

import sneaker.exception.NotOverriddenException;
import firedancer.types.Azimuth;
import firedancer.assembly.AssemblyStatement;
import firedancer.assembly.AssemblyCode;
import firedancer.assembly.ConstantOperand;
import firedancer.assembly.Opcode;
import firedancer.assembly.Opcode.*;

/**
	Underlying type of `VecExpression`.
**/
class VecExpressionData {
	public function tryGetConstantOperand(): Maybe<ConstantOperand>
		throw new NotOverriddenException();

	public function divideByFloat(divisor: Float): VecExpressionData
		throw new NotOverriddenException();

	public function loadToVolatileVector(): AssemblyCode
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
			new AssemblyStatement(processConstantVector, [const.unwrap()]);
		} else {
			final code = loadToVolatileVector();
			code.push(new AssemblyStatement(processVolatileVector, []));
			code;
		}
	}
}

@:structInit
class CartesianVecExpressionData extends VecExpressionData implements ripper.Data {
	public final x: FloatExpression;
	public final y: FloatExpression;

	override public function tryGetConstantOperand(): Maybe<ConstantOperand> {
		return switch x.toEnum() {
			case Constant(valX):
				switch y.toEnum() {
					case Constant(valY):
						return Maybe.from(Vec(
							valX.toOperandValue(FloatExpression.constantFactor),
							valY.toOperandValue(FloatExpression.constantFactor)
						));
					default: Maybe.none();
				}
			default: Maybe.none();
		}
	}

	override public function divideByFloat(divisor: Float): CartesianVecExpressionData
		return { x: x / divisor, y: y / divisor };

	override public function loadToVolatileVector(): AssemblyCode {
		final code = [
			x.loadToVolatileFloat(),
			[new AssemblyStatement(calc(SaveFloatV), [])],
			y.loadToVolatileFloat(),
			[new AssemblyStatement(calc(CastCartesianVV), [])]
		].flatten();
		return code;
	}
}

@:structInit
class PolarVecExpressionData extends VecExpressionData implements ripper.Data {
	public final length: FloatExpression;
	public final angle: AngleExpression;

	override public function tryGetConstantOperand(): Maybe<ConstantOperand> {
		return switch length.toEnum() {
			case Constant(valLen):
				switch angle.toEnum() {
					case Constant(valAng):
						final vec = Azimuth.fromDegrees(valAng).toVec2D(valLen);
						return Maybe.from(Vec(vec.x, vec.y));
					default:
						Maybe.none();
				}
			default:
				Maybe.none();
		}
	}

	override public function divideByFloat(divisor: Float): PolarVecExpressionData
		return { length: length / divisor, angle: angle };

	override public function loadToVolatileVector(): AssemblyCode {
		return [
			length.loadToVolatileFloat(),
			[new AssemblyStatement(calc(SaveFloatV), [])],
			angle.loadToVolatileFloat(),
			[new AssemblyStatement(calc(CastPolarVV), [])]
		].flatten();
	}
}
