package firedancer.script.expression.subtypes;

import firedancer.assembly.Opcode;
import firedancer.assembly.AssemblyStatement;
import firedancer.assembly.AssemblyCode;

/**
	Abstract over `VecRuntimeExpressionEnum` that can be implicitly cast from vector objects.
**/
@:notNull @:forward
abstract VecRuntimeExpression(VecRuntimeExpressionEnum) from VecRuntimeExpressionEnum to VecRuntimeExpressionEnum {
	@:op(A / B) public function divide(divisor: Float): VecRuntimeExpression {
		final expression: VecRuntimeExpressionEnum = switch this {
			case Cartesian(x, y):
				Cartesian(x / divisor, y / divisor);
			case Polar(length, angle):
				Polar(length / divisor, angle);
			case Variable(loadVolatileOpcode):
				throw "Not yet implemented.";
		}
		return expression;
	}

	@:op(A / B) extern inline function divideInt(divisor: Int): VecRuntimeExpression
		return divide(divisor);

	/**
		Creates an `AssemblyCode` that loads `this` evaluated value to the volatile vector.
	**/
	public function loadToVolatileVector(): AssemblyCode {
		return switch this {
			case Cartesian(x, y):
				[
					x.loadToVolatileFloat(),
					[new AssemblyStatement(SaveFloatV, [])],
					y.loadToVolatileFloat(),
					[new AssemblyStatement(CastCartesianVV, [])]
				].flatten();
			case Polar(length, angle):
				[
					length.loadToVolatileFloat(),
					[new AssemblyStatement(SaveFloatV, [])],
					angle.loadToVolatileFloat(),
					[new AssemblyStatement(CastPolarVV, [])]
				].flatten();
			case Variable(loadV):
				new AssemblyStatement(loadV, []);
		}
	}

	/**
		Creates an `AssemblyCode` that runs a given `Opcode` receiving `this` value as argument.
		@param processVolatileVector Any `Opcode` that uses the volatile vector.
	**/
	public function use(processVolatileVector: Opcode): AssemblyCode {
		final code = loadToVolatileVector();
		code.push(new AssemblyStatement(processVolatileVector, []));
		return code;
	}

	public extern inline function toEnum(): VecRuntimeExpressionEnum
		return this;
}
