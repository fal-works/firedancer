package firedancer.bytecode;

import banker.vector.Vector;
import banker.map.ArrayMap;

using banker.type_extension.MapExtension;

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
	final nameIdMap: ArrayMap<String, UInt>;

	public function new(
		bytecodeList: Vector<Bytecode>,
		nameIdMapping: Map<String, UInt>
	) {
		this.bytecodeTable = bytecodeList;

		final nameIdMap = new ArrayMap<String, UInt>(nameIdMapping.countKeys());
		for (name => id in nameIdMapping) nameIdMap.set(name, id);
		this.nameIdMap = nameIdMap;
	}

	/**
		@return `Bytecode` registered with `name`.
	**/
	public function getBytecodeByName(name: String): Bytecode {
		#if debug
		if (!this.nameIdMap.hasKey(name)) throw 'Bytecode not found: $name';
		#end

		final id = this.nameIdMap.get(name);
		return this.bytecodeTable[id];
	}
}
