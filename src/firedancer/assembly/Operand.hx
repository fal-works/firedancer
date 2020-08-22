package firedancer.assembly;

import firedancer.bytecode.internal.Constants.*;
import firedancer.assembly.OperandTools.*;

@:using(firedancer.assembly.Operand.OperandExtension)
enum Operand {
	Null;
	Int(operand: IntOperand);
	Float(operand: FloatOperand);
	Vec(operand: VecOperand);
}

class OperandExtension {
	public static function toString(_this: Operand): String {
		return switch _this {
			case Null: "n";
			case Int(operand): operand.toString();
			case Float(operand): operand.toString();
			case Vec(operand): operand.toString();
		}
	}

	public static function bytecodeLength(_this: Operand): UInt {
		return switch _this {
			case Null: UInt.zero;
			case Int(operand): operand.bytecodeLength();
			case Float(operand): operand.bytecodeLength();
			case Vec(operand): operand.bytecodeLength();
		};
	}

	public static function getType(_this: Operand): ValueType {
		return switch _this {
			case Null: throw "Cannot determine type of Null.";
			case Int(_): Int;
			case Float(_): Float;
			case Vec(_): Vec;
		}
	}

	/**
		@return `ValueType` if `this` is `Reg`.
	**/
	public static function tryGetRegType(_this: Operand): Maybe<ValueType> {
		final type: Null<ValueType> = switch _this {
			case Null: null;
			case Int(operand):
				switch operand {
					case Reg: Int;
					default: null;
				}
			case Float(operand):
				switch operand {
					case Reg: Float;
					default: null;
				}
			case Vec(operand):
				switch operand {
					case Reg: Vec;
					default: null;
				}
		}
		return Maybe.from(type);
	}

	/**
		@return `true` if `this` is `Reg`.
	**/
	public static function isReg(_this: Operand): Bool {
		return switch _this {
			case Null: false;
			case Int(operand): operand.isReg();
			case Float(operand): operand.isReg();
			case Vec(operand): operand.isReg();
		}
	}

	/**
		@return `true` if `this` is `RegBuf`.
	**/
	public static function isRegBuf(_this: Operand): Bool {
		return switch _this {
			case Null: false;
			case Int(operand): operand.isRegBuf();
			case Float(operand): operand.isRegBuf();
			case Vec(operand): false;
		}
	}

	/**
		Returns `maybeImm` if:
		- `this` is a register, and
		- `maybeImm` is an immediate with the same type as `this`.
	**/
	public static function tryReplaceRegWithImm(_this: Operand, maybeImm: Operand): Maybe<Operand> {
		final newOperand: Null<Operand> = switch _this {
			case Null: null;
			case Int(thisOperand):
				switch thisOperand {
					case Reg:
						switch maybeImm {
							case Int(maybeIntImm):
								switch maybeIntImm {
									case Imm(_): maybeImm;
									default: null;
								}
							default: null;
						}
					default: null;
				}
			case Float(thisOperand):
				switch thisOperand {
					case Reg:
						switch maybeImm {
							case Float(maybeIntImm):
								switch maybeIntImm {
									case Imm(_): maybeImm;
									default: null;
								}
							default: null;
						}
					default: null;
				}
			case Vec(thisOperand):
				switch thisOperand {
					case Reg:
						switch maybeImm {
							case Vec(maybeIntImm):
								switch maybeIntImm {
									case Imm(_): maybeImm;
									default: null;
								}
							default: null;
						}
					default: null;
				}
		}

		return Maybe.from(newOperand);
	}
}

@:using(firedancer.assembly.Operand.OperandPairExtension)
enum OperandPair {
	Int(a: IntOperand, b: IntOperand);
	Float(a: FloatOperand, b: FloatOperand);
	Vec(a: VecOperand, b: VecOperand);
}

class OperandPairExtension {
	public static function toString(_this: OperandPair): String {
		return switch _this {
			case Int(a, b): '${a.toString()}, ${b.toString()}';
			case Float(a, b):  '${a.toString()}, ${b.toString()}';
			case Vec(a, b): '${a.toString()}, ${b.toString()}';
		}
	}

	public static function bytecodeLength(_this: OperandPair): UInt {
		return switch _this {
			case Int(a, b): a.bytecodeLength() + b.bytecodeLength();
			case Float(a, b): a.bytecodeLength() + b.bytecodeLength();
			case Vec(a, b): a.bytecodeLength() + b.bytecodeLength();
		};
	}

	public static function getType(_this: OperandPair): ValueType {
		return switch _this {
			case Int(_): Int;
			case Float(_): Float;
			case Vec(_): Vec;
		}
	}

