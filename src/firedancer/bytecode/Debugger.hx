package firedancer.bytecode;

import sneaker.string_buffer.StringBuffer;
import sneaker.print.Printer;

/**
	Functions for debugging purposes.
**/
class Debugger {
	/**
		Prints the current status of the VM.
	**/
	public static extern inline function dump(scanner: Scanner, mem: Memory, reg: DataRegisterFile): Void {
		final buf = new StringBuffer();

		buf.addLf("---- DUMP -------------------------------------\n");

		dumpScanner(buf, scanner);
		dumpMemory(buf, mem);
		dumpDataRegisterFile(buf, reg);

		buf.addLf("\n------------------------------ END OF DUMP ----");

		Printer.println(buf.toString());
	}

	@:access(firedancer.bytecode.Scanner)
	static extern inline function dumpScanner(buf: StringBuffer, scanner: Scanner): Void {
		buf.addLf("[scanner]");

		buf.add("program counter: ");
		buf.addLf(scanner.pc);
		buf.add("bytecode length: ");
		buf.addLf(scanner.codeLength);

		buf.addLf("bytecode:");
		buf.add(scanner.code.dump(scanner.codeLength, scanner.pc));
	}

	@:access(firedancer.bytecode.Memory)
	static extern inline function dumpMemory(buf: StringBuffer, mem: Memory): Void {
		buf.addLf("\n[memory]");

		buf.add("stack pointer: ");
		buf.addLf(mem.sp);
		buf.add("capacity: ");
		buf.addLf(mem.capacity);

		buf.addLf("memory dump:");
		final memData = mem.data;
		var dump = memData.toHex(mem.capacity, true);
		final dumpLength = dump.length;
		if (!mem.sp.isZero()) {
			final dumpChars = dump.split("");
			dumpChars[mem.sp * 3 - 1] = "|";
			dump = dumpChars.join("");
		}
		var pos = UInt.zero;
		final lineLength = 16 * 3; // 16 bytes with spaces
		while (pos < dumpLength) {
			buf.addLf(dump.substr(pos, lineLength - 1));
			pos += lineLength;
		}
	}

	static extern inline function dumpDataRegisterFile(buf: StringBuffer, reg: DataRegisterFile): Void {
		buf.addLf("\n[data register file]");

		buf.add("int:      ");
		buf.addLf(reg.int);
		buf.add("intBuf:   ");
		buf.addLf(reg.intBuf);
		buf.add("float:    ");
		buf.addLf(reg.float);
		buf.add("floatBuf: ");
		buf.addLf(reg.floatBuf);
		buf.add("vecX:     ");
		buf.addLf(reg.vecX);
		buf.add("vecY:     ");
		buf.addLf(reg.vecY);
	}
}
