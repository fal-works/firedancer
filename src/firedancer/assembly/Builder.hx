package firedancer.assembly;

import firedancer.bytecode.types.FireArgument;
import firedancer.script.CompileContext;
import firedancer.script.expression.IntExpression;
import firedancer.assembly.operation.GeneralOperation;

/**
	Functions for creating `Instruction`/`AssemblyCode` instances.
**/
class Builder {
	/**
		Creates a code instance that repeats `body` in runtime.
	**/
	public static function constructLoop(context: CompileContext, pushLoopCount: AssemblyCode, body: AssemblyCode) {
		final nextLabelIdStack = context.nextLabelIdStack;
		var nextLabelId = nextLabelIdStack.pop().unwrap();
		final startLabelId = nextLabelId++;
		final endLabelId = nextLabelId++;
		nextLabelIdStack.push(nextLabelId);

		final prepareLoop: AssemblyCode = [];
		prepareLoop.pushFromArray(pushLoopCount);
		prepareLoop.push(Label(startLabelId));
		prepareLoop.push(CountDownGotoLabel(endLabelId));

		final closeLoop: AssemblyCode = [
			GotoLabel(startLabelId),
			Label(endLabelId)
		];

		return [
			prepareLoop,
			body,
			closeLoop
		].flatten();
	}

	/**
		Creates a code instance that repeats `body` in runtime.

		Use `constructLoop()` to avoid evaluating `count` and provide the preparation code instead.
	**/
	public static function loop(context: CompileContext, body: AssemblyCode, count: IntExpression): AssemblyCode {
		final pushLoopCount: AssemblyCode = count.loadToVolatile(context);
		pushLoopCount.push(Push(Int(Reg)));

		return constructLoop(context, pushLoopCount, body);
	}

	/**
		Creates a code instance with `bodyFactory` repeated in compile-time.
	**/
	public static function loopUnrolled(
		iterator: IntIterator,
		bodyFactory: (index: Int) -> AssemblyCode
	): AssemblyCode {
		return [for (i in iterator) bodyFactory(i)].flatten();
	}

	/**
		Creates an instruction with firing opcode.
	**/
	public static inline function fire(
		fireArgument: Maybe<FireArgument>,
		fireCode: Int = 0
	): Instruction {
		return if (fireArgument.isNone()) {
			switch fireCode {
				case 0: FireSimple;
				default: FireSimpleWithCode(fireCode);
			}
		} else {
			final arg = fireArgument.unwrap();
			switch fireCode {
				case 0: FireComplex(arg);
				default: FireComplexWithCode(arg, fireCode);
			}
		}
	}
}
