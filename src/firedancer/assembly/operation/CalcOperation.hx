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
			case CalcOperation.AddIntVCV: AddIntVCV;
			case CalcOperation.AddIntVVV: AddIntVVV;
			case CalcOperation.SubIntVCV: SubIntVCV;
			case CalcOperation.SubIntCVV: SubIntCVV;
			case CalcOperation.SubIntVVV: SubIntVVV;
			case CalcOperation.MinusIntV: MinusIntV;
			case CalcOperation.MultIntVCV: MultIntVCV;
			case CalcOperation.MultIntVVV: MultIntVVV;
			case CalcOperation.DivIntVCV: DivIntVCV;
			case CalcOperation.DivIntCVV: DivIntCVV;
			case CalcOperation.DivIntVVV: DivIntVVV;
			case CalcOperation.ModIntVCV: ModIntVCV;
			case CalcOperation.ModIntCVV: ModIntCVV;
			case CalcOperation.ModIntVVV: ModIntVVV;

			case CalcOperation.AddFloatVCV: AddFloatVCV;
			case CalcOperation.AddFloatVVV: AddFloatVVV;
			case CalcOperation.SubFloatVCV: SubFloatVCV;
			case CalcOperation.SubFloatCVV: SubFloatCVV;
			case CalcOperation.SubFloatVVV: SubFloatVVV;
			case CalcOperation.MinusFloatV: MinusFloatV;
			case CalcOperation.MultFloatVCV: MultFloatVCV;
			case CalcOperation.MultFloatVVV: MultFloatVVV;
			case CalcOperation.DivFloatCVV: DivFloatCVV;
			case CalcOperation.DivFloatVVV: DivFloatVVV;
			case CalcOperation.ModFloatVCV: ModFloatVCV;
			case CalcOperation.ModFloatCVV: ModFloatCVV;
			case CalcOperation.ModFloatVVV: ModFloatVVV;

			case CalcOperation.MinusVecV: MinusVecV;
			case CalcOperation.MultVecVCV: MultVecVCV;
			case CalcOperation.MultVecVVV: MultVecVVV;
			case CalcOperation.DivVecVVV: DivVecVVV;

			case CalcOperation.CastIntToFloatVV: CastIntToFloatVV;
			case CalcOperation.CastCartesianVV: CastCartesianVV;
			case CalcOperation.CastPolarVV: CastPolarVV;

			case CalcOperation.RandomRatioV: RandomRatioV;
			case CalcOperation.RandomFloatCV: RandomFloatCV;
			case CalcOperation.RandomFloatVV: RandomFloatVV;
			case CalcOperation.RandomFloatSignedCV: RandomFloatSignedCV;
			case CalcOperation.RandomFloatSignedVV: RandomFloatSignedVV;
			case CalcOperation.RandomIntCV: RandomIntCV;
			case CalcOperation.RandomIntVV: RandomIntVV;
			case CalcOperation.RandomIntSignedCV: RandomIntSignedCV;
			case CalcOperation.RandomIntSignedVV: RandomIntSignedVV;
			case CalcOperation.AddIntLCL: AddIntLCL;
			case CalcOperation.AddIntLVL: AddIntLVL;
			case CalcOperation.IncrementL: IncrementL;
			case CalcOperation.DecrementL: DecrementL;
			case CalcOperation.AddFloatLCL: AddFloatLCL;
			case CalcOperation.AddFloatLVL: AddFloatLVL;

			default: throw error(value);
		}
	}

	// ---- calc values ----------------------------------------------

	/**
		Adds a given constant integer to the current volatile integer.
	**/
	final AddIntVCV;

	/**
		Adds the last saved volatile integer to the current volatile integer.
	**/
	final AddIntVVV;

	/**
		Subtracts a given constant integer from the current volatile integer.
	**/
	final SubIntVCV;

	/**
		Subtracts the current volatile integer from a given constant integer and assigns it to the volatile integer.
	**/
	final SubIntCVV;

	/**
		Subtracts the current volatile integer from the last saved volatile integer and assigns it to the volatile integer.
	**/
	final SubIntVVV;

	/**
		Changes the sign of the current volatile integer.
	**/
	final MinusIntV;

	/**
		Multiplies the current volatile integer by a given constant integer.
	**/
	final MultIntVCV;

	/**
		Multiplies the last saved volatile integer and the current volatile integer, and reassigns it to the volatile integer.
	**/
	final MultIntVVV;

	/**
		Divides the current volatile integer by a given constant integer.
	**/
	final DivIntVCV;

	/**
		Divides a given constant integer by the current volatile integer and reassigns it to the volatile integer.
	**/
	final DivIntCVV;

	/**
		Divides the last saved volatile integer by the current volatile integer, and reassigns it to the volatile integer.
	**/
	final DivIntVVV;

	/**
		Divides the current volatile integer by a given constant integer and assigns the modulo to the volatile integer.
	**/
	final ModIntVCV;

	/**
		Divides a given constant integer by the current volatile integer and assigns the modulo to the volatile integer.
	**/
	final ModIntCVV;

	/**
		Divides the last saved volatile integer by the current volatile integer, and assigns the modulo to the volatile integer.
	**/
	final ModIntVVV;

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
		Multiplicates the current volatile vector by a given constant float.
	**/
	final MultVecVCV;

	/**
		Multiplicates the current volatile vector by the current volatile float.
	**/
	final MultVecVVV;

	/**
		Divides the current volatile vector by the current volatile float.
	**/
	final DivVecVVV;

	/**
		Casts the current volatile integer to a float and assigns it to the volatile float.
	**/
	final CastIntToFloatVV;

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
		Assigns a random value in rante `[0, 1)` to the volatile float.
	**/
	final RandomRatioV;

	/**
		Generates a random float from `0` up to (but not including) the given constant float
		and assigns it to the volatile float.
	**/
	final RandomFloatCV;

	/**
		Generates a random float from `0` up to (but not including) the current volatile float
		and assigns it to the volatile float.
	**/
	final RandomFloatVV;

	/**
		Generates a random float, positive or negative, of which the absolute value varies
		from `0` up to (but not including) the given constant float.
		Then assigns it to the volatile float.
	**/
	final RandomFloatSignedCV;

	/**
		Generates a random float, positive or negative, of which the absolute value varies
		from `0` up to (but not including) the current volatile float.
		Then assigns it to the volatile float.
	**/
	final RandomFloatSignedVV;

	/**
		Generates a random integer from `0` up to (but not including) the given constant integer
		and assigns it to the volatile integer.
	**/
	final RandomIntCV;

	/**
		Generates a random integer from `0` up to (but not including) the current volatile integer
		and assigns it to the volatile integer.
	**/
	final RandomIntVV;

	/**
		Generates a random integer, positive or negative, of which the absolute value varies
		from `0` up to (but not including) the given constant integer.
		Then assigns it to the volatile integer.
	**/
	final RandomIntSignedCV;

	/**
		Generates a random integer, positive or negative, of which the absolute value varies
		from `0` up to (but not including) the current volatile integer.
		Then assigns it to the volatile integer.
	**/
	final RandomIntSignedVV;

	/**
		Adds the second constant integer to the local variable
		(of which the address is specified by the first constant integer).
	**/
	final AddIntLCL;

	/**
		Adds the current volatile integer to the local variable
		(of which the address is specified by a given constant integer).
	**/
	final AddIntLVL;

	/**
		Increments the local variable of which the address is specified by the first constant integer.
	**/
	final IncrementL;

	/**
		Decrements the local variable of which the address is specified by the first constant integer.
	**/
	final DecrementL;

	/**
		Adds a given constant float to the local variable
		(of which the address is specified by a given constant integer).
	**/
	final AddFloatLCL;

	/**
		Adds the current volatile float to the local variable
		(of which the address is specified by a given constant integer).
	**/
	final AddFloatLVL;

	public extern inline function int(): Int
		return this;
}

