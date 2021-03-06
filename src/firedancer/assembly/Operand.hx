package firedancer.assembly;

import reckoner.Numeric;
import firedancer.vm.Constants.*;
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
		@return `ValueType` if `this` is `RegBuf`.
	**/
	public static function tryGetRegBufType(_this: Operand): Maybe<ValueType> {
		final type: Null<ValueType> = switch _this {
		case Null: null;
		case Int(operand):
			switch operand {
			case RegBuf: Int;
			default: null;
			}
		case Float(operand):
			switch operand {
			case RegBuf: Float;
			default: null;
			}
		default: null;
		}
		return Maybe.from(type);
	}

	/**
		@return `ValueType` if `this` is `Imm`.
	**/
	public static function tryGetImmType(_this: Operand): Maybe<ValueType> {
		final type: Null<ValueType> = switch _this {
		case Null: null;
		case Int(operand):
			switch operand {
			case Imm(_): Int;
			default: null;
			}
		case Float(operand):
			switch operand {
			case Imm(_): Float;
			default: null;
			}
		case Vec(operand):
			switch operand {
			case Imm(_): Vec;
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
		@return `true` if `this` is `Stack`.
	**/
	public static function isStack(_this: Operand): Bool {
		return switch _this {
		case Null: false;
		case Int(operand): operand == Stack;
		case Float(operand): operand == Stack;
		case Vec(operand): operand == Stack;
		}
	}

	/**
		@return The kind of `this` operand.
	**/
	public static function getKind(_this: Operand): OperandKind {
		return switch _this {
		case Null: Null;
		case Int(operand):
			switch operand {
			case Imm(_): Imm;
			case Reg: Reg;
			case RegBuf: RegBuf;
			case Stack: Stack;
			case Var(_): Var;
			}
		case Float(operand):
			switch operand {
			case Imm(_): Imm;
			case Reg: Reg;
			case RegBuf: RegBuf;
			case Stack: Stack;
			case Var(_): Var;
			}
		case Vec(operand):
			switch operand {
			case Imm(_, _): Imm;
			case Reg: Reg;
			case Stack: Stack;
			}
		}
	}

	public static function tryGetIntImm(_this: Operand): Maybe<Int> {
		final result: Null<Int> = switch _this {
		case Int(operand):
			switch operand {
			case Imm(value): value;
			default: null;
			}
		default: null;
		};
		return Maybe.from(result);
	}

	public static function tryGetFloatImm(_this: Operand): Maybe<Float> {
		final result: Null<Float> = switch _this {
		case Float(operand):
			switch operand {
			case Imm(value): value;
			default: null;
			}
		default: null;
		};
		return Maybe.from(result);
	}

	public static function tryGetVecImm(_this: Operand): Maybe<{x: Float, y: Float }> {
		final result: Null<{x: Float, y: Float }> = switch _this {
		case Vec(operand):
			switch operand {
			case Imm(x, y): { x: x, y: y };
			default: null;
			}
		default: null;
		};
		return Maybe.from(result);
	}

	/**
		Returns `maybeImm` if:
		- `this` is `Reg`, and
		- `maybeImm` is an immediate with the same type as `this`.
	**/
	public static function tryReplaceRegWithImm(
		_this: Operand,
		maybeImm: Operand
	): Maybe<Operand> {
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

	/**
		Returns `maybeImm` if:
		- `this` is `RegBuf`, and
		- `maybeImm` is an immediate with the same type as `this`.
	**/
	public static function tryReplaceRegBufWithImm(
		_this: Operand,
		maybeImm: Operand
	): Maybe<Operand> {
		final newOperand: Null<Operand> = switch _this {
		case Int(thisOperand):
			switch thisOperand {
			case RegBuf:
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
			case RegBuf:
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
		default: null;
		}

		return Maybe.from(newOperand);
	}

	/**
		If `this` refers to a variable and its content is an immediate (according to `variables`),
		returns that immediate as an `Operand`.
	**/
	public static function tryReplaceVarWithImm(
		_this: Operand,
		variables: Optimizer.Variables
	): Maybe<Operand> {
		final newOperand: Null<Operand> = switch _this {
		case Null: null;
		case Int(thisOperand):
			switch thisOperand {
			case Var(address):
				final variable = variables.get(address);
				if (variable.operand.isSome()) {
					switch variable.operand.unwrap() {
					case Int(maybeIntImm):
						switch maybeIntImm {
						case Imm(_): variable.operand.unwrap();
						default: null;
						}
					default: null;
					}
				} else null;
			default: null;
			}
		case Float(thisOperand):
			switch thisOperand {
			case Var(address):
				final variable = variables.get(address);
				if (variable.operand.isSome()) {
					switch variable.operand.unwrap() {
					case Float(maybeIntImm):
						switch maybeIntImm {
						case Imm(_): variable.operand.unwrap();
						default: null;
						}
					default: null;
					}
				} else null;
			default: null;
			}
		default: null;
		}

		return Maybe.from(newOperand);
	}

	/**
		@return `true` if `this` is (nearly) an immediate value `0`.
	**/
	public static function isZero(_this: Operand): Bool {
		return switch _this {
		case Int(operand): operand.isZero();
		case Float(operand): operand.isZero();
		case Vec(operand): operand.isZero();
		default: false;
		}
	}

	/**
		@return `true` if `this` is (nearly) an immediate value `1`. Always `false` if `Vec`.
	**/
	public static function isOne(_this: Operand): Bool {
		return switch _this {
		case Int(operand): operand.isOne();
		case Float(operand): operand.isOne();
		default: false;
		}
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
		case Float(a, b): '${a.toString()}, ${b.toString()}';
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

	public static function getFirstOperand(_this: OperandPair): Operand {
		return switch _this {
		case Int(a, b): Int(a);
		case Float(a, b): Float(a);
		case Vec(a, b): Vec(a);
		};
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
		@return `ValueType` if `this` contains `RegBuf`.
	**/
	public static function tryGetRegBufType(_this: OperandPair): Maybe<ValueType> {
		final type: Null<ValueType> = switch _this {
		case Int(a, b):
			if (a.isRegBuf() || b.isRegBuf()) Int else null;
		case Float(a, b):
			if (a.isRegBuf() || b.isRegBuf()) Float else null;
		default: null;
		}
		return Maybe.from(type);
	}

	/**
		If `this` takes `Reg` as an input and `maybeImm` is an immediate with the same type,
		returns a new operand with `Reg` replaced by `maybeImm`.
	**/
	public static function tryReplaceRegWithImm(
		_this: OperandPair,
		maybeImm: Operand
	): Maybe<OperandPair> {
		final newPair: Null<OperandPair> = switch _this {
		case Int(a, b):
			switch maybeImm {
			case Int(maybeIntImm):
				switch maybeIntImm {
				case Imm(value):
					// do not replace A if B is a buffer register (vice versa)
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
					// do not replace A if B is a buffer register (vice versa)
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

	/**
		If `this` takes `RegBuf` as an input and `maybeImm` is an immediate with the same type,
		returns a new operand with `RegBuf` replaced by `maybeImm`.
	**/
	public static function tryReplaceRegBufWithImm(
		_this: OperandPair,
		maybeImm: Operand
	): Maybe<OperandPair> {
		final newPair: Null<OperandPair> = switch _this {
		case Int(a, b):
			switch maybeImm {
			case Int(maybeIntImm):
				switch maybeIntImm {
				case Imm(value):
					if (a.isRegBuf()) {
						Int(maybeIntImm, b);
					} else if (b.isRegBuf()) {
						Int(a, maybeIntImm);
					} else null;
				default: null;
				}
			default: null;
			}
		case Float(a, b):
			switch maybeImm {
			case Float(maybeFloatImm):
				switch maybeFloatImm {
				case Imm(value):
					if (a.isRegBuf()) {
						Float(maybeFloatImm, b);
					} else if (b.isRegBuf()) {
						Float(a, maybeFloatImm);
					} else null;
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
	Var(key: String);
}

class IntOperandExtension {
	public static function toString(_this: IntOperand): String {
		return switch _this {
		case Imm(value): Std.string(value);
		case Reg: "ri";
		case RegBuf: "rib";
		case Stack: "s";
		case Var(key): varToString(key, Int);
		}
	}

	public static function bytecodeLength(_this: IntOperand): UInt {
		return switch _this {
		case Imm(_): IntSize;
		case Var(_): IntSize;
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

	public static function isZero(_this: IntOperand): Bool {
		return switch _this {
		case Imm(value): value == 0;
		default: false;
		}
	}

	public static function isOne(_this: IntOperand): Bool {
		return switch _this {
		case Imm(value): value == 1;
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
	Var(key: String);
}

class FloatOperandExtension {
	public static function toString(_this: FloatOperand): String {
		return switch _this {
		case Imm(value): ftoa(value);
		case Reg: "rf";
		case RegBuf: "rfb";
		case Stack: "s";
		case Var(key): varToString(key, Float);
		}
	}

	public static function bytecodeLength(_this: FloatOperand): UInt {
		return switch _this {
		case Imm(_): FloatSize;
		case Var(_): IntSize;
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

	public static function isZero(_this: FloatOperand): Bool {
		return switch _this {
		case Imm(value): Numeric.nearlyEqual(value, 0.0);
		default: false;
		}
	}

	public static function isOne(_this: FloatOperand): Bool {
		return switch _this {
		case Imm(value): Numeric.nearlyEqual(value, 1.0);
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
		case Imm(_): VecSize;
		default: UInt.zero;
		}
	}

	public static function isReg(_this: VecOperand): Bool {
		return switch _this {
		case Reg: true;
		default: false;
		}
	}

	public static function isZero(_this: VecOperand): Bool {
		return switch _this {
		case Imm(x, y): Numeric.nearlyEqual(
				x,
				0.0
			) && Numeric.nearlyEqual(y, 0.0);
		default: false;
		}
	}
}
