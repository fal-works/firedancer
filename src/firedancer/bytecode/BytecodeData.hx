package firedancer.bytecode;

import banker.binary.BytesData;

/**
	Bytecode data that can be executed by `firedancer.bytecode.Vm`.
	This does not have the `length` property (use `Bytecode` if you need it).
**/
@:notNull @:forward
abstract BytecodeData(BytesData) from BytesData to BytesData {
	public static final empty = Bytecode.empty.data;
}