class CalcOperationExtension {
	/**
		@return The mnemonic for `code`.
	**/
	public static inline function toString(code: CalcOperation): String {
		return switch code {
			case AddIntVCV: "add_int_vcv";
			case AddIntVVV: "add_int_vvv";
			case SubIntVCV: "sub_int_vcv";
			case SubIntCVV: "sub_int_cvv";
			case SubIntVVV: "sub_int_vvv";
			case MinusIntV: "minus_int_v";
			case MultIntVCV: "mult_int_vcv";
			case MultIntVVV: "mult_int_vvv";
			case ModIntVCV: "mod_int_vcv";
			case ModIntCVV: "mod_int_cvv";
			case ModIntVVV: "mod_int_vvv";
			case DivIntVCV: "div_int_vcv";
			case DivIntCVV: "div_int_cvv";
			case DivIntVVV: "div_int_vvv";

			case AddFloatVCV: "add_float_vcv";
			case AddFloatVVV: "add_float_vvv";
			case SubFloatVCV: "sub_float_vcv";
			case SubFloatCVV: "sub_float_cvv";
			case SubFloatVVV: "sub_float_vvv";
			case MinusFloatV: "minus_float_v";
			case MultFloatVCV: "mult_float_vcv";
			case MultFloatVVV: "mult_float_vvv";
			case ModFloatVCV: "mod_float_vcv";
			case ModFloatCVV: "mod_float_cvv";
			case ModFloatVVV: "mod_float_vvv";
			case DivFloatCVV: "div_float_cvv";
			case DivFloatVVV: "div_float_vvv";

			case MinusVecV: "minus_vec_v";
			case MultVecVCV: "mult_vec_vcv";
			case MultVecVVV: "mult_vec_vvv";
			case DivVecVVV: "div_vec_vvv";

			case CastIntToFloatVV: "cast_int_to_float_vv";
			case CastCartesianVV: "cast_cartesian_vv";
			case CastPolarVV: "cast_polar_vv";

			case RandomRatioV: "random_ratio_v";
			case RandomFloatCV: "random_float_cv";
			case RandomFloatVV: "random_float_vv";
			case RandomFloatSignedCV: "random_float_signed_cv";
			case RandomFloatSignedVV: "random_float_signed_vv";
			case RandomIntCV: "random_int_cv";
			case RandomIntVV: "random_int_vv";
			case RandomIntSignedCV: "random_int_signed_cv";
			case RandomIntSignedVV: "random_int_signed_vv";

			case AddIntLCL: "add_int_lcl";
			case AddIntLVL: "add_int_lvl";
			case IncrementL: "increment_l";
			case DecrementL: "decrement_l";
			case AddFloatLCL: "add_float_lcl";
			case AddFloatLVL: "add_float_lvl";
		}
	}

