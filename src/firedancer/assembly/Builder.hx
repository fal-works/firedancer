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
		Creates a `PushIntC` instruction.
	**/
	public static inline function pushIntC(v: Int): Instruction {
		return new Instruction(PushIntC, [Int(v)]);
	}

	/**
		Creates a `PushIntV` instruction.
	**/
	public static inline function pushIntV(): Instruction {
		return new Instruction(PushIntV, []);
	}

	/**
		Creates a `PeekFloat` instruction.
		@param bytesToSkip Bytes to be skipped from the stack top. `0` for peeking from the top.
	**/
	public static inline function peekFloat(bytesToSkip: Int = 0): Instruction {
		return new Instruction(PeekFloat, [Int(bytesToSkip)]);
	}

	/**
		Creates a `DropFloat` instruction.
	**/
	public static inline function dropFloat(): Instruction {
		return new Instruction(DropFloat, []);
	}

	/**
		Creates a `PeekVec` instruction.
		@param bytesToSkip Bytes to be skipped from the stack top. `0` for peeking from the top.
	**/
	public static inline function peekVec(bytesToSkip: Int = 0): Instruction {
		return new Instruction(PeekVec, [Int(bytesToSkip)]);
	}

	/**
		Creates a `DropVec` instruction.
	**/
	public static inline function dropVec(): Instruction {
		return new Instruction(DropVec, []);
	}

	/**
		Creates a `Break` instruction.
	**/
	public static inline function breakFrame(): Instruction {
		return new Instruction(Break, []);
	}

	/**
		Creates a `CountDownBreak` instruction.
	**/
	public static inline function countDownbreak(): Instruction {
		return new Instruction(CountDownBreak, []);
	}

	/**
		Creates a `Jump` instruction with a positive argument.
	**/
	public static inline function jump(lengthInBytes: UInt): Instruction {
		#if debug
		if (lengthInBytes != lengthInBytes & 0xffffffff)
			throw 'Invalid value: $lengthInBytes';
		#end

		return new Instruction(Jump, [Int(lengthInBytes.int())]);
	}

	/**
		Creates a `Jump` instruction with a negative argument.
	**/
	public static inline function jumpBack(lengthInBytes: UInt): Instruction {
		final jumpBackLength = Jump.toInstructionType().bytecodeLength();
		final totalBackLength = -jumpBackLength - lengthInBytes.int();

		#if debug
		if (totalBackLength != totalBackLength & 0xffffffff)
			throw 'Invalid value: $lengthInBytes';
		#end

		return new Instruction(Jump, [Int(totalBackLength)]);
	}

	/**
		Creates a `CountDownJump` instruction.
	**/
	public static inline function countDownJump(lengthInBytes: UInt): Instruction {
		return new Instruction(
			CountDownJump,
			[Int(lengthInBytes.int())]
		);
	}

	/**
		Creates a code instance that repeats `body` in runtime.
	**/
	public static function loop(context: CompileContext, body: AssemblyCode, count: IntExpression): AssemblyCode {
		final bodyLength = body.bytecodeLength().int();

		final countValue = count.tryGetConstant();

		final prepareLoop: AssemblyCode = if (countValue.isSome()) {
			pushIntC(countValue.unwrap());
		} else {
			final code = count.loadToVolatile(context);
			code.pushInstruction(PushIntV);
			code;
		};
		prepareLoop.push(countDownJump(bodyLength + Jump.getBytecodeLength()));

		final closeLoop: AssemblyCode = {
			jumpBack(body.bytecodeLength() + CountDownJump.getBytecodeLength());
		};

		return [
			prepareLoop,
			body,
			closeLoop
		].flatten();
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
			if (fireCode == 0) {
				new Instruction(FireSimple, []);
			} else {
				new Instruction(
					FireSimpleWithCode,
					[Int(fireCode)]
				);
			}
		} else {
			final arg = fireArgument.unwrap();
			if (fireCode == 0) {
				new Instruction(FireComplex, [arg]);
			} else {
				new Instruction(
					FireComplexWithCode,
					[arg, Int(fireCode)]
				);
			}
		}
	}

	/**
		Creates a `UseThread` instruction.
	**/
	public static inline function useThread(bytecodeId: Int): Instruction {
		return new Instruction(UseThread, [Int(bytecodeId)]);
	}

	/**
		Creates an `AwaitThread` instruction.
	**/
	public static inline function awaitThread(): Instruction {
		return new Instruction(AwaitThread, []);
	}

	/**
		Creates an `End` instruction.
	**/
	public static inline function end(endCode: Int): Instruction {
		return new Instruction(End, [Int(endCode)]);
	}
}
