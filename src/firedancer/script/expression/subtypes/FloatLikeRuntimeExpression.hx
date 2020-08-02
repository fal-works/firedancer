package firedancer.script.expression.subtypes;

import firedancer.assembly.AssemblyCode;
import firedancer.assembly.AssemblyStatement;

/**
	Abstract over `FloatLikeRuntimeExpressionEnum`.
**/
@:notNull @:forward
abstract FloatLikeRuntimeExpression(
	FloatLikeRuntimeExpressionEnum
) from FloatLikeRuntimeExpressionEnum to FloatLikeRuntimeExpressionEnum {
	/**
		Creates an `AssemblyCode` that assigns `this` value to the current volatile float.
	**/
	public function loadToVolatileFloat(): AssemblyCode {
		return switch this {
			case Variable(loadV):
				new AssemblyStatement(loadV, []);
			case UnaryOperator(type, operand):
				switch operand {
					case Constant(value):
						new AssemblyStatement(type.operateFloatCV, [value]);
					case Runtime(expression):
						final code = expression.loadToVolatileFloat();
						code.push(new AssemblyStatement(type.operateFloatVV, []));
						code;
				};
		}
	}

	public extern inline function toEnum(): FloatLikeRuntimeExpression
		return this;
}
