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
		Creates a `CountDown` statement.
	**/
	public static inline function countDown(): AssemblyStatement {
		return new AssemblyStatement(CountDown, []);
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
		Creates a statement with `opcode`.
	**/
	public static inline function operateVectorConst(
		opcode: Opcode.OperateVectorConstOpcode,
		x: Float,
		y: Float
	): AssemblyStatement {
		return new AssemblyStatement(opcode, [Vec(x, y)]);
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
	public static function loopInlined(
		bodyFactory: (index: UInt) -> AssemblyCode,
		count: UInt
	): AssemblyCode {
		return [for (i in 0...count) bodyFactory(i)].flatten();
	}
}