	/**
		Creates a `InstructionType` instance that corresponds to `op`.
	**/
	public static inline function toInstructionType(op: CalcOperation): InstructionType {
		return switch op {
			case AddIntVCV: [Int]; // value to add
			case AddIntVVV: [];
			case SubIntVCV: [Int]; // value to subtract
			case SubIntCVV: [Int]; // value from which to subtract
			case SubIntVVV: [];
			case MinusIntV: [];
			case MultIntVVV: [];
			case MultIntVCV: [Int]; // multiplier value
			case ModIntVCV: [Int]; // divisor
			case ModIntCVV: [Int]; // value to be divided
			case ModIntVVV: [];
			case DivIntVCV: [Int]; // divisor value
			case DivIntCVV: [Int]; // value to be divided
			case DivIntVVV: [];

			case AddFloatVCV: [Float]; // value to add
			case AddFloatVVV: [];
			case SubFloatVCV: [Float]; // value to subtract
			case SubFloatCVV: [Float]; // value from which to subtract
			case SubFloatVVV: [];
			case MinusFloatV: [];
			case MultFloatVVV: [];
			case MultFloatVCV: [Float]; // multiplier value
			case ModFloatVCV: [Float]; // divisor
			case ModFloatCVV: [Float]; // value to be divided
			case ModFloatVVV: [];
			case DivFloatCVV: [Float]; // value to be divided
			case DivFloatVVV: [];

			case MinusVecV: [];
			case MultVecVCV: [Float]; // multiplier value
			case MultVecVVV: [];
			case DivVecVVV: [];

			case CastIntToFloatVV | CastCartesianVV | CastPolarVV: [];

			case RandomRatioV: [];
			case RandomFloatCV: [Float];
			case RandomFloatVV: [];
			case RandomFloatSignedCV: [Float];
			case RandomFloatSignedVV: [];
			case RandomIntCV: [Int];
			case RandomIntVV: [];
			case RandomIntSignedCV: [Int];
			case RandomIntSignedVV: [];

			case AddIntLCL: [Int, Int]; // address, value to add
			case AddIntLVL: [Int]; // address
			case IncrementL: [Int]; // address
			case DecrementL: [Int]; // address
			case AddFloatLCL: [Int, Float]; // address, value to add
			case AddFloatLVL: [Int]; // address
		}
	}

	/**
		@return The bytecode length in bytes required for an instruction with `op`.
	**/
	public static inline function getBytecodeLength(op: CalcOperation): UInt
		return toInstructionType(op).bytecodeLength();
}
