package firedancer.assembly;

import firedancer.bytecode.internal.Constants.*;
import firedancer.assembly.OperandTools.*;

@:using(firedancer.assembly.Operand.OperandExtension)
enum Operand {
	Null;
	Immediate(imm: Immediate);
	Reg(reg: DataRegisterSpecifier);
	Stack;
	LocalVariable(address: UInt, type: ValueType);
}

@:using(firedancer.assembly.Operand.NullOrStackExtension)
enum NullOrStack {
	Null;
	Stack;
}

@:using(firedancer.assembly.Operand.ImmOrVarExtension)
enum ImmOrVar {
	Immediate(imm: Immediate);
	LocalVariable(address: UInt, type: ValueType);
}

@:using(firedancer.assembly.Operand.ImmOrRegExtension)
enum ImmOrReg {
	Immediate(imm: Immediate);
	Reg(reg: DataRegisterSpecifier);
}

@:using(firedancer.assembly.Operand.RegOrVarExtension)
enum RegOrVar {
	Reg(reg: DataRegisterSpecifier);
	LocalVariable(address: UInt, type: ValueType);
}

@:using(firedancer.assembly.Operand.ImmOrRegOrStackExtension)
enum ImmOrRegOrStack {
	Imm(imm: Immediate);
	Reg(reg: DataRegisterSpecifier);
	Stack;
}

class OperandExtension {
	public static function toString(_this: Operand): String {
		return switch _this {
			case Null: "n";
			case Immediate(imm): '${imm.toString()}';
			case Reg(reg): reg;
			case Stack: "s";
			case LocalVariable(address, type): varToString(address, type);
		}
	}

	public static function bytecodeLength(_this: Operand): UInt {
		return switch _this {
			case Null: UInt.zero;
			case Immediate(imm):
				switch imm {
					case Int(_): LEN32;
					case Float(_): LEN64;
					case Vec(_, _): LEN64 + LEN64;
				}
			case Reg(_): UInt.zero;
			case Stack: UInt.zero;
			case LocalVariable(_, _): LEN32; // for address
		};
	}

	public static function getType(_this: Operand): ValueType {
		return switch _this {
			case Null: throw "Cannot determine type of Null.";
			case Immediate(imm): imm.getType();
			case Reg(reg): reg.getType();
			case Stack: throw "Cannot determine type of Stack.";
			case LocalVariable(_, type): type;
		}
	}
}

class NullOrStackExtension {
	public static function toString(_this: NullOrStack): String
		return toOperand(_this).toString();

	public static function bytecodeLength(_this: NullOrStack): UInt
		return toOperand(_this).bytecodeLength();

	static function toOperand(_this: NullOrStack): Operand {
		return switch _this {
			case Null: Null;
			case Stack: Stack;
		}
	}
}

class ImmOrVarExtension {
	public static function toString(_this: ImmOrVar): String
		return toOperand(_this).toString();

	public static function bytecodeLength(_this: ImmOrVar): UInt
		return toOperand(_this).bytecodeLength();

	public static function getType(_this: ImmOrVar): ValueType
		return toOperand(_this).getType();

	static function toOperand(_this: ImmOrVar): Operand {
		return switch _this {
			case Immediate(imm): Immediate(imm);
			case LocalVariable(address, type): LocalVariable(address, type);
		}
	}
}

class ImmOrRegExtension {
	public static function toString(_this: ImmOrReg): String
		return toOperand(_this).toString();

	public static function bytecodeLength(_this: ImmOrReg): UInt
		return toOperand(_this).bytecodeLength();

	public static function getType(_this: ImmOrReg): ValueType
		return toOperand(_this).getType();

	static function toOperand(_this: ImmOrReg): Operand {
		return switch _this {
			case Immediate(imm): Immediate(imm);
			case Reg(reg): Reg(reg);
		}
	}
}

class RegOrVarExtension {
	public static function toString(_this: RegOrVar): String
		return toOperand(_this).toString();

	public static function bytecodeLength(_this: RegOrVar): UInt
		return toOperand(_this).bytecodeLength();

	public static function getType(_this: RegOrVar): ValueType
		return toOperand(_this).getType();

	static function toOperand(_this: RegOrVar): Operand {
		return switch _this {
			case Reg(reg): Reg(reg);
			case LocalVariable(address, type): LocalVariable(address, type);
		}
	}
}

class ImmOrRegOrStackExtension {
	public static function toString(_this: ImmOrRegOrStack): String
		return toOperand(_this).toString();

	public static function bytecodeLength(_this: ImmOrRegOrStack): UInt
		return toOperand(_this).bytecodeLength();

	public static function getType(_this: ImmOrRegOrStack): ValueType
		return toOperand(_this).getType();

	static function toOperand(_this: ImmOrRegOrStack): Operand {
		return switch _this {
			case Imm(imm): Immediate(imm);
			case Reg(reg): Reg(reg);
			case Stack: Stack;
		}
	}
}
