package firedancer.ast.nodes;

import firedancer.types.NInt;
import firedancer.assembly.Opcode.OpcodeOperateVectorC;
import firedancer.bytecode.internal.Constants.LEN32;

/**
	Operates actor's position/velocity with specific constant values.
**/
@:ripper_verified
class OperateVectorC implements ripper.Data implements AstNode {
	public final opcode: OpcodeOperateVectorC;
	public final x: Float;
	public final y: Float;

	/**
		Performs this operation gradually in `frames`.
	**/
	public inline function frames(frames: NInt): OperateVectorLinear
		return new OperateVectorLinear(opcode, x, y, frames);

	public inline function containsWait(): Bool
		return false;

	public function toAssembly(): AssemblyCode
		return operateVectorC(opcode, x, y);
}

/**
	Operates actor's position/velocity with linear easing.
**/
@:ripper_verified
class OperateVectorLinear implements ripper.Data implements AstNode {
	public final opcode: OpcodeOperateVectorC;
	public final x: Float;
	public final y: Float;
	public final frames: NInt;
	public var isInlined = false;

	public inline function inlined(): OperateVectorLinear {
		this.isInlined = true;
		return this;
	}

	public inline function containsWait(): Bool
		return true;

	public function toAssembly(): AssemblyCode {
		final frames = this.frames;
		var prepare: AssemblyCode;
		var body: AssemblyCode;
		var complete: AssemblyCode;

		switch this.opcode {
			case SetPositionC:
				prepare = [
					calcRelativePositionCV(this.x, this.y),
					multVecVCS(1.0 / frames)
				];
				// skip the loop counter when peeking
				body = [breakFrame(), peekVec(LEN32), operateVectorV(AddPositionV)];
				complete = [dropVec()];
			case SetVelocityC:
				prepare = [
					calcRelativeVelocityCV(this.x, this.y),
					multVecVCS(1.0 / frames)
				];
				// skip the loop counter when peeking
				body = [breakFrame(), peekVec(LEN32), operateVectorV(AddVelocityV)];
				complete = [dropVec()];
			case AddPositionC | AddVelocityC:
				prepare = [];
				body = [
					breakFrame(),
					operateVectorC(this.opcode, this.x / frames, this.y / frames)
				];
				complete = [];
		};

		final loopedBody = if (this.isInlined) loopInlined(
			_ -> body,
			frames
		) else loop(body, frames);

		return [
			prepare,
			loopedBody,
			complete
		].flatten();
	}
}
