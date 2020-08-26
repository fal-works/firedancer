package firedancer.assembly;

import banker.vector.Vector;
import firedancer.vm.ProgramPackage;
#if debug
import sneaker.print.Printer.println;
#end

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
		Prints all `AssemblyCode` in `this` package.
	**/
	public function printAll(): Void {
		for (id in 0...codeList.length) {
			println('[ASSEMBLY] ID: $id');
			println('${codeList[id].toString()}\n');
		}
	}

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
}
