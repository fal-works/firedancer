package firedancer.script.api_components;

import firedancer.script.expression.LocalVariableExpression;
import firedancer.script.nodes.DeclareLocalVariable;
import firedancer.script.nodes.OperateLocalVariable;


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

	public function set(value: IntExpression): OperateLocalVariable
		return { name: this.name, value: value, operation: Set };

	public function add(value: IntExpression): OperateLocalVariable
		return { name: this.name, value: value, operation: Add };
}

class FloatLocalVariable extends LocalVariable {
	public function let(?initialValue: FloatExpression): DeclareLocalVariable {
		return DeclareLocalVariable.fromFloat(name, initialValue);
	}

	public function get(): FloatExpression
		return LocalVariableExpression.fromName(this.name);

	public function set(value: FloatExpression): OperateLocalVariable
		return { name: this.name, value: value, operation: Set };

	public function add(value: FloatExpression): OperateLocalVariable
		return { name: this.name, value: value, operation: Add };
}

class AngleLocalVariable extends LocalVariable {
	public function let(?initialValue: AngleExpression): DeclareLocalVariable {
		return DeclareLocalVariable.fromAngle(name, initialValue);
	}

	public function get(): AngleExpression
		return LocalVariableExpression.fromName(this.name);

	public function set(value: AngleExpression): OperateLocalVariable
		return { name: this.name, value: value, operation: Set };

	public function add(value: AngleExpression): OperateLocalVariable
		return { name: this.name, value: value, operation: Add };
}
