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
		Deeply compares `this` and `other`.
	**/
	public function equals(other: AssemblyCode): Bool {
		if (this == other) return true;
		if (this.length != other.length) return false;

		for (i in 0...this.length)
			if (!this[i].equals(other[i])) return false;

		return true;
	}

	/**
		@return `this` in `String` representation.
	**/
	public function toString(): String
		return this.map(instruction -> instruction.toString()).join("\n") + "\n";
}
