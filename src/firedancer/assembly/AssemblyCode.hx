package firedancer.assembly;

import firedancer.bytecode.WordArray;
import firedancer.bytecode.Program;

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
		@return The bytecode length in bytes after assembled.
	**/
	public function bytecodeLength(): UInt {
		var len = UInt.zero;
		for (i in 0...this.length) len += this[i].bytecodeLength();
		return len;
	}

	/**
		Assembles `this` code into `Program`.
	**/
	public function assemble(): Program {
		final labelAddressMap = new Map<UInt, UInt>();
		final instructions: Array<Instruction> = [];
		var lengthInBytes = UInt.zero;

		// consume labels
		for (i in 0...this.length) {
			final cur = this[i];
			switch cur {
				case Label(labelId):
					labelAddressMap.set(labelId, lengthInBytes);
				default:
					instructions.push(cur);
					lengthInBytes += cur.bytecodeLength();
			}
		}

		final words: WordArray = [];

		for (i in 0...instructions.length) {
			final instruction = instructions[i];
			final curWords = instruction.toWordArray(labelAddressMap);
			words.pushFromArray(curWords);
		}

		return words.toProgram();
	}

	/**
		@return `this` in `String` representation.
	**/
	public function toString(): String
		return this.map(instruction -> instruction.toString()).join("\n");
}
