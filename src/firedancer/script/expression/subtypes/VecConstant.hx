package firedancer.script.expression.subtypes;

import reckoner.Geometry;
import reckoner.TmpVec2D;
import firedancer.types.Azimuth;
import firedancer.assembly.ConstantOperand;
import firedancer.assembly.Opcode;
import firedancer.assembly.AssemblyStatement;
import firedancer.assembly.AssemblyCode;

/**
	Abstract over `VecConstantEnum` with some casting methods and operator overloads.
**/
@:notNull
abstract VecConstant(VecConstantEnum) from VecConstantEnum to VecConstantEnum {
	/**
		Converts a cartesian 2D vector to `VecConstant`.
	**/
	@:from public static function fromCartesian(
		args: { x: Float, y: Float }
	): VecConstant {
		return VecConstantEnum.Cartesian(
			constantFloat(args.x),
			constantFloat(args.y)
		);
	}

	/**
		Converts a polar 2D vector to `VecConstant`.
	**/
	@:from public static function fromPolar(
		args: { length: Float, angle: Azimuth }
	): VecConstant {
		return VecConstantEnum.Polar(
			constantFloat(args.length),
			constantAngle(args.angle.toAngle())
		);
	}

	/**
		Converts `this` to a 2D vector `ConstantOperand`.

		If the input was a polar vector, the result is converted to cartesian.
	**/
	@:to public function toOperand(): ConstantOperand {
		return switch this {
			case Cartesian(x, y):
				Vec(x.toFloat(), y.toFloat());
			case Polar(length, angle):
				final vec = angle.toAzimuth().toVec2D(length.toFloat());
				Vec(vec.x, vec.y);
		}
	}

	@:op(-A) function unaryMinus(): VecConstant {
		return switch this {
			case Cartesian(x, y):
				VecConstantEnum.Cartesian(-x, -y);
			case Polar(length, angle):
				VecConstantEnum.Polar(-length, angle);
		}
	}

	@:op(A + B) static function add(a: VecConstant, b: VecConstant): VecConstant {
		final aVec = a.getComponents();
		final bVec = b.getComponents();

		final result: VecConstantEnum = Cartesian(
			aVec.x + bVec.x,
			aVec.y + bVec.y
		);

		return result;
	}

	@:op(A - B) static function subtract(a: VecConstant, b: VecConstant): VecConstant {
		final aVec = a.getComponents();
		final bVec = b.getComponents();

		final result: VecConstantEnum = Cartesian(
			aVec.x - bVec.x,
			aVec.y - bVec.y
		);

		return result;
	}

	@:op(A * B) @:commutative
	public static function multiply(
		vec: VecConstant,
		factor: FloatLikeConstant
	): VecConstant {
		final expression: VecConstantEnum = switch vec.toEnum() {
			case Cartesian(x, y): Cartesian(x * factor, y * factor);
			case Polar(length, angle): Polar(length * factor, angle);
		}
		return expression;
	}

	@:op(A / B) public function divide(divisor: FloatLikeConstant): VecConstant {
		final expression: VecConstantEnum = switch this {
			case Cartesian(x, y): Cartesian(x / divisor, y / divisor);
			case Polar(length, angle): Polar(length / divisor, angle);
		}
		return expression;
	}

	/**
		Creates an `AssemblyCode` that runs a given `Opcode` receiving `this` value as argument.
		@param processConstantVector Any `Opcode` that uses a constant vector.
	**/
	public function use(processConstantVector: Opcode): AssemblyCode {
		return new AssemblyStatement(processConstantVector, [toOperand()]);
	}

	function getComponents(): { x: FloatLikeConstant, y: FloatLikeConstant } {
		return switch this {
			case Cartesian(x, y): { x: x, y: y };
			case Polar(length, angle):
				final vec = angle.toAzimuth().toVec2D(length.toFloat());
				{ x: FloatLikeConstant.fromFloat(vec.x), y: FloatLikeConstant.fromFloat(vec.y) };
		}
	}

	public extern inline function toEnum(): VecConstantEnum
		return this;
}
