package firedancer.assembly;

class OperandTools {
	public static function ftoa(v: Float): String
		return if (Floats.toInt(v) == v) '$v.0' else Std.string(v);

	public static function varToString(key: String, type: ValueType): String {
		if (key.getIndexOf("\"").isSome())
			throw 'Invalid variable key. Contains double quote: $key';

		final typeChar = switch type {
		case Int: "i";
		case Float: "f";
		case Vec: "v";
		};
		return '${typeChar}var[\"$key\"]';
	}
}
