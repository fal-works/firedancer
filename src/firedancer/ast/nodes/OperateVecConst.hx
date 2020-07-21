package firedancer.ast.nodes;

import firedancer.assembly.Opcode.OperateVectorConstOpcode;

/**
	Operates actor's position/velocity with specific constant values.
**/
@:ripper_verified
class OperateVectorConst implements ripper.Data implements AstNode {
	public final opcode: OperateVectorConstOpcode;
	public final x: Float;
	public final y: Float;

	public inline function containsWait(): Bool
		return false;

	public function toAssembly(): AssemblyCode
		return operateVectorConst(opcode, x, y);
}
