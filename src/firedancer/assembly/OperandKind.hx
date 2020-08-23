package firedancer.assembly;

enum abstract OperandKind(Int) {
	final Null;
	final Imm;
	final Reg;
	final RegBuf;
	final Stack;
	final Var;
}

enum abstract RegOrRegBuf(Int) {
	final Reg;
	final RegBuf;
}

enum abstract RegOrStack(Int) {
	final Reg;
	final Stack;
}
