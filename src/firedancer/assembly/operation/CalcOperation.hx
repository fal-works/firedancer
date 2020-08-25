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
		case CalcOperation.AddIntRCR: AddIntRCR;
		case CalcOperation.AddIntRRR: AddIntRRR;
		case CalcOperation.SubIntRCR: SubIntRCR;
		case CalcOperation.SubIntCRR: SubIntCRR;
		case CalcOperation.SubIntRRR: SubIntRRR;
		case CalcOperation.MinusIntRR: MinusIntRR;
		case CalcOperation.MultIntRCR: MultIntRCR;
		case CalcOperation.MultIntRRR: MultIntRRR;
		case CalcOperation.DivIntRCR: DivIntRCR;
		case CalcOperation.DivIntCRR: DivIntCRR;
		case CalcOperation.DivIntRRR: DivIntRRR;
		case CalcOperation.ModIntRCR: ModIntRCR;
		case CalcOperation.ModIntCRR: ModIntCRR;
		case CalcOperation.ModIntRRR: ModIntRRR;

		case CalcOperation.AddFloatRCR: AddFloatRCR;
		case CalcOperation.AddFloatRRR: AddFloatRRR;
		case CalcOperation.SubFloatRCR: SubFloatRCR;
		case CalcOperation.SubFloatCRR: SubFloatCRR;
		case CalcOperation.SubFloatRRR: SubFloatRRR;
		case CalcOperation.MinusFloatRR: MinusFloatRR;
		case CalcOperation.MultFloatRCR: MultFloatRCR;
		case CalcOperation.MultFloatRRR: MultFloatRRR;
		case CalcOperation.DivFloatRCR: DivFloatRCR;
		case CalcOperation.DivFloatCRR: DivFloatCRR;
		case CalcOperation.DivFloatRRR: DivFloatRRR;
		case CalcOperation.ModFloatRCR: ModFloatRCR;
		case CalcOperation.ModFloatCRR: ModFloatCRR;
		case CalcOperation.ModFloatRRR: ModFloatRRR;

		case CalcOperation.MinusVecRR: MinusVecRR;
		case CalcOperation.MultVecRCR: MultVecRCR;
		case CalcOperation.MultVecRRR: MultVecRRR;
		case CalcOperation.DivVecRRR: DivVecRRR;

		case CalcOperation.CastIntToFloatRR: CastIntToFloatRR;
		case CalcOperation.CastCartesianRR: CastCartesianRR;
		case CalcOperation.CastPolarRR: CastPolarRR;

		case CalcOperation.RandomRatioR: RandomRatioR;
		case CalcOperation.RandomFloatCR: RandomFloatCR;
		case CalcOperation.RandomFloatRR: RandomFloatRR;
		case CalcOperation.RandomFloatSignedCR: RandomFloatSignedCR;
		case CalcOperation.RandomFloatSignedRR: RandomFloatSignedRR;
		case CalcOperation.RandomIntCR: RandomIntCR;
		case CalcOperation.RandomIntRR: RandomIntRR;
		case CalcOperation.RandomIntSignedCR: RandomIntSignedCR;
		case CalcOperation.RandomIntSignedRR: RandomIntSignedRR;
		case CalcOperation.SinRR: SinRR;
		case CalcOperation.CosRR: CosRR;

		case CalcOperation.AddIntVCV: AddIntVCV;
		case CalcOperation.AddIntVRV: AddIntVRV;
		case CalcOperation.IncrementVV: IncrementVV;
		case CalcOperation.DecrementVV: DecrementVV;
		case CalcOperation.AddFloatVCV: AddFloatVCV;
		case CalcOperation.AddFloatVRV: AddFloatVRV;

		default: throw error(value);
		}
	}

	// ---- calc values ----------------------------------------------

	/**
		(int register) + (int immediate) -> (int register)
	**/
	final AddIntRCR;

	/**
		(int register buffer) + (int register) -> (int register)
	**/
	final AddIntRRR;

	/**
		(int register) - (int immediate) -> (int register)
	**/
	final SubIntRCR;

	/**
		(int immediate) - (int register) -> (int register)
	**/
	final SubIntCRR;

	/**
		(int register buffer) - (int register) -> (int register)
	**/
	final SubIntRRR;

	/**
		-(int register) -> (int register)
	**/
	final MinusIntRR;

	/**
		(int register) * (int immediate) -> (int register)
	**/
	final MultIntRCR;

	/**
		(int register buffer) * (int register) -> (int register)
	**/
	final MultIntRRR;

	/**
		(int register) / (int immediate) -> (int register)
	**/
	final DivIntRCR;

	/**
		(int immediate) / (int register) -> (int register)
	**/
	final DivIntCRR;

	/**
		(int register buffer) / (int register) -> (int register)
	**/
	final DivIntRRR;

	/**
		(int register) % (int immediate) -> (int register)
	**/
	final ModIntRCR;

	/**
		(int immediate) % (int register) -> (int register)
	**/
	final ModIntCRR;

	/**
		(int register buffer) / (int register) -> (int register)
	**/
	final ModIntRRR;

	/**
		(float register) + (float immediate) -> (float register)
	**/
	final AddFloatRCR;

	/**
		(float register buffer) + (float register) -> (float register)
	**/
	final AddFloatRRR;

	/**
		(float register) - (float immediate) -> (float register)
	**/
	final SubFloatRCR;

	/**
		(float immediate) + (float register) -> (float register)
	**/
	final SubFloatCRR;

	/**
		(float register buffer) - (float register) -> (float register)
	**/
	final SubFloatRRR;

	/**
		-(float register) -> (float register)
	**/
	final MinusFloatRR;

	/**
		(float register) * (float immediate) -> (float register)
	**/
	final MultFloatRCR;

	/**
		(float register buffer) * (float register) -> (float register)
	**/
	final MultFloatRRR;

	/**
		(float register) / (float immediate) -> (float register)
	**/
	final DivFloatRCR;

	/**
		(float immediate) / (float register) -> (float register)
	**/
	final DivFloatCRR;

	/**
		(float register buffer) / (float register) -> (float register)
	**/
	final DivFloatRRR;

	/**
		(float register) % (float immediate) -> (float register)
	**/
	final ModFloatRCR;

	/**
		(float immediate) % (float register) -> (float register)
	**/
	final ModFloatCRR;

	/**
		(float register buffer) % (float register) -> (float register)
	**/
	final ModFloatRRR;

	/**
		-(vec register) -> (vec register)
	**/
	final MinusVecRR;

	/**
		(vec register) * (float immediate) -> (vec register)
	**/
	final MultVecRCR;

	/**
		(vec register) * (float register) -> (vec register)
	**/
	final MultVecRRR;

	/**
		(vec register) * (float register) -> (vec register)
	**/
	final DivVecRRR;

	/**
		cast (int register) -> (float register)
	**/
	final CastIntToFloatRR;

	/**
		(float register buffer), (float register) as (x, y) -> (vec register)
	**/
	final CastCartesianRR;

	/**
		(float register buffer), (float register) as (r, θ) -> (vec register)
	**/
	final CastPolarRR;

	/**
		Random value in range `[0, 1)` -> (float register)
	**/
	final RandomRatioR;

	/**
		Random value in range `[0, c)` -> (float register)

		(c: float immediate)
	**/
	final RandomFloatCR;

	/**
		Random value in range `[0, r)` -> (float register)

		(r: float register)
	**/
	final RandomFloatRR;

	/**
		Random value in range `[-c, c)` -> (float register)

		(c: float immediate)
	**/
	final RandomFloatSignedCR;

	/**
		Random value in range `[-r, r)` -> (float register)

		(r: float register)
	**/
	final RandomFloatSignedRR;

	/**
		Random value in range `[0, c)` -> (int register)

		(c: int immediate)
	**/
	final RandomIntCR;

	/**
		Random value in range `[0, r)` -> (int register)

		(r: int register)
	**/
	final RandomIntRR;

	/**
		Random value in range `[-c, c)` -> (int register)

		(c: int immediate)
	**/
	final RandomIntSignedCR;

	/**
		Random value in range `[-r, r)` -> (int register)

		(r: int register)
	**/
	final RandomIntSignedRR;

	/**
		sin(float register) -> (float register)
	**/
	final SinRR;

	/**
		cos(float register) -> (float register)
	**/
	final CosRR;

	/**
		(int var) + (2nd, int immediate) -> (int var)

		where the variable address is specified by (1st, int immediate)
	**/
	final AddIntVCV;

	/**
		(int var) + (int register) -> (int var)

		where the variable address is specified by (int immediate)
	**/
	final AddIntVRV;

	/**
		++(int var)
	**/
	final IncrementVV;

	/**
		--(int var)
	**/
	final DecrementVV;

	/**
		(float var) + (2nd, float immediate) -> (float var)

		where the variable address is specified by (1st, int immediate)
	**/
	final AddFloatVCV;

	/**
		(float var) + (float register) -> (float var)

		where the variable address is specified by (int immediate)
	**/
	final AddFloatVRV;

	public extern inline function int(): Int
		return this;
}

