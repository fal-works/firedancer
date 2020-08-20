package firedancer.assembly;

import firedancer.assembly.operation.*;

/**
	Static extension for `Opcode`.
	Used for compiling bytecode and should not be used in the VM as it has `switch` overhead.
**/
class OpcodeExtension {
	/**
		@return The mnemonic for `opcode`.
	**/
	public static inline function toString(opcode: Opcode): String {
		return switch opcode.category {
			case General: GeneralOperation.from(opcode.op).toString();
			case Calc: CalcOperation.from(opcode.op).toString();
			case Read: ReadOperation.from(opcode.op).toString();
			case Write: WriteOperation.from(opcode.op).toString();
		}
	}
}