	/**
		@return `ValueType` if `this` contains `Reg`.
	**/
	public static function tryGetRegType(_this: OperandPair): Maybe<ValueType> {
		final type: Null<ValueType> = switch _this {
			case Int(a, b):
				if (a.isReg() || b.isReg()) Int else null;
			case Float(a, b):
				if (a.isReg() || b.isReg()) Float else null;
			case Vec(a, b):
				if (a.isReg() || b.isReg()) Vec else null;
		}
		return Maybe.from(type);
	}

	/**
		If `this` takes a register as an input and `maybeImm` is an immediate with the same type,
		returns a new operand with the register operand replaced by `maybeImm`.
	**/
	public static function tryReplaceRegWithImm(_this: OperandPair, maybeImm: Operand): Maybe<OperandPair> {
		final newPair: Null<OperandPair> = switch _this {
			case Int(a, b):
				switch maybeImm {
					case Int(maybeIntImm):
						switch maybeIntImm {
							case Imm(value):
								// do not replace A if B is a buffer register
								if (a.isReg()) switch b {
									case RegBuf: null;
									default: Int(maybeIntImm, b);
								}
								else if (b.isReg()) switch a {
									case RegBuf: null;
									default: Int(a, maybeIntImm);
								}
								else null;
							default: null;
						}
					default: null;
				}
			case Float(a, b):
				switch maybeImm {
					case Float(maybeFloatImm):
						switch maybeFloatImm {
							case Imm(value):
								// do not replace A if B is a buffer register
								if (a.isReg()) switch b {
									case RegBuf: null;
									default: Float(maybeFloatImm, b);
								}
								else if (b.isReg()) switch a {
									case RegBuf: null;
									default: Float(a, maybeFloatImm);
								}
								else null;
							default: null;
						}
					default: null;
				}
			case Vec(a, b): null;
			default: null;
		}

		return Maybe.from(newPair);
	}
}

@:using(firedancer.assembly.Operand.IntOperandExtension)
enum IntOperand {
	Imm(value: Int);
	Reg;
	RegBuf;
	Stack;
	Var(address: UInt);
}

class IntOperandExtension {
	public static function toString(_this: IntOperand): String {
		return switch _this {
			case Imm(value): Std.string(value);
			case Reg: "ri";
			case RegBuf: "rib";
			case Stack: "s";
			case Var(address): 'ivar($address)';
		}
	}

	public static function bytecodeLength(_this: IntOperand): UInt {
		return switch _this {
			case Imm(_): LEN32;
			case Var(_): LEN32;
			default: UInt.zero;
		}
	}

	public static function isReg(_this: IntOperand): Bool {
		return switch _this {
			case Reg: true;
			default: false;
		}
	}

	public static function isRegBuf(_this: IntOperand): Bool {
		return switch _this {
			case RegBuf: true;
			default: false;
		}
	}
}

@:using(firedancer.assembly.Operand.FloatOperandExtension)
enum FloatOperand {
	Imm(value: Float);
	Reg;
	RegBuf;
	Stack;
	Var(address: UInt);
}

class FloatOperandExtension {
	public static function toString(_this: FloatOperand): String {
		return switch _this {
			case Imm(value): ftoa(value);
			case Reg: "rf";
			case RegBuf: "rfb";
			case Stack: "s";
			case Var(address): 'fvar($address)';
		}
	}

	public static function bytecodeLength(_this: FloatOperand): UInt {
		return switch _this {
			case Imm(_): LEN64;
			case Var(_): LEN32;
			default: UInt.zero;
		}
	}

	public static function isReg(_this: FloatOperand): Bool {
		return switch _this {
			case Reg: true;
			default: false;
		}
	}

	public static function isRegBuf(_this: FloatOperand): Bool {
		return switch _this {
			case RegBuf: true;
			default: false;
		}
	}
}

@:using(firedancer.assembly.Operand.VecOperandExtension)
enum VecOperand {
	Imm(x: Float, y: Float);
	Reg;
	Stack;
}

class VecOperandExtension {
	public static function toString(_this: VecOperand): String {
		return switch _this {
			case Imm(x, y): '(${ftoa(x)}, ${ftoa(y)})';
			case Reg: "rvec";
			case Stack: "s";
		}
	}

	public static function bytecodeLength(_this: VecOperand): UInt {
		return switch _this {
			case Imm(_): LEN64 + LEN64;
			default: UInt.zero;
		}
	}

	public static function isReg(_this: VecOperand): Bool {
		return switch _this {
			case Reg: true;
			default: false;
		}
	}
}
