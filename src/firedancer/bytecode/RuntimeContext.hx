package firedancer.bytecode;

import banker.vector.Vector;

/**
	Context for running a `Bytecode`.
**/
class RuntimeContext {
	/**
		Table for retrieving `Bytecode` by ID number.
	**/
	public final bytecodeTable: Vector<Bytecode>;

	/**
		Mapping from names to ID numbers of `Bytecode` instances.
	**/
	final nameIdMap = new Map<String, UInt>();

	public function new(bytecodeList: Vector<Bytecode>, nameIdMap: Map<String, UInt>) {
		this.bytecodeTable = bytecodeList;
		this.nameIdMap = nameIdMap;
	}

	/**
		@return `Bytecode` registered with `name`.
	**/
	public function getBytecodeByName(name: String): Bytecode {
		final id = this.nameIdMap.get(name);
		if (id == null) throw 'Bytecode not found: $name';
		return this.bytecodeTable[id];
	}
}
