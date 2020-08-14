package firedancer.bytecode;

import sneaker.string_buffer.StringBuffer;
import banker.binary.BytesData;

/**
	Bytecode that can be executed by `firedancer.bytecode.Vm`.

	This does not have the `length` property (use `Program` if you need it).
**/
@:notNull @:forward
abstract Bytecode(BytesData) from BytesData to BytesData {
	/**
		@return `this` bytecode in `String` representation with line feed for each 16 bytes.
	**/
	public function dump(codeLength: UInt, markPosition = MaybeUInt.none): String {
		final buf = new StringBuffer();

		var codeDump = this.toHex(codeLength, true);

		if (markPosition.isSome()) {
			final pos = markPosition.unwrap();
			if (!pos.isZero() && pos < codeLength) {
				final chars = codeDump.split("");
				chars[markPosition.unwrap() * 3 - 1] = "|";
				codeDump = chars.join("");
			}
		}

		final codeDumpLength = codeDump.length;
		var pos = UInt.zero;
		final lineLength = 16 * 3; // 16 bytes with spaces
		while (pos < codeDumpLength) {
			buf.addLf(codeDump.substr(pos, lineLength - 1));
			pos += lineLength;
		}

		return buf.toString();
	}
}
