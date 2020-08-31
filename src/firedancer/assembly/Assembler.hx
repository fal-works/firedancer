package firedancer.assembly;

import firedancer.vm.Program;

class Assembler {
	public static function assemble(code: AssemblyCode): Program {
		final labelPositionMap = new Map<UInt, UInt>();
		final instructions: Array<Instruction> = [];
		var lengthInBytes = UInt.zero;

		// consume labels
		for (i in 0...code.length) {
			final cur = code[i];
			switch cur {
			case Label(labelId):
				labelPositionMap.set(labelId, lengthInBytes);
			default:
				instructions.push(cur);
				lengthInBytes += cur.bytecodeLength();
			}
		}

		final variableTable = new VariableTable();
		final words: WordArray = [];

		for (i in 0...instructions.length) {
			final instruction = instructions[i];
			final curWords = instruction.toWordArray(labelPositionMap, variableTable);

			// if (curWords.length > 0)
			// 	Sys.println('[${words.getLengthInBytes()}] ${curWords.toString()}');

			words.pushFromArray(curWords);
		}

		return words.toProgram();
	}
}

class VariableTable {
	static function notFound(key: String): String
		return 'Variable not found: $key';

	/**
		List of variable records.
		Should be sorted by `address` in ascending order.
	**/
	final table: Array<{key: String, address: UInt, type: ValueType }> = [];

	final addressStackMap = new Map<String, Array<UInt>>();

	public function new() {}

	public function let(key: String, type: ValueType): Void {
		var address = UInt.zero;
		var inserted = false;

		for (i in 0...table.length) {
			final entry = table[i];
			if (address + type.size < entry.address) {
				table.insert(i, { key: key, address: address, type: type });
				inserted = true;
				break;
			} else {
				address = entry.address + entry.type.size;
			}
		}

		if (!inserted) table.push({ key: key, address: address, type: type });

		final addressStack = this.addressStackMap.get(key);
		if (addressStack != null) addressStack.push(address);
		else this.addressStackMap.set(key, [address]);
	}

	public function getAddress(key: String): UInt {
		final addressStack = this.addressStackMap.get(key);
		if (addressStack == null) throw notFound(key);

		final address = addressStack.getLastSafe();
		if (address.isNone()) throw notFound(key);

		return address.unwrap();
	}

	public function free(key: String): Void {
		final addressStack = this.addressStackMap.get(key);
		if (addressStack == null) throw notFound(key);

		final address = addressStack.pop().unwrap();

		final table = this.table;
		for (i in 0...table.length) {
			final entry = table[i];
			if (entry.key == key && entry.address == address) {
				table.removeAt(i);
				break;
			}
		}
	}
}
