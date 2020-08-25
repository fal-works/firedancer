package firedancer.assembly;

import firedancer.assembly.Operand;

class OperandTools {
	public static function ftoa(v: Float): String
		return if (Floats.toInt(v) == v) '$v.0' else Std.string(v);

	public static function varToString(address: UInt, type: ValueType): String {
		final typeChar = switch type {
		case Int: "i";
		case Float: "f";
		case Vec: "v";
		};
		return '${typeChar}var($address)';
	}

	public static function tryGetOperandPair(a: Operand, b: Operand): Maybe<OperandPair> {
		final pair: Null<OperandPair> = switch a {
		case Null: null;
		case Int(operandA):
			switch b {
			case Int(operandB): Int(operandA, operandB);
			default: null;
			}
		case Float(operandA):
			switch b {
			case Float(operandB): Float(operandA, operandB);
			default: null;
			}
		case Vec(operandA):
			switch b {
			case Vec(operandB): Vec(operandA, operandB);
			default: null;
			}
		};

		return Maybe.from(pair);
	}
}
