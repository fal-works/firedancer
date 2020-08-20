package firedancer.script.expression;

import firedancer.assembly.Instruction;
import firedancer.assembly.AssemblyCode;

interface ExpressionData {
	/**
		Creates an `AssemblyCode` that assigns `this` value to the current volatile float.
	**/
	public function loadToVolatile(context: CompileContext): AssemblyCode;

	/**
		Creates an `AssemblyCode` that runs `instruction` receiving `this` value as argument.
	**/
	public function use(context: CompileContext, instruction: Instruction): AssemblyCode;
}
