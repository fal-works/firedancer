package firedancer.script.expression;

import firedancer.assembly.Instruction;
import firedancer.assembly.AssemblyCode;
import firedancer.script.expression.FloatLikeExpressionData;
import firedancer.script.expression.subtypes.IntLikeRuntimeExpression;
import firedancer.script.expression.subtypes.IntLikeConstant;
import firedancer.script.expression.subtypes.FloatLikeRuntimeExpression;

enum IntLikeExpressionEnum {
	Constant(value: IntLikeConstant);
	Runtime(expression: IntLikeRuntimeExpression);
}

/**
	Expression representing any float value.
**/
@:structInit
class IntLikeExpressionData implements ExpressionData {
	public static extern inline function create(
		data: IntLikeExpressionEnum
	): IntLikeExpressionData {
		return { data: data };
	}

	public final data: IntLikeExpressionEnum;

	public function toFloatExpression(): FloatExpression
		return this.toFloatLikeExpressionData(FloatExpression.constantFactor);

	public function toAngleExpression(): AngleExpression
		return this.toFloatLikeExpressionData(AngleExpression.constantFactor);

	/**
		Creates an `AssemblyCode` that assigns `this` value to the int register.
	**/
	public function load(context: CompileContext): AssemblyCode {
		return switch this.data {
		case Constant(value):
			Load(Int(Imm(value.toImmediateValue())));
		case Runtime(expression):
			expression.load(context);
		}
	}

	/**
		Creates an `AssemblyCode` that runs `instruction`
		receiving `this` value as argument via register.
	**/
	public function use(context: CompileContext, instruction: Instruction): AssemblyCode
		return [load(context), [instruction]].flatten();

	public function tryGetConstant(): Maybe<Int> {
		return switch this.data {
		case Constant(value):
			Maybe.from(value.toImmediateValue());
		case Runtime(expression):
			Maybe.none();
		}
	}

	public function unaryOperation(instruction: Instruction): IntLikeExpressionData {
		return create(
			Runtime(
				IntLikeRuntimeExpressionEnum.UnaryOperation(
					instruction,
					this
				)
			)
		);
	}

	public function binaryOperation(
		instruction: Instruction,
		other: IntLikeExpressionData
	): IntLikeExpressionData {
		return create(
			Runtime(
				IntLikeRuntimeExpressionEnum.BinaryOperation(
					instruction,
					this,
					other
				)
			)
		);
	}

	public function unaryMinus(): IntLikeExpressionData
		return unaryOperation(Minus(Int(Reg)));

	public function add(other: IntLikeExpressionData): IntLikeExpressionData
		return binaryOperation(Add(Int(RegBuf, Reg)), other);

	public function subtract(other: IntLikeExpressionData): IntLikeExpressionData
		return binaryOperation(Sub(Int(RegBuf, Reg)), other);

	public function multiply(other: IntLikeExpressionData): IntLikeExpressionData
		return binaryOperation(Mult(Int(RegBuf), Int(Reg)), other);

	public function divide(other: IntLikeExpressionData): IntLikeExpressionData
		return binaryOperation(Div(Int(RegBuf), Int(Reg)), other);

	public function modulo(other: IntLikeExpressionData): IntLikeExpressionData
		return binaryOperation(Mod(Int(RegBuf), Int(Reg)), other);

	public extern inline function toEnum()
		return this.data;

	public function toString(): String {
		return switch data {
		case Constant(value): 'IntC(${value.toString()})';
		case Runtime(expression): 'IntR(${expression.toString()})';
		}
	}

	function toFloatLikeExpressionData(constantFactor: Float): FloatLikeExpressionData {
		final loadAsFloat: (context: CompileContext) -> AssemblyCode = context -> [
			this.load(context),
			[Cast(IntToFloat)],
			if (constantFactor == 1.0) [] else {
				[Mult(Float(Reg), Float(Imm(constantFactor)))];
			}
		].flatten();

		final data = FloatLikeExpressionEnum.Runtime(FloatLikeRuntimeExpressionEnum.Custom(loadAsFloat));

		return FloatLikeExpressionData.create(data);
	}
}
