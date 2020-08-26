package firedancer.bytecode;

import haxe.Int32;
import firedancer.assembly.Opcode;
import firedancer.bytecode.Constants.*;

#if firedancer_verbose
using firedancer.assembly.OpcodeExtension;
#end

/**
	Virtual scanner of bytecode data.
**/
@:nullSafety(Off)
class Scanner {
	#if firedancer_verbose
	static function println(s: String): Void
		sneaker.print.Printer.println(s);
	#end

	/**
		The program counter.
		Indicates the current position in the bytecode.
	**/
	public var pc: UInt;

	/**
		The upper bound of the value of `pc` i.e. the length of the bytecode.
	**/
	var codeLength(default, null): UInt;

	/**
		The bytecode data to scan.
	**/
	var code: Bytecode;

	#if debug
	/**
		Number of instructions that have been executed in the current frame.
		Used for detecting infinite loop in debug mode.
	**/
	var scanCount: UInt;
	#end

	public extern inline function new() {}

	/**
		Resets `this` scanner according to the current status of `thread`.
	**/
	public extern inline function reset(thread: Thread): Void {
		this.pc = thread.programCounter;
		this.codeLength = thread.codeLength;
		this.code = thread.code.unwrap();

		#if debug
		this.scanCount = UInt.zero;
		#end
	}

	/**
		Reads the next opcode.
	**/
	public extern inline function opcode(): Opcode {
		final opcode: Opcode = cast untyped $bgetui8(code, pc);

		#if firedancer_verbose
		println('${opcode.toString()} (pos: $pc)');
		#end

		pc += Opcode.size;

		#if debug
		scanCount += 1;
		#end

		return opcode;
	}

	/**
		Reads the next integer immediate.
	**/
	public extern inline function int(): Int32 {
		final value = untyped $bgeti32(code, pc);
		pc += IntSize;
		return value;
	}

	/**
		Reads the next float immediate.
	**/
	public extern inline function float(): Float {
		final value = untyped $bgetf64(code, pc);
		pc += FloatSize;
		return value;
	}

	/**
		@return `true` if the program counter has reached (or exceeded) the end of code.
	**/
	public extern inline function reachedEnd(): Bool
		return codeLength <= pc;

	/**
		Throws error if `opcode()` is called more times than `threshold`.

		No effect `#if !debug`.
	**/
	public extern inline function checkInfinite(threshold: UInt): Void {
		#if debug
		if (threshold < scanCount) throw "Detected infinite loop.";
		#end
	}
}
