package firedancer.script.expression;

import firedancer.script.nodes.DeclareLocalVariable;
import firedancer.script.nodes.OperateLocalVariable;

@:access(firedancer.script.expression.IntExpression)
abstract IntLocalVariableExpression(String) {
	public extern inline function new(name: String)
		this = name;

	@:to function toIntExpression(): IntExpression {
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

	@:to extern inline function toFloatExpression(): FloatExpression
		return get().toFloatExpression();

	@:to extern inline function toAngleExpression(): AngleExpression
		return get().toAngleExpression();

	@:op(-A)
	extern inline function unaryMinus(): IntExpression
		return get().unaryMinus();

	@:op(A + B) @:commutative
	static extern inline function addOp(
		a: IntLocalVariableExpression,
		b: IntExpression
	): IntExpression {
		return a.get().add(b);
	}

	@:op(A - B)
	static extern inline function subtract(
		a: IntLocalVariableExpression,
		b: IntExpression
	): IntExpression {
		return a.get().subtract(b);
	}

	@:op(A - B)
	static extern inline function subtractR(
		a: IntExpression,
		b: IntLocalVariableExpression
	): IntExpression {
		return a.subtract(b);
	}

	@:op(A * B) @:commutative
	static extern inline function multiply(
		a: IntLocalVariableExpression,
		b: IntExpression
	): IntExpression {
		return a.get().multiply(b);
	}

	@:op(A / B)
	static extern inline function divide(
		a: IntLocalVariableExpression,
		b: IntExpression
	): IntExpression {
		return a.get().divide(b);
	}

	@:op(A / B)
	static extern inline function divideR(
		a: IntExpression,
		b: IntLocalVariableExpression
	): IntExpression {
		return a.divide(b);
	}

	@:op(A % B)
	static extern inline function modulo(
		a: IntLocalVariableExpression,
		b: IntExpression
	): IntExpression {
		return a.get().modulo(b);
	}

	@:op(A % B)
	static extern inline function moduloR(
		a: IntExpression,
		b: IntLocalVariableExpression
	): IntExpression {
		return a.modulo(b);
	}

	public function let(?initialValue: IntExpression): DeclareLocalVariable {
		return DeclareLocalVariable.fromInt(this, initialValue);
	}

	public function set(value: IntExpression): OperateLocalVariable
		return { name: this, value: value, operation: Set };

	public function add(value: IntExpression): OperateLocalVariable
		return { name: this, value: value, operation: Add };

	function get()
		return toIntExpression();
}
