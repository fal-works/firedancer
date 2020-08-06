package firedancer.assembly.operation;

/**
	Value that specifies a calc operation.
**/
@:using(firedancer.assembly.operation.CalcOperation.CalcOperationExtension)
enum abstract CalcOperation(Int) to Int {
	static function error(v: Int): String
		return 'Unknown calc operation: $v';

	/**
		Converts `value` to `CalcOperation`.
		Throws error if `value` does not match any `CalcOperation` values.
	**/
	public static inline function from(value: Int): CalcOperation {
		return switch value {
			case CalcOperation.LoadFloatCV: LoadFloatCV;
			case CalcOperation.LoadVecCV: LoadVecCV;
			case CalcOperation.AddFloatVCV: AddFloatVCV;
			case CalcOperation.AddFloatVVV: AddFloatVVV;
			case CalcOperation.SubFloatVCV: SubFloatVCV;
			case CalcOperation.SubFloatCVV: SubFloatCVV;
			case CalcOperation.SubFloatVVV: SubFloatVVV;
			case CalcOperation.MinusFloatV: MinusFloatV;
			case CalcOperation.MultFloatVCV: MultFloatVCV;
			case CalcOperation.MultFloatVVV: MultFloatVVV;
			case CalcOperation.MultFloatVCS: MultFloatVCS;
			case CalcOperation.DivFloatCVV: DivFloatCVV;
			case CalcOperation.DivFloatVVV: DivFloatVVV;
			case CalcOperation.ModFloatVCV: ModFloatVCV;
			case CalcOperation.ModFloatCVV: ModFloatCVV;
			case CalcOperation.ModFloatVVV: ModFloatVVV;
			case CalcOperation.MinusVecV: MinusVecV;
			case CalcOperation.MultVecVCS: MultVecVCS;
			case CalcOperation.SaveFloatV: SaveFloatV;
			case CalcOperation.CastCartesianVV: CastCartesianVV;
			case CalcOperation.CastPolarVV: CastPolarVV;
			case CalcOperation.RandomFloatCV: RandomFloatCV;
			case CalcOperation.RandomFloatVV: RandomFloatVV;
			case CalcOperation.RandomFloatSignedCV: RandomFloatSignedCV;
			case CalcOperation.RandomFloatSignedVV: RandomFloatSignedVV;
			default: throw error(value);
		}
	}


	// ---- calc values ----------------------------------------------

	/**
		Assigns a given constant float to the current volatile float.
	**/
	final LoadFloatCV;

	/**
		Assigns given constant float values to the current volatile vector.
	**/
	final LoadVecCV;

	/**
		Adds a given constant float to the current volatile float.
	**/
	final AddFloatVCV;

	/**
		Adds the last saved volatile float to the current volatile float.
	**/
	final AddFloatVVV;

	/**
		Subtracts a given constant float from the current volatile float.
	**/
	final SubFloatVCV;

	/**
		Subtracts the current volatile float from a given constant float and assigns it to the volatile float.
	**/
	final SubFloatCVV;

	/**
		Subtracts the current volatile float from the last saved volatile float and assigns it to the volatile float.
	**/
	final SubFloatVVV;

	/**
		Changes the sign of the current volatile float.
	**/
	final MinusFloatV;

	/**
		Multiplies the current volatile float by a given constant float.
	**/
	final MultFloatVCV;

	/**
		Multiplies the last saved volatile float and the current volatile float, and reassigns it to the volatile float.
	**/
	final MultFloatVVV;

	/**
		Multiplicates the current volatile float by a given constant float and pushes it to the stack top.
	**/
	final MultFloatVCS;

	/**
		Divides a given constant float by the current volatile float and reassigns it to the volatile float.
	**/
	final DivFloatCVV;

	/**
		Divides the last saved volatile float by the current volatile float, and reassigns it to the volatile float.
	**/
	final DivFloatVVV;

	/**
		Divides the current volatile float by a given constant float and assigns the modulo to the volatile float.
	**/
	final ModFloatVCV;

	/**
		Divides a given constant float by the current volatile float and assigns the modulo to the volatile float.
	**/
	final ModFloatCVV;

	/**
		Divides the last saved volatile float by the current volatile float, and assigns the modulo to the volatile float.
	**/
	final ModFloatVVV;

