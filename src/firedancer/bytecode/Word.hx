package firedancer.bytecode;

import firedancer.assembly.Opcode;

/**
	Data unit in `Bytecode`.
**/
enum Word {
	/**
		Operation code i.e. a value that specifies an operation to be performed.
	**/
	Opcode(code: Opcode);

	/**
		Integer operand.
	**/
	Int(value: Int);

	/**
		Float operand.
	**/
	Float(value: Float);
}
