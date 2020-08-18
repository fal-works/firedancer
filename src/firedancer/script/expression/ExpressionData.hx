package firedancer.script.expression;

import firedancer.assembly.Opcode;
import firedancer.assembly.AssemblyCode;
import firedancer.assembly.Immediate;

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

	/**
		@return `Immediate` value if `this` is evaluated as a constant.
	**/
	public function tryMakeImmediate(): Maybe<Immediate>;
}
