package firedancer.script.expression;

import firedancer.assembly.Opcode;
import firedancer.assembly.AssemblyStatement;
import firedancer.assembly.AssemblyCode;

/**
	Expression representing any float value.
**/
@:using(firedancer.script.expression.FloatExpression.FloatExpressionExtension)
enum FloatExpression {
	Constant(value: Float);
	Runtime(expression: FloatRuntimeExpression);
}

@:using(firedancer.script.expression.FloatExpression.FloatRuntimeExpressionExtension)
enum FloatRuntimeExpression {
	/**
		@param loadV `Opcode` for loading the value to the current volatile float.
	**/
	Variable(loadV: Opcode);
}

class FloatExpressionExtension {
	/**
		Creates an `AssemblyCode` that assigns `this` value to the current volatile float.
	**/
	public static function loadToVolatileFloat(_this: FloatExpression): AssemblyCode {
		return switch _this {
			case Constant(value):
				new AssemblyStatement(LoadFloatCV, [Float(value)]);
			case Runtime(expression):
				expression.loadToVolatileFloat();
		}
	}

	/**
		Creates an `AssemblyCode` that runs either `constantOpcode` or `volatileOpcode`
		receiving `this` value as argument.
	**/
	public static function use(
		_this: FloatExpression,
		constantOpcode: Opcode,
		volatileOpcode: Opcode
	): AssemblyCode {
		return switch _this {
			case Constant(value):
				new AssemblyStatement(constantOpcode, [Float(value)]);
			case Runtime(expression):
				final code = expression.loadToVolatileFloat();
				code.push(new AssemblyStatement(volatileOpcode, []));
				code;
		}
	}
}

class FloatRuntimeExpressionExtension {
	/**
		Creates an `AssemblyCode` that assigns `this` value to the current volatile float.
	**/
	public static function loadToVolatileFloat(_this: FloatRuntimeExpression): AssemblyCode {
		return switch _this {
			case Variable(loadV): new AssemblyStatement(loadV, []);
		}
	}
}
