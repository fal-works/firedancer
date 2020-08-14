package firedancer.bytecode;

import banker.binary.BytesData;

/**
	Bytecode that can be executed by `firedancer.bytecode.Vm`.

	This does not have the `length` property (use `Program` if you need it).
**/
@:notNull @:forward
abstract Bytecode(BytesData) from BytesData to BytesData {}
