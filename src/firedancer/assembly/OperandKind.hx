package firedancer.assembly;

enum abstract OperandKind(Int) {
	final Null;
	final Imm;
	final Reg;
	final RegBuf;
	final Stack;
	final Var;
}
