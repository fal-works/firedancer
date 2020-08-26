package firedancer.assembly;

import firedancer.bytecode.FireArgument;
import firedancer.script.CompileContext;
import firedancer.script.expression.IntExpression;

/**
	Functions for creating `Instruction`/`AssemblyCode` instances.
**/
class Builder {
	/**
		Creates a code instance that repeats `body` in runtime.
	**/
	public static function constructLoop(
		context: CompileContext,
		pushLoopCount: AssemblyCode,
		body: AssemblyCode
	) {
		final nextLabelIdStack = context.nextLabelIdStack;
		var nextLabelId = nextLabelIdStack.pop().unwrap();
		final startLabelId = nextLabelId++;
		final endLabelId = nextLabelId++;
		nextLabelIdStack.push(nextLabelId);

		final prepareLoop: AssemblyCode = [];
		prepareLoop.pushFromArray(pushLoopCount);
		prepareLoop.push(Label(startLabelId));
		prepareLoop.push(CountDownGotoLabel(endLabelId));

		final closeLoop: AssemblyCode = [GotoLabel(startLabelId), Label(endLabelId)];

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
	public static function loop(
		context: CompileContext,
		body: AssemblyCode,
		count: IntExpression
	): AssemblyCode {
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
			Fire(switch fireCode {
			case 0: Simple;
			default: SimpleWithCode(fireCode);
			});
		} else {
			final arg = fireArgument.unwrap();
			Fire(switch fireCode {
			case 0: Complex(arg);
			default: ComplexWithCode(arg, fireCode);
			});
		}
	}
}
