package firedancer.bytecode;

import banker.binary.Bytes;

/**
	Bytecode that can be executed by `firedancer.bytecode.Vm`.
**/
@:notNull @:forward
abstract Bytecode(Bytes) from Bytes to Bytes {}
