package firedancer.assembly;

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
		@return `this` in `String` representation.
	**/
	public function toString(): String
		return this.map(instruction -> instruction.toString()).join("\n");
}
