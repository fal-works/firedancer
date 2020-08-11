package firedancer.script.api_components;

import firedancer.script.expression.IntExpression;
import firedancer.script.nodes.DeclareLocalVariable;

class Let {
	public function new() {}

	/**
		Declares a new local integer variable.
		@param name
	**/
	public function int(name: String, ?initialValue: IntExpression): DeclareLocalVariable {
		return DeclareLocalVariable.fromInt(name, initialValue);
	}

	/**
		Declares a new local float variable.
		@param name
	**/
	public function float(name: String, initialValue: FloatExpression): DeclareLocalVariable {
		return DeclareLocalVariable.fromFloat(name, initialValue);
	}

	/**
		Declares a new local angle variable.
		@param name
	**/
	public function angle(name: String, initialValue: AngleExpression): DeclareLocalVariable {
		return DeclareLocalVariable.fromAngle(name, initialValue);
	}
}
