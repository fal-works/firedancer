package firedancer.assembly;

import firedancer.bytecode.WordArray;
import firedancer.bytecode.Program;

class Assembler {
	public static function assemble(code: AssemblyCode): Program {
		final labelAddressMap = new Map<UInt, UInt>();
		final instructions: Array<Instruction> = [];
		var lengthInBytes = UInt.zero;

		// consume labels
		for (i in 0...code.length) {
			final cur = code[i];
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
}
