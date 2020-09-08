package firedancer.script.expression;

import sneaker.exception.NotOverriddenException;
import firedancer.types.Azimuth;
import firedancer.assembly.AssemblyCode;
import firedancer.assembly.Instruction;

/**
	Underlying type of `VecExpression`.
**/
class VecExpressionData implements ExpressionData {
	final divisor: Maybe<FloatExpression> = Maybe.none();

	public function new(?divisor: FloatExpression) {
		this.divisor = Maybe.from(divisor);
	}

	public function tryGetConstant(): Maybe<{x: Float, y: Float }>
		throw new NotOverriddenException();

	public function divide(divisor: FloatExpression): VecExpressionData
		throw new NotOverriddenException();

	public function transform(matrix: Transformation): VecExpressionData
		throw new NotOverriddenException();

	public function divideByFloat(divisor: Float): VecExpressionData
		throw new NotOverriddenException();

	public function load(context: CompileContext): AssemblyCode
		throw new NotOverriddenException();

	/**
		Creates an `AssemblyCode` that runs either `processConstantVector` or `processVolatileVector`
		receiving `this` value as argument.
		@param instruction Any `Instruction` that uses the volatile vector.
	**/
	public function use(context: CompileContext, instruction: Instruction): AssemblyCode {
		final code = load(context);
		code.push(instruction);
		return code;
	}

	public function toString(): String
		throw new NotOverriddenException();
}

@:structInit
class CartesianVecExpressionData extends VecExpressionData {
	public final x: FloatExpression;
	public final y: FloatExpression;

	final transformation: Maybe<Transformation> = Maybe.none();

	public function new(
		x: FloatExpression,
		y: FloatExpression,
		?divisor: FloatExpression,
		?transformation: Transformation
	) {
		super(divisor);
		this.x = x;
		this.y = y;
		this.transformation = Maybe.from(transformation);
	}

	override public function tryGetConstant(): Maybe<{x: Float, y: Float }> {
		var x = this.x;
		var y = this.y;

		if (this.transformation.isSome()) {
			final newVec = Transformation.apply(
				this.transformation.unwrap(),
				{ x: x, y: y }
			);
			x = newVec.x;
			y = newVec.y;
		}

		final xConstant = x.tryGetConstant();
		if (xConstant.isNone()) return Maybe.none();

		final yConstant = y.tryGetConstant();
		if (yConstant.isNone()) return Maybe.none();

		final xVal = xConstant.unwrap();
		final yVal = yConstant.unwrap();

		if (divisor.isNone())
			return Maybe.from({ x: xVal, y: yVal });
		else {
			final divisorConstant = divisor.unwrap().tryGetConstant();
			if (divisorConstant.isNone()) return Maybe.none();
			final divVal = divisorConstant.unwrap();
			return Maybe.from({ x: xVal / divVal, y: yVal / divVal });
		}
	}

	override public function divide(divisor: FloatExpression): CartesianVecExpressionData {
		if (this.divisor.isSome()) divisor = this.divisor.unwrap() * divisor;
		return new CartesianVecExpressionData(
			x,
			y,
			divisor,
			transformation.nullable()
		);
	}

	override public function transform(
		matrix: Transformation
	): CartesianVecExpressionData {
		return new CartesianVecExpressionData(
			x,
			y,
			divisor.nullable(),
			if (this.transformation.isSome()) Transformation.multiply(
				this.transformation.unwrap(),
				matrix
			) else matrix
		);
	}

	override public function divideByFloat(divisor: Float): CartesianVecExpressionData
		return divide(divisor);

	override public function load(context: CompileContext): AssemblyCode {
		var x = this.x;
		var y = this.y;

		if (this.transformation.isSome()) {
			final newVec = Transformation.apply(
				this.transformation.unwrap(),
				{ x: x, y: y }
			);
			x = newVec.x;
			y = newVec.y;
		}

		final divisor = this.divisor;

		final loadVecWithoutDivisor = [
			y.load(context),
			[Push(Float(Reg))],
			x.load(context),
			[
				Save(Float(Reg)),
				Pop(Float),
				Cast(CartesianToVec)
			]
		].flatten();

		#if js
		loadVecWithoutDivisor.length; // Workaround for terser --mangle bug
		#end

		if (divisor.isNone()) {
			// rVec
			return loadVecWithoutDivisor;
		} else {
			// rVec / rDiv
			return [
				loadVecWithoutDivisor,
				divisor.unwrap().load(context),
				[Div(Vec(Reg), Float(Reg))]
			].flatten();
		}
	}

	override public function toString(): String
		return '{ x: ${x.toString()}, y: ${y.toString()} }';
}

@:structInit
class PolarVecExpressionData extends VecExpressionData {
	public final length: FloatExpression;
	public final angle: AngleExpression;

	public function new(
		length: FloatExpression,
		angle: AngleExpression,
		?divisor: FloatExpression
	) {
		super(divisor);
		this.length = length;
		this.angle = angle;
	}

	override public function tryGetConstant(): Maybe<{x: Float, y: Float }> {
		final lengthConstant = length.tryGetConstant();
		if (lengthConstant.isNone()) return Maybe.none();

		final angleConstant = angle.tryGetConstant();
		if (angleConstant.isNone()) return Maybe.none();

		final lenVal = lengthConstant.unwrap();
		final angVal = angleConstant.unwrap();
		final vec = Azimuth.fromRadians(angVal).toVec2D(lenVal);

		if (divisor.isNone()) {
			return Maybe.from({ x: vec.x, y: vec.y });
		} else {
			final divisorValue = divisor.unwrap().tryGetConstant();
			if (divisorValue.isNone()) return Maybe.none();
			final divVal = divisorValue.unwrap();
			return Maybe.from({ x: vec.x / divVal, y: vec.y / divVal });
		}
	}

	override public function divide(divisor: FloatExpression): PolarVecExpressionData {
		if (this.divisor.isSome()) divisor = this.divisor.unwrap() * divisor;
		return new PolarVecExpressionData(
			length,
			angle,
			divisor
		);
	}

	override public function transform(
		matrix: Transformation
	): CartesianVecExpressionData {
		// TODO: optimize
		return new CartesianVecExpressionData(
			length * angle.cos(),
			length * angle.sin(),
			divisor.nullable(),
			matrix
		);
	}

	override public function divideByFloat(divisor: Float): PolarVecExpressionData
		return divide(divisor);

	override public function load(context: CompileContext): AssemblyCode {
		var length = this.length;
		final angle = this.angle;

		final loadVecWithoutDivisor = [
			angle.load(context),
			[Push(Float(Reg))],
			length.load(context),
			[
				Save(Float(Reg)),
				Pop(Float),
				Cast(PolarToVec)
			]
		].flatten();

		if (divisor.isNone()) {
			// rVec
			return loadVecWithoutDivisor;
		} else {
			// rVec / rDiv
			return [
				loadVecWithoutDivisor,
				divisor.unwrap().load(context),
				[Div(Vec(Reg), Float(Reg))]
			].flatten();
		}
	}

	override public function toString(): String
		return '{ r: ${length.toString()}, θ: ${angle.toString()} }';
}
