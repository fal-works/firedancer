package firedancer.script.expression;

import firedancer.assembly.ConstantOperand;
import firedancer.assembly.AssemblyCode;

abstract GenericExpression(Data) from Data {
	@:from static extern inline function fromIntExpr(expr: IntExpression): GenericExpression
		return IntExpr(expr);

	@:from static extern inline function fromFloatExpr(expr: FloatExpression): GenericExpression
		return FloatExpr(expr);

	@:from static extern inline function fromAngleExpr(expr: AngleExpression): GenericExpression
		return AngleExpr(expr);

	@:from static extern inline function fromVecExpr(expr: VecExpression): GenericExpression
		return VecExpr(expr);

	@:to function toIntExpr(): IntExpression {
		return switch this {
			case IntExpr(expr): expr;
			case FloatExpr(_): throw "Cannot cast FloatExpression to IntExpression.";
			case AngleExpr(_): throw "Cannot cast AngleExpression to IntExpression.";
			case VecExpr(_): throw "Cannot cast VecExpression to IntExpression.";
		}
	}

	@:to function toFloatExpr(): FloatExpression {
		return switch this {
			case IntExpr(expr): expr;
			case FloatExpr(expr): expr;
			case AngleExpr(_): throw "Cannot cast AngleExpression to FloatExpression.";
			case VecExpr(_): throw "Cannot cast VecExpression to FloatExpression.";
		}
	}

	@:to function toAngleExpr(): AngleExpression {
		return switch this {
			case IntExpr(expr): expr;
			case FloatExpr(_): throw "Cannot cast AngleExpression to FloatExpression.";
			case AngleExpr(expr): expr;
			case VecExpr(_): throw "Cannot cast VecExpression to AngleExpression.";
		}
	}

	@:to function toVecExpr(): VecExpression {
		return switch this {
			case IntExpr(_): throw "Cannot cast IntExpression to VecExpression.";
			case FloatExpr(_): throw "Cannot cast FloatExpression to VecExpression.";
			case AngleExpr(_): throw "Cannot cast AngleExpression to VecExpression.";
			case VecExpr(expr): expr;
		}
	}

	/**
		Creates an `AssemblyCode` that assigns `this` value to the current volatile float.
	**/
	public function loadToVolatile(context: CompileContext): AssemblyCode {
		return switch this {
			case IntExpr(expr): expr.loadToVolatile(context);
			case FloatExpr(expr): expr.loadToVolatile(context);
			case AngleExpr(expr): expr.loadToVolatile(context);
			case VecExpr(expr): expr.loadToVolatile(context);
		}
	}

	public function tryGetConstantOperand(): Maybe<ConstantOperand> {
		return switch this {
			case IntExpr(expr): expr.tryGetConstantOperand();
			case FloatExpr(expr): expr.tryGetConstantOperand();
			case AngleExpr(expr): expr.tryGetConstantOperand();
			case VecExpr(expr): expr.tryGetConstantOperand();
		}
	}

	public extern inline function toEnum(): Data
		return this;
}

private enum Data {
	IntExpr(expr: IntExpression);
	FloatExpr(expr: FloatExpression);
	AngleExpr(expr: AngleExpression);
	VecExpr(expr: VecExpression);
}
