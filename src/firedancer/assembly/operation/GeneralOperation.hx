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

			case GeneralOperation.LoadIntCV: LoadIntCV;
			case GeneralOperation.LoadFloatCV: LoadFloatCV;
			case GeneralOperation.LoadVecCV: LoadVecCV;
			case GeneralOperation.SaveIntV: SaveIntV;
			case GeneralOperation.SaveFloatV: SaveFloatV;
			case GeneralOperation.LoadIntLV: LoadIntLV;
			case GeneralOperation.LoadFloatLV: LoadFloatLV;
			case GeneralOperation.StoreIntCL: StoreIntCL;
			case GeneralOperation.StoreIntVL: StoreIntVL;
			case GeneralOperation.StoreFloatCL: StoreFloatCL;
			case GeneralOperation.StoreFloatVL: StoreFloatVL;

			case GeneralOperation.PushIntC: PushIntC;
			case GeneralOperation.PushIntV: PushIntV;
			case GeneralOperation.PushFloatC: PushFloatC;
			case GeneralOperation.PushFloatV: PushFloatV;
			case GeneralOperation.PushVecV: PushVecV;
			case GeneralOperation.PeekFloat: PeekFloat;
			case GeneralOperation.DropFloat: DropFloat;
			case GeneralOperation.PeekVec: PeekVec;
			case GeneralOperation.DropVec: DropVec;

			case GeneralOperation.FireSimple: FireSimple;
			case GeneralOperation.FireComplex: FireComplex;
			case GeneralOperation.FireSimpleWithType: FireSimpleWithType;
			case GeneralOperation.FireComplexWithType: FireComplexWithType;

			case GeneralOperation.GlobalEvent: GlobalEvent;
			case GeneralOperation.LocalEvent: LocalEvent;

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

	// ---- load values -------------------------------------------------

	/**
		Assigns a given constant integer to the current volatile integer.
	**/
	final LoadIntCV;

	/**
		Assigns a given constant float to the current volatile float.
	**/
	final LoadFloatCV;

	/**
		Assigns given constant float values to the current volatile vector.
	**/
	final LoadVecCV;

	/**
		Saves the current volatile integer.
	**/
	final SaveIntV;

	/**
		Saves the current volatile float.
	**/
	final SaveFloatV;

	/**
		Assigns the local variable value (of which the address is specified
		by a given constant integer) to the volatile integer.
	**/
	final LoadIntLV;

	/**
		Assigns the local variable value (of which the address is specified
		by a given constant integer) to the volatile float.
	**/
	final LoadFloatLV;

	/**
		Assigns the second constant integer to the local variable
		(of which the address is specified by the first constant integer).
	**/
	final StoreIntCL;

	/**
		Assigns the current volatile integer to the local variable
		(of which the address is specified by a given constant integer).
	**/
	final StoreIntVL;

	/**
		Assigns a given constant float to the local variable
		(of which the address is specified by a given constant integer).
	**/
	final StoreFloatCL;

	/**
		Assigns the current volatile float to the local variable
		(of which the address is specified by a given constant integer).
	**/
	final StoreFloatVL;

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
		Pushes the current volatile vector to the stack top.
	**/
	final PushVecV;

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

	// ---- fire ----------------------------------------------------

	/**
		Emits a new actor with a default type, without bytecode and
		without binding the position.
	**/
	final FireSimple;

	/**
		Emits a new actor with a default type.

		Argument:
		- (int) `FireArgument` value
	**/
	final FireComplex;

	/**
		Emits a new actor with a specified type, without bytecode and
		without binding the position.

		Argument:
		- (int) Fire type
	**/
	final FireSimpleWithType;

	/**
		Emits a new actor with a specified type.

		Arguments:
		1. (int) `FireArgument` value
		2. (int) Fire type
	**/
	final FireComplexWithType;

	// ---- other ----------------------------------------------------

	/**
		Invokes a global event with an user-defined code
		specified by the current volatile integer.
	**/
	final GlobalEvent;

	/**
		Invokes a global event with an user-defined code
		specified by the current volatile integer.
	**/
	final LocalEvent;

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

			case LoadIntCV: "load_int_cv";
			case LoadFloatCV: "load_float_cv";
			case LoadVecCV: "load_vec_cv";
			case SaveIntV: "save_int_v";
			case SaveFloatV: "save_float_v";
			case LoadIntLV: "load_int_lv";
			case LoadFloatLV: "load_float_lv";
			case StoreIntCL: "store_int_cl";
			case StoreIntVL: "store_int_vl";
			case StoreFloatCL: "store_float_cl";
			case StoreFloatVL: "store_float_vl";

			case PushIntC: "push_int_c";
			case PushIntV: "push_int_v";
			case PushFloatC: "push_float_c";
			case PushFloatV: "push_float_v";
			case PushVecV: "push_vec_v";
			case PeekFloat: "peek_float";
			case DropFloat: "drop_float";
			case PeekVec: "peek_vec";
			case DropVec: "drop_vec";

			case FireSimple: "fire_simple";
			case FireComplex: "fire_complex";
			case FireSimpleWithType: "fire_simple_with_type";
			case FireComplexWithType: "fire_complex_with_type";

			case GlobalEvent: "global_event";
			case LocalEvent: "local_event";
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

			case LoadIntCV: [Int];
			case LoadFloatCV: [Float];
			case LoadVecCV: [Vec];
			case SaveIntV: [];
			case SaveFloatV: [];
			case LoadIntLV: [Int]; // address
			case LoadFloatLV: [Int]; // address
			case StoreIntCL: [Int, Int]; // address, value
			case StoreIntVL: [Int]; // address
			case StoreFloatCL: [Int, Float]; // address, value
			case StoreFloatVL: [Int]; // address

			case PushIntC: [Int]; // integer to push
			case PushIntV: [];
			case PushFloatC: [Float]; // float to push
			case PushFloatV: [];
			case PushVecV: [];
			case PeekFloat | PeekVec: [Int]; // bytes to be skipped from the stack top
			case DropFloat | DropVec: [];

			case FireSimple: [];
			case FireComplex: [Int]; // FireArgument value
			case FireSimpleWithType: [Int]; // fire type
			case FireComplexWithType: [Int, Int]; // 1. FireArgument value, 2. fire type

			case GlobalEvent: [];
			case LocalEvent: [];
		}
	}

	/**
		@return The bytecode length in bytes required for a statement with `op`.
	**/
	public static inline function getBytecodeLength(op: GeneralOperation): UInt
		return toStatementType(op).bytecodeLength();
}
