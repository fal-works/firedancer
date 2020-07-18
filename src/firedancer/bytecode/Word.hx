package firedancer.bytecode;

import haxe.Int32;
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
	Int(value: Int32);

	/**
		Float operand.
	**/
	Float(value: Float);
}
