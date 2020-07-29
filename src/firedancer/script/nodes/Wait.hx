package firedancer.script.nodes;

import firedancer.types.NInt;

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
	public final frames: NInt;

	override public inline function containsWait(): Bool
		return true;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final injectionCode = context.getInjectionCode();

		if (injectionCode.length == 0) {
			return if (frames.int() <= unrollThreshold) {
				loopUnrolled(0...frames, _ -> breakFrame());
			} else {
				[pushInt(frames), countDownbreak()];
			}
		}

		final loopBody: AssemblyCode = injectionCode.concat([breakFrame()]);
		final totalLength = frames * loopBody.bytecodeLength();
		return if (totalLength <= unrollThreshold) {
			loopUnrolled(0...frames, _ -> loopBody);
		} else {
			loop(loopBody, frames);
		}
	}
}
