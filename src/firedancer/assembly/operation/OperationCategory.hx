package firedancer.assembly.operation;

/**
	Value that specifies the category of an operation.
**/
enum abstract OperationCategory(Int) {
	final General = 0;
	final Calc = 1;
	final Read = 2;
	final Write = 3;
	public inline function int()
		return this;
}
