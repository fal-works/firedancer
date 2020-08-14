package firedancer.assembly;

import firedancer.bytecode.WordArray;
import firedancer.bytecode.Bytecode;

private typedef Data = Array<Instruction>;

/**
	Represents bullet pattern code written in a virtual assembly language.
**/
@:notNull @:forward
abstract AssemblyCode(Data) from Data to Data {
	@:from static extern inline function fromInstruction(
		instruction: Instruction
	): AssemblyCode
		return [instruction];

	/**
		Pushes a new `Instruction` created from `opcode` and `operands`.
	**/
	public function pushInstruction(opcode: Opcode, ?operands: Array<Immediate>): Void
		this.push(Instruction.create(opcode, operands));

	/**
		@return The bytecode length in bytes after assembled.
	**/
	public function bytecodeLength(): UInt {
		var len = UInt.zero;
		for (i in 0...this.length) len += this[i].bytecodeLength();
		return len;
	}

	/**
		Assembles `this` code into `Bytecode`.
	**/
	public function assemble(): Bytecode {
		final words: WordArray = this.map(instruction -> instruction.toWordArray()).flatten();
		return words.toBytecode();
	}

	/**
		@return `this` in `String` representation.
	**/
	public function toString(): String
		return this.map(instruction -> instruction.toString()).join("\n");
}
