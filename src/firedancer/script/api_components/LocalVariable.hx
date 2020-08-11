package firedancer.script.api_components;

import firedancer.script.expression.LocalVariableExpression;
import firedancer.script.nodes.DeclareLocalVariable;

class LocalVariable {
	final name: String;

	public function new(name: String) {
		this.name = name;
	}
}

class IntLocalVariable extends LocalVariable {
	public function let(?initialValue: IntExpression): DeclareLocalVariable {
		return DeclareLocalVariable.fromInt(name, initialValue);
	}

	public function get(): IntExpression
		return LocalVariableExpression.fromName(this.name);
}

class FloatLocalVariable extends LocalVariable {
	public function let(?initialValue: FloatExpression): DeclareLocalVariable {
		return DeclareLocalVariable.fromFloat(name, initialValue);
	}

	public function get(): FloatExpression
		return LocalVariableExpression.fromName(this.name);
}

class AngleLocalVariable extends LocalVariable {
	public function let(?initialValue: AngleExpression): DeclareLocalVariable {
		return DeclareLocalVariable.fromAngle(name, initialValue);
	}

	public function get(): AngleExpression
		return LocalVariableExpression.fromName(this.name);
}
