package firedancer.bytecode;

import haxe.Int32;

/**
	Argument for `debug()`.
**/
enum abstract DebugCode(Int32) to Int32 {
	/**
		Prints the current status of the VM.
	**/
	final Dump;
}
