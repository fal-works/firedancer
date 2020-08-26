package firedancer.assembly;

import sneaker.string_buffer.StringBuffer;
import sneaker.print.Printer;
import banker.vector.Vector;
import firedancer.vm.ProgramPackage;

@:structInit
class AssemblyCodePackage {
	/**
		List of `AssemblyCode` that should be able to retrieved by an `UInt` ID.
	**/
	final codeList: Array<AssemblyCode>;

	/**
		Mapping from names to ID numbers of `AssemblyCode` instances.
	**/
	final nameIndexMap: Map<String, UInt>;

	/**
		@return New `AssemblyCodePackage` with all `AssemblyCode` optimized.
	**/
	public function optimize(): AssemblyCodePackage {
		return {
			codeList: this.codeList.map(Optimizer.optimize),
			nameIndexMap: this.nameIndexMap
		};
	}

	public function assemble(): ProgramPackage {
		final assembled = this.codeList.map(Assembler.assemble);
		final bytecodeList = Vector.fromArrayCopy(assembled);

		return new ProgramPackage(bytecodeList, this.nameIndexMap);
	}

	/**
		Creates a `ProgramPackage` instance.
	**/
	public function createPackage(optimize = true): ProgramPackage {
		var codeList = this.codeList;
		if (optimize) codeList = codeList.map(Optimizer.optimize);

		#if debug
		this.printAll();
		#end

		final assembled = codeList.map(Assembler.assemble);
		final bytecodeList = Vector.fromArrayCopy(assembled);

		return new ProgramPackage(bytecodeList, this.nameIndexMap);
	}

	/**
		Converts all `AssemblyCode` in `this` package into a `String`.
	**/
	public function toString(): String {
		final buf = new StringBuffer();

		final lastId = codeList.length - 1;
		for (id in 0...codeList.length) {
			buf.addLf('[ASSEMBLY] ID: $id');
			buf.add('${codeList[id].toString()}');
			if (id < lastId) buf.lf();
		}

		return buf.toString();
	}

	/**
		Prints all `AssemblyCode` in `this` package.
	**/
	public function printAll(): Void
		Printer.print(this.toString());
}
