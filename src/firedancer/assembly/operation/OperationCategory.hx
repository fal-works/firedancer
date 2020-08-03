package firedancer.assembly.operation;

/**
	Value that specifies the category of an operation.
**/
enum abstract OperationCategory(Int) {
	final General = 0;
	final Read = 1;
	final Write = 2;
	final WriteShot = 3;

	public inline function int()
		return this;
}
