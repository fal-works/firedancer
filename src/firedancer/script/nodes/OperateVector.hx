package firedancer.script.nodes;

import firedancer.types.NInt;
import firedancer.assembly.Opcode;
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

		inline function relativeChange(
			calcRelativeOpcode: CalcRelativeVec,
			addVecOpcode: OpcodeOperateVectorNonC
		): Void {
			prepare = [
				calcRelativePositionCV(calcRelativeOpcode, this.x, this.y),
				multVecVCS(1.0 / frames)
			];
			// skip the loop counter when peeking
			body = [breakFrame(), peekVec(LEN32), operateVectorNonC(addVecOpcode)];
			complete = [dropVec()];
		}

		switch this.opcode {
			case SetPositionC:
				relativeChange(CalcRelativePositionCV, AddPositionV);
			case SetVelocityC:
				relativeChange(CalcRelativeVelocityCV, AddVelocityV);
			case SetShotPositionC:
				relativeChange(CalcRelativeShotPositionCV, AddShotPositionV);
			case SetShotVelocityC:
				relativeChange(CalcRelativeShotVelocityCV, AddShotVelocityV);
			case AddPositionC | AddVelocityC | AddShotPositionC | AddShotVelocityC:
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
