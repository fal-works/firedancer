package firedancer.ast.nodes;

import firedancer.types.NInt;
import firedancer.assembly.Opcode;
import firedancer.bytecode.internal.Constants.LEN32;

/**
	Operates one component of actor's position/velocity with specific constant values.
**/
@:ripper_verified
class OperateAttributeC implements ripper.Data implements AstNode {
	public final opcode: Opcode;
	public final value: Float;

	/**
		Performs this operation gradually in `frames`.
	**/
	public inline function frames(frames: NInt): OperateAttributeLinear
		return new OperateAttributeLinear(opcode, value, frames);

	public inline function containsWait(): Bool
		return false;

	public function toAssembly(): AssemblyCode
		return statement(opcode, [Float(value)]);
}

/**
	Operates one component of actor's position/velocity with linear easing.
**/
@:ripper_verified
class OperateAttributeLinear implements ripper.Data implements AstNode {
	public final opcode: Opcode;
	public final value: Float;
	public final frames: NInt;
	public var isInlined = false;

	public inline function inlined(): OperateAttributeLinear {
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
			calcRelativeOpcode: Opcode,
			addOpcode: Opcode
		): Void {
			prepare = [
				statement(calcRelativeOpcode, [Float(this.value)]),
				multFloatVCS(1.0 / frames)
			];
			// skip the loop counter when peeking
			body = [breakFrame(), peekFloat(LEN32), statement(addOpcode)];
			complete = [dropFloat()];
		}

		switch this.opcode {
			case SetDistanceC:
				relativeChange(CalcRelativeDistanceCV, AddDistanceV);
			case SetBearingC:
				relativeChange(CalcRelativeBearingCV, AddBearingV);
			case SetSpeedC:
				relativeChange(CalcRelativeSpeedCV, AddSpeedV);
			case SetDirectionC:
				relativeChange(CalcRelativeDirectionCV, AddDirectionV);
			case SetShotDistanceC:
				relativeChange(CalcRelativeShotDistanceCV, AddShotDistanceV);
			case SetShotBearingC:
				relativeChange(CalcRelativeShotBearingCV, AddShotBearingV);
			case SetShotSpeedC:
				relativeChange(CalcRelativeShotSpeedCV, AddShotSpeedV);
			case SetShotDirectionC:
				relativeChange(CalcRelativeShotDirectionCV, AddShotDirectionV);
			case AddDistanceC | AddBearingC | AddSpeedC | AddDirectionC | AddShotDistanceC | AddShotBearingC | AddShotSpeedC | AddShotDirectionC:
				prepare = [];
				body = [
					breakFrame(),
					statement(this.opcode, [Float(this.value / frames)])
				];
				complete = [];
			default:
				throw 'Invalid opcode: ${this.opcode}';
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
