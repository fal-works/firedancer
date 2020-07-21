package firedancer.assembly;

/**
	Functions for creating `AssemblyStatement` instances.
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
		Creates a `SetPositionConst` statement.
	**/
	public static inline function setPositionConst(x: Float, y: Float): AssemblyStatement {
		return new AssemblyStatement(SetPositionConst, [Vec(x, y)]);
	}

	/**
		Creates an `AddPositionConst` statement.
	**/
	public static inline function addPositionConst(x: Float, y: Float): AssemblyStatement {
		return new AssemblyStatement(AddPositionConst, [Vec(x, y)]);
	}

	/**
		Creates a `SetVelocityConst` statement.
	**/
	public static inline function setVelocityConst(
		vx: Float,
		vy: Float
	): AssemblyStatement {
		return new AssemblyStatement(SetVelocityConst, [Vec(vx, vy)]);
	}

	/**
		Creates an `AddVelocityConst` statement.
	**/
	public static inline function addVelocityConst(
		vx: Float,
		vy: Float
	): AssemblyStatement {
		return new AssemblyStatement(AddVelocityConst, [Vec(vx, vy)]);
	}
}
