package firedancer.script.expression;

import firedancer.assembly.Opcode;
import firedancer.assembly.AssemblyCode;

interface ExpressionData {
	/**
		Creates an `AssemblyCode` that assigns `this` value to the current volatile float.
	**/
	public function loadToVolatile(context: CompileContext): AssemblyCode;

	/**
		Creates an `AssemblyCode` that runs either `constantOpcode` or `volatileOpcode`
		receiving `this` value as argument.
	**/
	public function use(context: CompileContext, constantOpcode: Opcode, volatileOpcode: Opcode): AssemblyCode;
}
