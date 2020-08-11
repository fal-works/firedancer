package firedancer.script.expression;

import firedancer.script.expression.AngleExpression;
import firedancer.assembly.Opcode.calc;

abstract LocalVariableExpression(String) {
	@:from public static function fromName(name: String): LocalVariableExpression {
		return new LocalVariableExpression(name);
	}

	@:to public function toIntExpr(): IntExpression {
		return IntExpression.fromEnum(IntLikeExpressionEnum.Runtime(Custom(context -> {
			final variable = context.localVariables.get(this);
			final code = variable.loadToVolatile();
			switch variable.type {
				case Int:
				case Float: throw "Cannot cast float to int.";
				case Vec: throw "Cannot cast vector to int.";
			}
			code;
		})));
	}

	@:to public function toFloatExpr(): FloatExpression {
		return FloatExpression.fromEnum(FloatLikeExpressionEnum.Runtime(Custom(context -> {
			final variable = context.localVariables.get(this);
			final code = variable.loadToVolatile();
			switch variable.type {
				case Int: code.pushStatement(calc(CastIntToFloatVV));
				case Float:
				case Vec: throw "Cannot cast vector to float.";
			}
			code;
		})));
	}

	@:to public function toAngleExpr(): AngleExpression {
		return AngleExpression.fromEnum(FloatLikeExpressionEnum.Runtime(Custom(context -> {
			final variable = context.localVariables.get(this);
			final code = variable.loadToVolatile();
			switch variable.type {
				case Int:
					code.pushStatement(calc(CastIntToFloatVV));
					code.pushStatement(
						calc(MultFloatVCV),
						[Float(AngleExpression.constantFactor)]
					);
				case Float:
				case Vec: throw "Cannot cast vector to float.";
			}
			code;
		})));
	}

	extern inline function new(name: String)
		this = name;
}
