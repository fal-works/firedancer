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
	public static inline function operateVectorC(
		opcode: Opcode.OpcodeOperateVectorC,
		x: Float,
		y: Float
	): AssemblyStatement {
		return new AssemblyStatement(opcode, [Vec(x, y)]);
	}

	/**
		Creates a statement with `opcode`.
	**/
	public static inline function operateVectorS(
		opcode: Opcode.OpcodeOperateVectorS
	): AssemblyStatement {
		return new AssemblyStatement(opcode, []);
	}

	/**
		Creates a statement with `opcode`.
	**/
	public static inline function operateVectorV(
		opcode: Opcode.OpcodeOperateVectorV
	): AssemblyStatement {
		return new AssemblyStatement(opcode, []);
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

	/**
		Creates a `CalcRelativePositionCV` statement.
	**/
	public static inline function calcRelativePositionCV(x: Float, y: Float): AssemblyStatement {
		return new AssemblyStatement(CalcRelativePositionCV, [Vec(x, y)]);
	}

	/**
		Creates a `CalcRelativeVelocityCV` statement.
	**/
	public static inline function calcRelativeVelocityCV(x: Float, y: Float): AssemblyStatement {
		return new AssemblyStatement(CalcRelativeVelocityCV, [Vec(x, y)]);
	}

	public static inline function multVecVCS(multiplier: Float): AssemblyStatement {
		return new AssemblyStatement(MultVecVCS, [Float(multiplier)]);
	}
}
