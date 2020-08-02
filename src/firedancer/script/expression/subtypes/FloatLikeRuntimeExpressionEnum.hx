package firedancer.script.expression.subtypes;

import firedancer.assembly.Opcode;

/**
	Expression of any float-like type that has to be evaluated in runtime.
**/
enum FloatLikeRuntimeExpressionEnum {
	/**
		@param loadV `Opcode` for loading the value to the current volatile float.
	**/
	Variable(loadV: Opcode);
}
