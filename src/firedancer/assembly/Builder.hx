package firedancer.assembly;

/**
	Functions for creating `AssemblyStatement`/`AssemblyCode` instances.
**/
class Builder {
	/**
		Creates a `PushInt` statement.
	**/
	public static inline function pushInt(v: Int): AssemblyStatement {
		return new AssemblyStatement(PushInt, [Int(v)]);
	}

	/**
		Creates a `PeekFloat` statement.
		@param bytesToSkip Bytes to be skipped from the stack top. `0` for peeking from the top.
	**/
	public static inline function peekFloat(bytesToSkip: Int = 0): AssemblyStatement {
		return new AssemblyStatement(PeekFloat, [Int(bytesToSkip)]);
	}

	/**
		Creates a `DropFloat` statement.
	**/
	public static inline function dropFloat(): AssemblyStatement {
		return new AssemblyStatement(DropFloat, []);
	}

	/**
		Creates a `PeekVec` statement.
		@param bytesToSkip Bytes to be skipped from the stack top. `0` for peeking from the top.
	**/
	public static inline function peekVec(bytesToSkip: Int = 0): AssemblyStatement {
		return new AssemblyStatement(PeekVec, [Int(bytesToSkip)]);
	}

	/**
		Creates a `DropVec` statement.
	**/
	public static inline function dropVec(): AssemblyStatement {
		return new AssemblyStatement(DropVec, []);
	}

	/**
		Creates a `Break` statement.
	**/
	public static inline function breakFrame(): AssemblyStatement {
		return new AssemblyStatement(Break, []);
	}

	/**
		Creates a `CountDownBreak` statement.
	**/
	public static inline function countDownbreak(): AssemblyStatement {
		return new AssemblyStatement(CountDownBreak, []);
	}

	/**
		Creates a `Jump` statement with a positive argument.
	**/
	public static inline function jump(lengthInBytes: UInt): AssemblyStatement {
		#if debug
		if (lengthInBytes != lengthInBytes & 0xffffffff)
			throw 'Invalid value: $lengthInBytes';
		#end

		return new AssemblyStatement(Jump, [Int(lengthInBytes.int())]);
	}

	/**
		Creates a `Jump` statement with a negative argument.
	**/
	public static inline function jumpBack(lengthInBytes: UInt): AssemblyStatement {
		final jumpBackLength = Opcode.Jump.toStatementType().bytecodeLength();
		final totalBackLength = -jumpBackLength - lengthInBytes.int();

		#if debug
		if (totalBackLength != totalBackLength & 0xffffffff)
			throw 'Invalid value: $lengthInBytes';
		#end

		return new AssemblyStatement(Jump, [Int(totalBackLength)]);
	}

	/**
		Creates a `CountDownJump` statement.
	**/
	public static inline function countDownJump(lengthInBytes: UInt): AssemblyStatement {
		return new AssemblyStatement(CountDownJump, [Int(lengthInBytes.int())]);
	}

	/**
		Creates a `Decrement` statement.
	**/
	public static inline function decrement(): AssemblyStatement {
		return new AssemblyStatement(Decrement, []);
	}

	/**
		Creates a code instance that repeats `body` in runtime.
	**/
	public static function loop(body: AssemblyCode, count: UInt): AssemblyCode {
		final bodyLength = body.bytecodeLength().int();

		return [
			[
				pushInt(count),
				countDownJump(bodyLength + Opcode.Jump.getBytecodeLength())
			],
			body,
			[
				jumpBack(body.bytecodeLength() + Opcode.CountDownJump.getBytecodeLength())
			]
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
		Creates a `Fire` or `FireWithType` statement.
	**/
	public static inline function fire(
		bytecodeId: Int,
		fireType: Int = 0
	): AssemblyStatement {
		return if (fireType == 0) {
			new AssemblyStatement(Fire, [Int(bytecodeId)]);
		} else {
			new AssemblyStatement(FireWithType, [Int(bytecodeId), Int(fireType)]);
		}
	}

	/**
		Creates a `UseThread` statement.
	**/
	public static inline function useThread(bytecodeId: Int): AssemblyStatement {
		return new AssemblyStatement(UseThread, [Int(bytecodeId)]);
	}

	/**
		Creates an `AwaitThread` statement.
	**/
	public static inline function awaitThread(): AssemblyStatement {
		return new AssemblyStatement(AwaitThread, []);
	}

	/**
		Creates an `End` statement.
	**/
	public static inline function end(endCode: Int): AssemblyStatement {
		return new AssemblyStatement(End, [Int(endCode)]);
	}
}
