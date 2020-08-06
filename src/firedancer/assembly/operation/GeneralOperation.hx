package firedancer.assembly.operation;

/**
	Value that specifies a general operation.
**/
@:using(firedancer.assembly.operation.GeneralOperation.GeneralOperationExtension)
enum abstract GeneralOperation(Int) to Int {
	static function error(v: Int): String
		return 'Unknown general operation: $v';

	/**
		Converts `value` to `GeneralOperation`.
		Throws error if `value` does not match any `GeneralOperation` values.
	**/
	public static inline function from(value: Int): GeneralOperation {
		return switch value {
			case GeneralOperation.Break: Break;
			case GeneralOperation.CountDownBreak: CountDownBreak;
			case GeneralOperation.Jump: Jump;
			case GeneralOperation.CountDownJump: CountDownJump;
			case GeneralOperation.UseThread: UseThread;
			case GeneralOperation.UseThreadS: UseThreadS;
			case GeneralOperation.AwaitThread: AwaitThread;
			case GeneralOperation.End: End;
			case GeneralOperation.PushIntC: PushIntC;
			case GeneralOperation.PushIntV: PushIntV;
			case GeneralOperation.PushFloatC: PushFloatC;
			case GeneralOperation.PushFloatV: PushFloatV;
			case GeneralOperation.PeekFloat: PeekFloat;
			case GeneralOperation.DropFloat: DropFloat;
			case GeneralOperation.PeekVec: PeekVec;
			case GeneralOperation.DropVec: DropVec;
			case GeneralOperation.Fire: Fire;
			case GeneralOperation.FireWithType: FireWithType;
			default: throw error(value);
		}
	}

	// ---- control flow --------------------------------------------------------

	/**
		Breaks the current frame.
	**/
	final Break;

	/**
		Peeks the top integer (which should be the remaining loop count) from the stack and checks the value.
		- If `1` or more, decrements the loop counter at the stack top and breaks the current frame.
			The next frame will begin with this `CountDownBreak` opcode again.
		- If `0` or less, drops the loop counter from the stack and goes to next.
	**/
	final CountDownBreak;

	/**
		Adds a given constant value to the current bytecode position.
	**/
	final Jump;

	/**
		Peeks the top integer (which should be the remaining loop count) from the stack and checks the value.
		- If `1` or more, decrements the loop counter at the stack top and goes to next.
		- If `0` or less, drops the loop counter from the stack and
			adds a given constant value to the current bytecode position.
	**/
	final CountDownJump;

	/**
		Activates a new thread with bytecode ID specified by a given constant integer.
	**/
	final UseThread;

	/**
		Activates a new thread with bytecode ID specified by a given constant integer,
		then pushes the thread ID to the stack.
	**/
	final UseThreadS;

	/**
		Peeks the top integer (which should be a thread ID) from the stack
		and checks if the thread is currently active.
		- If active, breaks the current frame.
			The next frame will begin with this `AwaitThread` opcode again.
		- If not active, drops the thread ID from the stack and goes to next.
	**/
	final AwaitThread;

	/**
		Ends running bytecode and returns an end code specified by a given constant integer.
	**/
	final End;

	// ---- read/write stack ----------------------------------------------

	/**
		Pushes a given constant integer to the stack top.
	**/
	final PushIntC;

	/**
		Pushes the current volatile integer to the stack top.
	**/
	final PushIntV;

	/**
		Pushes a given constant float to the stack top.
	**/
	final PushFloatC;

	/**
		Pushes the current volatile float to the stack top.
	**/
	final PushFloatV;

	/**
		Reads a float at the stack top (skipping a given constant bytes from the top)
		and assigns it to the volatile float.
	**/
	final PeekFloat;

	/**
		Drops float from the stack top.
	**/
	final DropFloat;

	/**
		Reads a vector at the stack top (skipping a given constant bytes from the top)
		and assigns it to the volatile vector.
	**/
	final PeekVec;

	/**
		Drops vector from the stack top.
	**/
	final DropVec;

	// ---- other operations ----------------------------------------------------

	/**
		Emits a new actor with a default type.

		Argument:
		- (int) Bytecode ID, or any negative value to emit without bytecode
	**/
	final Fire;

	/**
		Emits a new actor with a specified type.

		Arguments:
		1. (int) Bytecode ID, or any negative value to emit without bytecode
		2. (int) Fire type
	**/
	final FireWithType;

	public extern inline function int(): Int
		return this;
}

class GeneralOperationExtension {
	/**
		@return The mnemonic for `code`.
	**/
	public static inline function toString(code: GeneralOperation): String {
		return switch code {
			case Break: "break";
			case CountDownBreak: "count_down_break";
			case Jump: "jump";
			case CountDownJump: "count_down_jump";
			case UseThread: "use_thread";
			case UseThreadS: "use_thread_s";
			case AwaitThread: "await_thread";
			case End: "end";
			case PushIntC: "push_int_c";
			case PushIntV: "push_int_v";
			case PushFloatC: "push_float_c";
			case PushFloatV: "push_float_v";
			case PeekFloat: "peek_float";
			case DropFloat: "drop_float";
			case PeekVec: "peek_vec";
			case DropVec: "drop_vec";
			case Fire: "fire";
			case FireWithType: "fire_with_type";
		}
	}

	/**
		Creates a `StatementType` instance that corresponds to `op`.
	**/
	public static inline function toStatementType(op: GeneralOperation): StatementType {
		return switch op {
			case Break: [];
			case CountDownBreak: [];
			case Jump: [Int]; // bytecode length to jump
			case CountDownJump: [Int]; // bytecode length to jump
			case UseThread | UseThreadS: [Int]; // bytecode ID
			case AwaitThread: [];
			case End: [Int]; // end code
			case PushIntC: [Int]; // integer to push
			case PushIntV: [];
			case PushFloatC: [Float]; // float to push
			case PushFloatV: [];
			case PeekFloat | PeekVec: [Int]; // bytes to be skipped from the stack top
			case DropFloat | DropVec: [];
			case Fire: [Int]; // bytecode ID or negative for null
			case FireWithType: [Int, Int]; // 1. bytecode ID or negative for null, 2. Fire type
		}
	}

	/**
		@return The bytecode length in bytes required for a statement with `op`.
	**/
	public static inline function getBytecodeLength(op: GeneralOperation): UInt
		return toStatementType(op).bytecodeLength();
}
