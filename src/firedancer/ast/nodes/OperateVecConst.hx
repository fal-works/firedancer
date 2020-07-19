package firedancer.ast.nodes;

import firedancer.assembly.Opcode;

/**
	Super class of `SetPositionConst` and `SetVelocityConst`.
**/
private class OperateVecConst implements ripper.Data implements AstNode {
	public final opcode: Opcode;
	public final x: Float;
	public final y: Float;

	public inline function containsWait(): Bool
		return false;

	public function toAssembly(): AssemblyCode
		return statement(opcode, [Vec(x, y)]);
}

class SetPositionConst extends OperateVecConst {
	public function new(x: Float, y: Float) {
		super(SetPositionConst, x, y);
	}
}

class SetVelocityConst extends OperateVecConst {
	public function new(x: Float, y: Float) {
		super(SetVelocityConst, x, y);
	}
}
