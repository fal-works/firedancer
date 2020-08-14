package firedancer.bytecode;

import banker.vector.Vector;
import banker.map.ArrayMap;

using banker.type_extension.MapExtension;

/**
	Collection of `Program` instances that can be retrieved by ID or name.
**/
class ProgramPackage {
	/**
		Table for retrieving `Program` by ID number.
	**/
	public final programTable: Vector<Program>;

	/**
		Mapping from names to ID numbers of `Program` instances.
	**/
	final nameIdMap: ArrayMap<String, UInt>;

	public function new(
		programList: Vector<Program>,
		nameIdMapping: Map<String, UInt>
	) {
		this.programTable = programList;

		final nameIdMap = new ArrayMap<String, UInt>(nameIdMapping.countKeys());
		for (name => id in nameIdMapping) nameIdMap.set(name, id);
		this.nameIdMap = nameIdMap;
	}

	/**
		@return `Program` registered with `name`.
	**/
	public function getProgramByName(name: String): Program {
		#if debug
		if (!this.nameIdMap.hasKey(name)) throw 'Program not found: $name';
		#end

		final id = this.nameIdMap.get(name);
		return this.programTable[id];
	}
}
