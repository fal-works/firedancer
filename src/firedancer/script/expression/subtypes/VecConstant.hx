package firedancer.script.expression.subtypes;

import firedancer.types.Azimuth;
import firedancer.assembly.ConstantOperand;
import firedancer.assembly.Opcode;
import firedancer.assembly.AssemblyStatement;
import firedancer.assembly.AssemblyCode;

/**
	Abstract over `VecConstantEnum` that can be implicitly cast from vector objects.
**/
@:notNull @:forward
abstract VecConstant(VecConstantEnum) from VecConstantEnum to VecConstantEnum {
	@:from public static function fromCartesian(
		args: { x: Float, y: Float }
	): VecConstant
		return VecConstantEnum.Cartesian(FloatLikeConstantEnum.Float(args.x), FloatLikeConstantEnum.Float(args.y));

	@:from public static function fromPolar(
		args: { length: Float, angle: Azimuth }
	): VecConstant {
		return VecConstantEnum.Polar(
			FloatLikeConstantEnum.Float(args.length),
			FloatLikeConstantEnum.Azimuth(args.angle)
		);
	}

	@:to public function toOperand(): ConstantOperand {
		return switch this {
			case Cartesian(x, y):
				Vec(x, y);
			case Polar(length, angle):
				final x: Float = length.toFloat() * angle.toAzimuth().cos();
				final y: Float = length.toFloat() * angle.toAzimuth().sin();
				Vec(x, y);
		}
	}

	@:op(A / B) public function divide(divisor: Float): VecConstant {
		final expression: VecConstantEnum = switch this {
			case Cartesian(x, y): Cartesian(x / divisor, y / divisor);
			case Polar(length, angle): Polar(length / divisor, angle);
		}
		return expression;
	}

	@:op(A / B) extern inline function divideInt(divisor: Int): VecConstant
		return divide(divisor);

	/**
		Creates an `AssemblyCode` that runs a given `Opcode` receiving `this` value as argument.
		@param processConstantVector Any `Opcode` that uses a constant vector.
	**/
	public function use(processConstantVector: Opcode): AssemblyCode {
		return new AssemblyStatement(processConstantVector, [toOperand()]);
	}

	public extern inline function toEnum(): VecConstantEnum
		return this;
}
