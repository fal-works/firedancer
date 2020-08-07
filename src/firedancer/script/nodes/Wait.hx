package firedancer.script.nodes;

import firedancer.script.expression.IntExpression;

/**
	Waits for a specific number of frames.
**/
@:ripper_verified
class Wait extends AstNode implements ripper.Data {
	/**
		The maximum length in bytes of an unrolled block of `AssemblyCode`.
	**/
	public static var unrollThreshold: UInt = 32;

	/**
		Wait duration in frames.
	**/
	public final frames: IntExpression;

	override public inline function containsWait(): Bool
		return true;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final injectionCode = context.getInjectionCode();
		final loopBody: AssemblyCode = injectionCode.concat([breakFrame()]);

		switch frames.toEnum() {
			case Constant(constFrames):
				final framesValue = constFrames.raw();
				final totalLength = framesValue * loopBody.bytecodeLength();

				if (totalLength <= unrollThreshold)
					return loopUnrolled(0...framesValue, _ -> loopBody);

				if (injectionCode.length == 0)
					return [pushIntC(framesValue), countDownbreak()];

			default:
		}

		return loop(loopBody, frames);
	}
}