	/**
		Changes the sign of the current volatile vector.
	**/
	final MinusVecV;

	/**
		Multiplicates the current volatile vector by a given constant float and pushes it to the stack top.
	**/
	final MultVecVCS;

	/**
		Saves the current volatile float.
	**/
	final SaveFloatV;

	/**
		Interprets the last saved volatile float as `x` and the current volatile float as `y`,
		and assigns them to the volatile vector.
	**/
	final CastCartesianVV;

	/**
		Interprets the last saved volatile float as `length` and the current volatile float as `angle`,
		and assigns their cartesian representation to the volatile vector.
	**/
	final CastPolarVV;

	/**
		Multiplies the given constant float by a random value in range `[0, 1)`
		and assigns it to the volatile float.
	**/
	final RandomFloatCV;

	/**
		Multiplies the current volatile float by a random value in range `[0, 1)`
		and reassigns it to the volatile float.
	**/
	final RandomFloatVV;

	/**
		Multiplies the given constant float by a random value in range `[-1, 1)`
		and assigns it to the volatile float.
	**/
	final RandomFloatSignedCV;

	/**
		Multiplies the current volatile float by a random value in range `[-1, 1)`
		and reassigns it to the volatile float.
	**/
	final RandomFloatSignedVV;


	public extern inline function int(): Int
		return this;
}

class CalcOperationExtension {
	/**
		@return The mnemonic for `code`.
	**/
	public static inline function toString(code: CalcOperation): String {
		return switch code {
			case LoadFloatCV: "load_float_cv";
			case LoadVecCV: "load_vec_cv";
			case AddFloatVCV: "add_float_vcv";
			case AddFloatVVV: "add_float_vvv";
			case SubFloatVCV: "sub_float_vcv";
			case SubFloatCVV: "sub_float_cvv";
			case SubFloatVVV: "sub_float_vvv";
			case MinusFloatV: "minus_float_v";
			case MultFloatVCV: "mult_float_vcv";
			case MultFloatVVV: "mult_float_vvv";
			case MultFloatVCS: "mult_float_vcs";
			case ModFloatVCV: "mod_float_vcv";
			case ModFloatCVV: "mod_float_cvv";
			case ModFloatVVV: "mod_float_vvv";
			case DivFloatCVV: "div_float_cvv";
			case DivFloatVVV: "div_float_vvv";
			case MinusVecV: "minus_vec_v";
			case MultVecVCS: "mult_vec_vcs";
			case SaveFloatV: "save_float_v";
			case CastCartesianVV: "cast_cartesian_vv";
			case CastPolarVV: "cast_polar_vv";
			case RandomFloatCV: "random_float_cv";
			case RandomFloatVV: "random_float_vv";
			case RandomFloatSignedCV: "random_float_signed_cv";
			case RandomFloatSignedVV: "random_float_signed_vv";
		}
	}

	/**
		Creates a `StatementType` instance that corresponds to `op`.
	**/
	public static inline function toStatementType(op: CalcOperation): StatementType {
		return switch op {
			case LoadFloatCV: [Float];
			case LoadVecCV: [Vec];
			case AddFloatVCV: [Float]; // value to add
			case AddFloatVVV: [];
			case SubFloatVCV: [Float]; // value to subtract
			case SubFloatCVV: [Float]; // value from which to subtract
			case SubFloatVVV: [];
			case MinusFloatV: [];
			case MultFloatVVV: [];
			case MultFloatVCV | MultFloatVCS: [Float]; // multiplier value
			case ModFloatVCV: [Float]; // divisor
			case ModFloatCVV: [Float]; // value to be divided
			case ModFloatVVV: [];
			case DivFloatCVV: [Float]; // value to be divided
			case DivFloatVVV: [];
			case MinusVecV: [];
			case MultVecVCS: [Float]; // multiplier value
			case SaveFloatV: [];
			case CastCartesianVV | CastPolarVV: [];
			case RandomFloatCV: [Float];
			case RandomFloatVV: [];
			case RandomFloatSignedCV: [Float];
			case RandomFloatSignedVV: [];
		}
	}

	/**
		@return The bytecode length in bytes required for a statement with `op`.
	**/
	public static inline function getBytecodeLength(op: CalcOperation): UInt
		return toStatementType(op).bytecodeLength();
}
