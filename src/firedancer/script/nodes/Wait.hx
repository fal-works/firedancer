package firedancer.script.nodes;

import firedancer.script.expression.IntExpression;

/**
	Waits for a specific number of frames.
**/
@:ripper_verified
class Wait extends AstNode implements ripper.Data {
	/**
		Wait duration in frames.
	**/
	final frames: IntExpression;

	override inline function containsWait(): Bool
		return true;

	override function toAssembly(context: CompileContext): AssemblyCode {
		final injectionCode = context.getInjectionCode();
		final loopBody: AssemblyCode = injectionCode.concat([Break]);

		if (injectionCode.length == 0)
			return [
				frames.load(context),
				[Push(Int(Reg)), CountDownBreak]
			].flatten();

		return loop(context, loopBody, frames);
	}
}
