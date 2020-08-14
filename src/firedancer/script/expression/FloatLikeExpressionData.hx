package firedancer.script.expression;

import firedancer.assembly.Opcode;
import firedancer.assembly.operation.GeneralOperation;
import firedancer.assembly.operation.CalcOperation;
import firedancer.assembly.Instruction;
import firedancer.assembly.AssemblyCode;
import firedancer.assembly.Immediate;
import firedancer.script.expression.subtypes.FloatLikeConstant;
import firedancer.script.expression.subtypes.FloatLikeRuntimeExpression;
import firedancer.script.expression.subtypes.SimpleUnaryOperator;
import firedancer.script.expression.subtypes.SimpleBinaryOperator;

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
		Creates an `AssemblyCode` that assigns `this` value to the current volatile float.
	**/
	public function loadToVolatile(context: CompileContext): AssemblyCode {
		return switch this.data {
			case Constant(value):
				new Instruction(LoadFloatCV, [value.toImmediate()]);
			case Runtime(expression):
				expression.loadToVolatile(context);
		}
	}

	/**
		Creates an `AssemblyCode` that runs either `constantOpcode` or `volatileOpcode`
		receiving `this` value as argument.
	**/
	public function use(context: CompileContext, constantOpcode: Opcode, volatileOpcode: Opcode): AssemblyCode {
		final immediate = tryMakeImmediate();

		return if (immediate.isSome()) {
			new Instruction(constantOpcode, [immediate.unwrap()]);
		} else [
			loadToVolatile(context),
			[new Instruction(volatileOpcode, [])]
		].flatten();
	}

	public function tryGetConstant(): Maybe<Float> {
		switch this.data {
			case Constant(value):
				return Maybe.from(value.toImmediateValue());
			case Runtime(expression):
				switch expression.toEnum() {
					case UnaryOperation(type, operandExpr):
						final constant = operandExpr.tryGetConstant();
						if (constant.isSome()) {
							switch type.constantOperator {
								case Immediate(func):
									return Maybe.from(func(constant.unwrap()).raw());
								default:
							}
						}
					case BinaryOperation(type, operandExprA, operandExprB):
						final constantA = operandExprA.tryGetConstant();
						final constantB = operandExprB.tryGetConstant();
						if (constantA.isSome() && constantB.isSome() && type.operateConstants.isSome()) {
							final operate = type.operateConstants.unwrap();
							return Maybe.from(operate(
								constantA.unwrap(),
								constantB.unwrap()
							).raw());
						}
					default:
				}
		}

		return Maybe.none();
	}

	public function tryMakeImmediate(): Maybe<Immediate> {
		final constant = tryGetConstant();
		return if (constant.isSome()) Maybe.from(Float(constant.unwrap())) else Maybe.none();
	}

	public function unaryOperation(
		type: SimpleUnaryOperator<FloatLikeConstant>
	): FloatLikeExpressionData {
		return create(Runtime(FloatLikeRuntimeExpressionEnum.UnaryOperation(
			type,
			this
		)));
	}

	public function binaryOperation(
		type: SimpleBinaryOperator<FloatLikeConstant>,
		other: FloatLikeExpressionData
	): FloatLikeExpressionData {
		return create(Runtime(FloatLikeRuntimeExpressionEnum.BinaryOperation(
			type,
			this,
			other
		)));
	}

	public function unaryMinus(): FloatLikeExpressionData {
		return unaryOperation({
			constantOperator: Immediate(v -> -v),
			runtimeOperator: MinusFloatV
		});
	}

	public function add(other: FloatLikeExpressionData): FloatLikeExpressionData {
		return binaryOperation({
			operateConstants: (a, b) -> a + b,
			operateVCV: AddFloatVCV,
			operateCVV: AddFloatVCV,
			operateVVV: AddFloatVVV
		}, other);
	}

	public function subtract(other: FloatLikeExpressionData): FloatLikeExpressionData {
		return binaryOperation({
			operateConstants: (a, b) -> a - b,
			operateVCV: SubFloatVCV,
			operateCVV: SubFloatCVV,
			operateVVV: SubFloatVVV
		}, other);
	}

	public function multiply(other: FloatExpression): FloatLikeExpressionData {
		return binaryOperation({
			operateConstants: (a, b) -> a * b,
			operateVCV: MultFloatVCV,
			operateCVV: MultFloatVCV,
			operateVVV: MultFloatVVV
		}, other);
	}

	public function divide(other: FloatExpression): FloatLikeExpressionData {
		switch this.data {
			case Constant(_):
			case Runtime(_):
				final otherConstant = other.tryGetConstant();
				if (otherConstant.isSome()) {
					// multiply by the reciprocal: rt / c => rt * (1 / c)
					other = create(Constant(1.0 / otherConstant.unwrap()));
				}
		}

		return binaryOperation({
			operateConstants: (a, b) -> a / b,
			operateVCV: MultFloatVCV, // multiply by the reciprocal
			operateCVV: DivFloatCVV,
			operateVVV: DivFloatVVV
		}, other);
	}

	public function modulo(other: FloatLikeExpressionData): FloatLikeExpressionData {
		return binaryOperation({
			operateConstants: (a, b) -> a % b,
			operateVCV: ModFloatVCV,
			operateCVV: ModFloatCVV,
			operateVVV: ModFloatVVV
		}, other);
	}

	public extern inline function toEnum(): FloatLikeExpressionEnum
		return this.data;
}
