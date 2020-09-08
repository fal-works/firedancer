package firedancer.script.expression;

import firedancer.script.nodes.DeclareLocalVariable;
import firedancer.script.nodes.OperateLocalVariable;

@:access(firedancer.script.expression.AngleExpression)
abstract AngleLocalVariableExpression(String) {
	public extern inline function new(name: String)
		this = name;

	@:to function toAngleExpression(): AngleExpression {
		return AngleExpression.fromEnum(FloatLikeExpressionEnum.Runtime(Custom(context -> {
			final variable = context.localVariables.get(this);
			final code = variable.load();
			switch variable.type {
			case Int:
				code.push(Cast(IntToFloat));
				code.push(
					Mult(Float(RegBuf), Float(Imm(AngleExpression.constantFactor)))
				);
			case Float:
			case Vec: throw "Cannot cast vector to float.";
			}
			code;
		})));
	}

	@:to public function toString(): String
		return 'AngleVar($this)';

	@:op(-A)
	extern inline function unaryMinus(): AngleExpression
		return get().unaryMinus();

	@:op(A + B) @:commutative
	static extern inline function addOp(
		a: AngleLocalVariableExpression,
		b: AngleExpression
	): AngleExpression {
		return a.get().add(b);
	}

	@:op(A - B)
	static extern inline function subtract(
		a: AngleLocalVariableExpression,
		b: AngleExpression
	): AngleExpression {
		return a.get().subtract(b);
	}

	@:op(A - B)
	static extern inline function subtractR(
		a: AngleExpression,
		b: AngleLocalVariableExpression
	): AngleExpression {
		return a.subtract(b);
	}

	@:op(A * B) @:commutative
	static extern inline function multiply(
		a: AngleLocalVariableExpression,
		b: FloatExpression
	): AngleExpression {
		return a.get().multiply(b);
	}

	@:op(A / B)
	static extern inline function divide(
		a: AngleLocalVariableExpression,
		b: FloatExpression
	): AngleExpression {
		return a.get().divide(b);
	}

	@:op(A % B)
	static extern inline function modulo(
		a: AngleLocalVariableExpression,
		b: AngleExpression
	): AngleExpression {
		return a.get().modulo(b);
	}

	@:op(A % B)
	static extern inline function moduloR(
		a: AngleExpression,
		b: AngleLocalVariableExpression
	): AngleExpression {
		return a.modulo(b);
	}

	/**
		Declares `this` local variable so that it can be used in the current scope.
	**/
	public function let(?initialValue: AngleExpression): DeclareLocalVariable {
		return DeclareLocalVariable.fromAngle(this, initialValue);
	}

	/**
		Assigns `value` to `this` local variable.
	**/
	public function set(value: AngleExpression): OperateLocalVariable
		return { name: this, value: value, operation: Set };

	/**
		Adds `value` to `this` local variable.
	**/
	public function add(value: AngleExpression): OperateLocalVariable
		return { name: this, value: value, operation: Add };

	function get()
		return toAngleExpression();
}
