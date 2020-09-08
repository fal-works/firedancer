package firedancer.script.expression;

import firedancer.assembly.Instruction;
import firedancer.assembly.AssemblyCode;
import firedancer.script.expression.subtypes.FloatLikeConstant;
import firedancer.script.expression.subtypes.FloatLikeRuntimeExpression;

/**
	Expression representing any float value.
**/
enum FloatLikeExpressionEnum {
	Constant(value: FloatLikeConstant);
	Runtime(expression: FloatLikeRuntimeExpression);
}

/**
	Wrapper of `FloatLikeExpressionEnum`.
**/
@:structInit
class FloatLikeExpressionData implements ExpressionData {
	public static extern inline function create(
		data: FloatLikeExpressionEnum
	): FloatLikeExpressionData {
		return { data: data };
	}

	/**
		The enum instance.
	**/
	public final data: FloatLikeExpressionEnum;

	/**
		Creates an `AssemblyCode` that assigns `this` value to the float register.
	**/
	public function load(context: CompileContext): AssemblyCode {
		return switch this.data {
		case Constant(value):
			Load(Float(Imm(value.toImmediateValue())));
		case Runtime(expression):
			expression.load(context);
		}
	}

	/**
		Creates an `AssemblyCode` that runs either `constantOpcode` or `volatileOpcode`
		receiving `this` value as argument.
	**/
	public function use(context: CompileContext, instruction: Instruction): AssemblyCode {
		return [
			load(context),
			[instruction]
		].flatten();
	}

	public function tryGetConstant(): Maybe<Float> {
		return switch this.data {
		case Constant(value):
			Maybe.from(value.toImmediateValue());
		case Runtime(expression):
			Maybe.none();
		}
	}

	public function unaryOperation(instruction: Instruction): FloatLikeExpressionData {
		return create(
			Runtime(
				FloatLikeRuntimeExpressionEnum.UnaryOperation(
					instruction,
					this
				)
			)
		);
	}

	public function binaryOperation(
		instruction: Instruction,
		other: FloatLikeExpressionData
	): FloatLikeExpressionData {
		return create(
			Runtime(
				FloatLikeRuntimeExpressionEnum.BinaryOperation(
					instruction,
					this,
					other
				)
			)
		);
	}

	public function unaryMinus(): FloatLikeExpressionData
		return unaryOperation(Minus(Float(Reg)));

	public function cos(): FloatLikeExpressionData
		return unaryOperation(Cos);

	public function sin(): FloatLikeExpressionData
		return unaryOperation(Sin);

	public function add(other: FloatLikeExpressionData): FloatLikeExpressionData
		return binaryOperation(Add(Float(RegBuf, Reg)), other);

	public function subtract(other: FloatLikeExpressionData): FloatLikeExpressionData
		return binaryOperation(Sub(Float(RegBuf, Reg)), other);

	public function multiply(other: FloatLikeExpressionData): FloatLikeExpressionData
		return binaryOperation(Mult(Float(RegBuf), Float(Reg)), other);

	public function divide(other: FloatLikeExpressionData): FloatLikeExpressionData
		return binaryOperation(Div(Float(RegBuf), Float(Reg)), other);

	public function modulo(other: FloatLikeExpressionData): FloatLikeExpressionData
		return binaryOperation(Mod(Float(RegBuf), Float(Reg)), other);

	public extern inline function toEnum(): FloatLikeExpressionEnum
		return this.data;

	public function toString(): String {
		return switch data {
		case Constant(value): 'FloatC(${value.toString()})';
		case Runtime(expression): 'FloatR(${expression.toString()})';
		}
	}
}
