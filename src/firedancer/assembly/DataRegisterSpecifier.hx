package firedancer.assembly;

enum abstract DataRegisterSpecifier(Int) {
	/**
		@return The main register that corresponds to `type`.
	**/
	public static function get(type: ValueType): DataRegisterSpecifier {
		return switch type {
			case Int: Ri;
			case Float: Rf;
			case Vec: Rvec;
		}
	}

	/**
		The main integer data register.
	**/
	final Ri;

	/**
		The integer data register for buffering purpose.
	**/
	final Rib;

	/**
		The main floating-point data register.
	**/
	final Rf;

	/**
		The floating-point data register for buffering purpose.
	**/
	final Rfb;

	/**
		The 2D vector data register.
	**/
	final Rvec;

	/**
		@return The `ValueType` that corresponds to `this`.
	**/
	public function getType(): ValueType {
		final reg: DataRegisterSpecifier = cast this;
		return switch reg {
			case Ri | Rib: Int;
			case Rf | Rfb: Float;
			case Rvec: Vec;
		};
	}

	/**
		@return The corresponding buffer register for `this`.
	**/
	public function getBuffer(): DataRegisterSpecifier {
		final reg: DataRegisterSpecifier = cast this;
		return switch reg {
			case Ri: Rib;
			case Rf: Rfb;
			default: throw 'Buffer is not available for ${reg.toString()}';
		};
	}

	@:to public function toString(): String {
		return switch (cast this: DataRegisterSpecifier) {
			case Ri: "ri";
			case Rib: "rib";
			case Rf: "rf";
			case Rfb: "rfb";
			case Rvec: "rvec";
		};
	}
}
