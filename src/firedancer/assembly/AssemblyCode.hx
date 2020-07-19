package firedancer.assembly;

import firedancer.bytecode.WordArray;
import firedancer.bytecode.Bytecode;

private typedef Data = Array<AssemblyStatement>;

/**
	Represents bullet pattern code written in a virtual assembly language.
**/
@:notNull @:forward
abstract AssemblyCode(Data) from Data to Data {
	@:from static function fromStatement(statement: AssemblyStatement): AssemblyCode
		return [statement];

	/**
		@return The bytecode length in bytes after compiled.
	**/
	public function bytecodeLength(): UInt {
		var len = UInt.zero;
		for (i in 0...this.length) len += this[i].bytecodeLength();
		return len;
	}

	/**
		Compiles `this` code into `Bytecode`.
	**/
	public function compile(): Bytecode {
		final words: WordArray = this.map(statement -> statement.toWordArray()).flatten();
		return words.toBytecode();
	}

	/**
		@return `this` in `String` representation.
	**/
	public function toString(): String
		return this.map(statement -> statement.toString()).join("\n");
}