class CalcOperationExtension {
	/**
		@return The mnemonic for `code`.
	**/
	public static inline function toString(code: CalcOperation): String {
		return switch code {
		case AddIntRCR: "add_int_rcr";
		case AddIntRRR: "add_int_rrr";
		case SubIntRCR: "sub_int_rcr";
		case SubIntCRR: "sub_int_crr";
		case SubIntRRR: "sub_int_rrr";
		case MinusIntRR: "minus_int_rr";
		case MultIntRCR: "mult_int_rcr";
		case MultIntRRR: "mult_int_rrr";
		case ModIntRCR: "mod_int_rcr";
		case ModIntCRR: "mod_int_crr";
		case ModIntRRR: "mod_int_rrr";
		case DivIntRCR: "div_int_rcr";
		case DivIntCRR: "div_int_crr";
		case DivIntRRR: "div_int_rrr";

		case AddFloatRCR: "add_float_rcr";
		case AddFloatRRR: "add_float_rrr";
		case SubFloatRCR: "sub_float_rcr";
		case SubFloatCRR: "sub_float_crr";
		case SubFloatRRR: "sub_float_rrr";
		case MinusFloatRR: "minus_float_rr";
		case MultFloatRCR: "mult_float_rcr";
		case MultFloatRRR: "mult_float_rrr";
		case ModFloatRCR: "mod_float_rcr";
		case ModFloatCRR: "mod_float_crr";
		case ModFloatRRR: "mod_float_rrr";
		case DivFloatCRR: "div_float_crr";
		case DivFloatRCR: "div_float_rcr";
		case DivFloatRRR: "div_float_rrr";

		case MinusVecRR: "minus_vec_rr";
		case MultVecRCR: "mult_vec_rcr";
		case MultVecRRR: "mult_vec_rrr";
		case DivVecRRR: "div_vec_rrr";

		case CastIntToFloatRR: "cast_int_to_float_rr";
		case CastCartesianRR: "cast_cartesian_rr";
		case CastPolarRR: "cast_polar_rr";

		case RandomRatioR: "random_ratio_r";
		case RandomFloatCR: "random_float_cr";
		case RandomFloatRR: "random_float_rr";
		case RandomFloatSignedCR: "random_float_signed_cr";
		case RandomFloatSignedRR: "random_float_signed_rr";
		case RandomIntCR: "random_int_cr";
		case RandomIntRR: "random_int_rr";
		case RandomIntSignedCR: "random_int_signed_cr";
		case RandomIntSignedRR: "random_int_signed_rr";
		case CosRR: "cos_rr";
		case SinRR: "sin_rr";

		case AddIntVCV: "add_int_vcv";
		case AddIntVRV: "add_int_vrv";
		case IncrementVV: "increment_vv";
		case DecrementVV: "decrement_vv";
		case AddFloatVCV: "add_float_vcv";
		case AddFloatVRV: "add_float_vrv";
		}
	}
}
