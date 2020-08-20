package firedancer.assembly;

class OperandTools {
	public static function varToString(address: UInt, type: ValueType): String {
		final typeChar = switch type {
			case Int: "i";
			case Float: "f";
			case Vec: "v";
		};
		return '${typeChar}var($address)';
	}
}
