package firedancer.assembly;

import firedancer.assembly.operation.*;

/**
	Static extension for `Opcode`.
	Used for compiling bytecode and should not be used in the VM as it has `switch` overhead.
**/
class OpcodeExtension {
	/**
		Creates an `InstructionType` instance that corresponds to `opcode`.
	**/
	public static inline function toInstructionType(opcode: Opcode): InstructionType {
		return switch opcode.category {
			case General: GeneralOperation.from(opcode.op).toInstructionType();
			case Calc: CalcOperation.from(opcode.op).toInstructionType();
			case Read: ReadOperation.from(opcode.op).toInstructionType();
			case Write: WriteOperation.from(opcode.op).toInstructionType();
		}
	}

	/**
		@return The bytecode length in bytes required for an instruction with `opcode`.
	**/
	public static inline function getBytecodeLength(opcode: Opcode): UInt {
		return switch opcode.category {
			case General: GeneralOperation.from(opcode.op).getBytecodeLength();
			case Calc: CalcOperation.from(opcode.op).getBytecodeLength();
			case Read: ReadOperation.from(opcode.op).getBytecodeLength();
			case Write: WriteOperation.from(opcode.op).getBytecodeLength();
		}
	}

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
