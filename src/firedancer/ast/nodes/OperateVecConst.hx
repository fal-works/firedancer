package firedancer.ast.nodes;

/**
	Sets actor's position to specific constant values.
**/
@:ripper_verified
class SetPositionConst implements ripper.Data implements AstNode {
	public final x: Float;
	public final y: Float;

	public inline function containsWait(): Bool
		return false;

	public function toAssembly(): AssemblyCode
		return setPositionConst(x, y);
}

/**
	Sets actor's velocity to specific constant values.
**/
@:ripper_verified
class SetVelocityConst implements ripper.Data implements AstNode {
	public final x: Float;
	public final y: Float;

	public inline function containsWait(): Bool
		return false;

	public function toAssembly(): AssemblyCode
		return setVelocityConst(x, y);
}
