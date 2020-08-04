package firedancer.script.expression.subtypes;

import firedancer.assembly.Opcode;
import firedancer.assembly.Opcode.*;
import firedancer.assembly.AssemblyStatement;
import firedancer.assembly.AssemblyCode;

/**
	Abstract over `VecRuntimeExpressionEnum` that can be implicitly cast from vector objects.
**/
@:notNull @:forward
abstract VecRuntimeExpression(
	VecRuntimeExpressionEnum
) from VecRuntimeExpressionEnum to VecRuntimeExpressionEnum {
	@:op(A / B) public function divide(divisor: FloatExpression): VecRuntimeExpression {
		final expression: VecRuntimeExpressionEnum = switch this {
			case Cartesian(x, y):
				Cartesian(x / divisor, y / divisor);
			case Polar(length, angle):
				Polar(length / divisor, angle);
			default:
				BinaryOperatorWithFloat(VecExpressionEnum.Runtime(this), divisor);
		}
		return expression;
	}

	/**
		Creates an `AssemblyCode` that loads `this` evaluated value to the volatile vector.
	**/
	public function loadToVolatileVector(): AssemblyCode {
		return switch this {
			case Cartesian(x, y):
				[
					x.loadToVolatileFloat(),
					[new AssemblyStatement(general(SaveFloatV), [])],
					y.loadToVolatileFloat(),
					[new AssemblyStatement(general(CastCartesianVV), [])]
				].flatten();
			case Polar(length, angle):
				[
					length.loadToVolatileFloat(),
					[new AssemblyStatement(general(SaveFloatV), [])],
					angle.loadToVolatileFloat(),
					[new AssemblyStatement(general(CastPolarVV), [])]
				].flatten();
			case Variable(loadV):
				new AssemblyStatement(loadV, []);
			case UnaryOperator(type, operand):
				switch operand.toEnum() {
					case Constant(vec):
						switch type.constantOperator {
							case Immediate(func):
								new AssemblyStatement(general(LoadFloatCV), [func(vec)]);
							case Instruction(opcodeCV):
								new AssemblyStatement(opcodeCV, [vec]);
						}
					case Runtime(expression):
						final code = expression.loadToVolatileVector();
						code.push(new AssemblyStatement(type.operateVV, []));
						code;
				};
			case BinaryOperator(_, _):
				throw "Not yet implemented.";
			case BinaryOperatorWithFloat(_, _):
				throw "Not yet implemented.";
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
