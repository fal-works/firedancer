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
			case GeneralOperation.Goto: Goto;
			case GeneralOperation.CountDownGoto: CountDownGoto;
			case GeneralOperation.UseThread: UseThread;
			case GeneralOperation.UseThreadS: UseThreadS;
			case GeneralOperation.AwaitThread: AwaitThread;
			case GeneralOperation.End: End;

			case GeneralOperation.LoadIntCR: LoadIntCR;
			case GeneralOperation.LoadFloatCR: LoadFloatCR;
			case GeneralOperation.LoadVecCR: LoadVecCR;
			case GeneralOperation.SaveIntR: SaveIntR;
			case GeneralOperation.SaveFloatR: SaveFloatR;
			case GeneralOperation.LoadIntVR: LoadIntVR;
			case GeneralOperation.LoadFloatVR: LoadFloatVR;
			case GeneralOperation.StoreIntCV: StoreIntCV;
			case GeneralOperation.StoreIntRV: StoreIntRV;
			case GeneralOperation.StoreFloatCV: StoreFloatCV;
			case GeneralOperation.StoreFloatRV: StoreFloatRV;

			case GeneralOperation.PushIntC: PushIntC;
			case GeneralOperation.PushIntR: PushIntR;
			case GeneralOperation.PushFloatC: PushFloatC;
			case GeneralOperation.PushFloatR: PushFloatR;
			case GeneralOperation.PushVecR: PushVecR;
			case GeneralOperation.PopInt: PopInt;
			case GeneralOperation.PopFloat: PopFloat;
			case GeneralOperation.PeekFloat: PeekFloat;
			case GeneralOperation.DropFloat: DropFloat;
			case GeneralOperation.PeekVec: PeekVec;
			case GeneralOperation.DropVec: DropVec;

			case GeneralOperation.FireSimple: FireSimple;
			case GeneralOperation.FireComplex: FireComplex;
			case GeneralOperation.FireSimpleWithCode: FireSimpleWithCode;
			case GeneralOperation.FireComplexWithCode: FireComplexWithCode;

			case GeneralOperation.GlobalEventR: GlobalEventR;
			case GeneralOperation.LocalEventR: LocalEventR;

			case GeneralOperation.Debug: Debug;

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
		Adds the current program counter to an immediate value.
	**/
	final Goto;

	/**
		Peeks the top integer (which should be the remaining loop count) from the stack and checks the value.
		- If `1` or more, decrements the loop counter at the stack top and goes to next.
		- If `0` or less, drops the loop counter from the stack and
			sets the current program counter to an immediate value.
	**/
	final CountDownGoto;

	/**
		Activates a new thread with program ID specified by an immediate integer.
	**/
	final UseThread;

	/**
		Activates a new thread with program ID specified by an immediate integer,
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
		Ends running program and returns an end code specified by an immediate integer.
	**/
	final End;

	// ---- load values -------------------------------------------------

	/**
		(int immediate) -> (int register)
	**/
	final LoadIntCR;

	/**
		(float immediate) -> (float register)
	**/
	final LoadFloatCR;

	/**
		(vec immediate) -> (vec register)
	**/
	final LoadVecCR;

	/**
		(int immediate) -> (int register buffer)
	**/
	final SaveIntC;

	/**
		(int register) -> (int register buffer)
	**/
	final SaveIntR;

	/**
		(float immediate) -> (float register buffer)
	**/
	final SaveFloatC;

	/**
		(float register) -> (float register buffer)
	**/
	final SaveFloatR;

	/**
		(int var) -> (int register)

		where the variable address is specified by (int immediate)
	**/
	final LoadIntVR;

	/**
		(float var) -> (float register)

		where the variable address is specified by (int immediate)
	**/
	final LoadFloatVR;

	/**
		(2nd, int immediate) -> (int var)

		where the variable address is specified by (1st, int immediate)
	**/
	final StoreIntCV;

	/**
		(int register) -> (int var)

		where the variable address is specified by (int immediate)
	**/
	final StoreIntRV;

	/**
		(2nd, float immediate) -> (float var)

		where the variable address is specified by (1st, int immediate)
	**/
	final StoreFloatCV;

	/**
		(float register) -> (float var)

		where the variable address is specified by (int immediate)
	**/
	final StoreFloatRV;

	// ---- read/write stack ----------------------------------------------

	/**
		Push (int immediate) -> (stack)
	**/
	final PushIntC;

	/**
		Push (int register) -> (stack)
	**/
	final PushIntR;

	/**
		Push (float immediate) -> (stack)
	**/
	final PushFloatC;

	/**
		Push (float register) -> (stack)
	**/
	final PushFloatR;

	/**
		Push (vec register) -> (stack)
	**/
	final PushVecR;

	/**
		Pop (stack) -> (int register)
	**/
	final PopInt;

	/**
		Pop (stack) -> (float register)
	**/
	final PopFloat;

	/**
		Peek (stack) -> (float register)

		skipping (int immediate) bytes from the stack top
	**/
	final PeekFloat;

	/**
		Drop float from (stack)
	**/
	final DropFloat;

	/**
		Peek (stack) -> (vec register)

		skipping (int immediate) bytes from the stack top
	**/
	final PeekVec;

	/**
		Drop vec from (stack)
	**/
	final DropVec;

	// ---- fire ----------------------------------------------------

	/**
		Emits a new actor with a default type, without program and
		without binding the position.
	**/
	final FireSimple;

	/**
		Emits a new actor with a default type.

		Argument:
		- (int immediate) `FireArgument` value
	**/
	final FireComplex;

	/**
		Emits a new actor with a specified type, without program and
		without binding the position.

		Argument:
		- (int immediate) Fire code
	**/
	final FireSimpleWithCode;

	/**
		Emits a new actor with a specified type.

		Arguments:
		1. (int immediate) `FireArgument` value
		2. (int immediate) Fire code
	**/
	final FireComplexWithCode;

	// ---- other ----------------------------------------------------

	/**
		Invokes a global event with an user-defined code
		specified by (int register).
	**/
	final GlobalEventR;

	/**
		Invokes a global event with an user-defined code
		specified by (int register).
	**/
	final LocalEventR;

	/**
		Runs debug process specified by (immediate integer).
	**/
	final Debug;

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
			case Goto: "goto";
			case CountDownGoto: "count_down_goto";
			case UseThread: "use_thread";
			case UseThreadS: "use_thread_s";
			case AwaitThread: "await_thread";
			case End: "end";

			case LoadIntCR: "load_int_cr";
			case LoadFloatCR: "load_float_cr";
			case LoadVecCR: "load_vec_cr";
			case SaveIntC: "save_int_c";
			case SaveIntR: "save_int_r";
			case SaveFloatC: "save_float_c";
			case SaveFloatR: "save_float_r";
			case LoadIntVR: "load_int_vr";
			case LoadFloatVR: "load_float_vr";
			case StoreIntCV: "store_int_cv";
			case StoreIntRV: "store_int_rv";
			case StoreFloatCV: "store_float_cv";
			case StoreFloatRV: "store_float_rv";

			case PushIntC: "push_int_c";
			case PushIntR: "push_int_r";
			case PushFloatC: "push_float_c";
			case PushFloatR: "push_float_r";
			case PushVecR: "push_Vec_r";
			case PopInt: "pop_int";
			case PopFloat: "pop_float";
			case PeekFloat: "peek_float";
			case DropFloat: "drop_float";
			case PeekVec: "peek_vec";
			case DropVec: "drop_vec";

			case FireSimple: "fire_simple";
			case FireComplex: "fire_complex";
			case FireSimpleWithCode: "fire_simple_with_type";
			case FireComplexWithCode: "fire_complex_with_type";

			case GlobalEventR: "global_event";
			case LocalEventR: "local_event";

			case Debug: "debug";
		}
	}
}
