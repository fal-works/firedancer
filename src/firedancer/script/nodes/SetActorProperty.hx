package firedancer.script.nodes;

import firedancer.vm.Constants.IntSize;
import firedancer.assembly.Instruction;
import firedancer.assembly.AssemblyCode;
import firedancer.assembly.types.ActorProperty.create as prop;
import firedancer.assembly.types.ActorPropertyType;
import firedancer.script.expression.*;

/**
	Sets actor's property (e.g. position).
**/
@:ripper_verified
class SetActorProperty extends AstNode implements ripper.Data {
	final propType: ActorPropertyType;
	final operation: ActorPropertySetOperation;

	/**
		Performs this operation gradually in `frames`.
	**/
	public function frames(frames: IntExpression)
		return new SetActorPropertyLinear(propType, operation, frames);

	override inline function containsWait(): Bool
		return false;

	override function toAssembly(context: CompileContext): AssemblyCode {
		final c = context;

		return switch propType {
		case Position:
			switch operation {
			case SetVector(e, mat):
				if (mat != null) e = e.transform(mat);
				e.use(c, Set(Vec(Reg), prop(Position, Vector)));
			case SetLength(e): e.use(c, Set(Float(Reg), prop(Position, Length)));
			case SetAngle(e): e.use(c, Set(Float(Reg), prop(Position, Angle)));
			}
		case Velocity:
			switch operation {
			case SetVector(e, mat):
				if (mat != null) e = e.transform(mat);
				e.use(c, Set(Vec(Reg), prop(Velocity, Vector)));
			case SetLength(e): e.use(c, Set(Float(Reg), prop(Velocity, Length)));
			case SetAngle(e): e.use(c, Set(Float(Reg), prop(Velocity, Angle)));
			}
		case ShotPosition:
			switch operation {
			case SetVector(e, mat):
				if (mat != null) e = e.transform(mat);
				e.use(c, Set(Vec(Reg), prop(ShotPosition, Vector)));
			case SetLength(e): e.use(c, Set(Float(Reg), prop(ShotPosition, Length)));
			case SetAngle(e): e.use(c, Set(Float(Reg), prop(ShotPosition, Angle)));
			}
		case ShotVelocity:
			switch operation {
			case SetVector(e, mat):
				if (mat != null) e = e.transform(mat);
				e.use(c, Set(Vec(Reg), prop(ShotVelocity, Vector)));
			case SetLength(e): e.use(c, Set(Float(Reg), prop(ShotVelocity, Length)));
			case SetAngle(e): e.use(c, Set(Float(Reg), prop(ShotVelocity, Angle)));
			}
		}
	}
}

@:ripper_verified
class SetActorVector extends SetActorProperty implements ripper.Data {
	public function new(
		propType: ActorPropertyType,
		vec: VecExpression,
		?matrix: Transformation
	) {
		super(propType, SetVector(vec, matrix));
	}

	public function transform(matrix: Transformation): SetActorVector {
		return switch operation {
		case SetVector(vec, mat):
			new SetActorVector(
				propType,
				vec,
				if (mat != null) Transformation.multiply(mat, matrix) else matrix
			);
		default:
			throw "Invalid operation in SetActorVector class.";
		}
	}

	public function translate(x: FloatExpression, y: FloatExpression): SetActorVector
		return this.transform(Transformation.createTranslate(x, y));

	public function rotate(angle: AngleExpression): SetActorVector
		return this.transform(Transformation.createRotate(angle));

	public function scale(x: FloatExpression, y: FloatExpression): SetActorVector
		return this.transform(Transformation.createScale(x, y));
}

class SetActorPropertyLinear extends AstNode {
	final propType: ActorPropertyType;
	final operation: ActorPropertySetOperation;
	final frames: IntExpression;

	public function new(
		propType: ActorPropertyType,
		operation: ActorPropertySetOperation,
		frames: IntExpression
	) {
		this.propType = propType;
		this.operation = operation;
		this.frames = frames;
	}

	override inline function containsWait(): Bool {
		final constFrames = this.frames.tryGetConstant();
		return if (constFrames.isSome()) 0 < constFrames.unwrap() else true;
	}

	override function toAssembly(context: CompileContext): AssemblyCode {
		final frames = this.frames;

		inline function getDivChange(isVec: Bool): AssemblyCode {
			return {
				final divRRR: Instruction = Div(isVec ? Vec(Reg) : Float(RegBuf), Float(Reg));
				final code: AssemblyCode = isVec ? [] : [Save(Float(Reg))];
				final loadFramesAsFloat = (frames : FloatExpression).load(context);
				code.pushFromArray(loadFramesAsFloat);
				code.push(divRRR);
				code;
			};
		}

		var getDiff: AssemblyCode; // Calculate total change (before the loop)
		var divChange: AssemblyCode; // Get change rate (before the loop)
		var pushChange: Instruction; // Push change rate (before the loop)
		var peekChange: Instruction; // Peek change rate (in the loop)
		var addFromVolatile: Instruction; // Apply change rate (in the loop)
		var dropChange: Instruction; // Drop change rate (after the loop)

		switch operation {
		case SetVector(vec, mat):
			if (mat != null) vec = vec.transform(mat);

			divChange = getDivChange(true);
			pushChange = Push(Vec(Reg));
			peekChange = Peek(Vec, IntSize); // skip the loop counter
			dropChange = Drop(Vec);

			addFromVolatile = Increase(Vec(Reg), prop(propType, Vector));

			final getDiffRR:Instruction = GetDiff(Vec(Reg), prop(propType, Vector));
			getDiff = [vec.load(context), [getDiffRR]].flatten();

		case SetLength(length):
			divChange = getDivChange(false);
			pushChange = Push(Float(Reg));
			peekChange = Peek(Float, IntSize); // skip the loop counter
			dropChange = Drop(Float);

			addFromVolatile = Increase(Float(Reg), prop(propType, Length));

			final getDiffRR:Instruction = GetDiff(Float(Reg), prop(propType, Length));
			getDiff = length.load(context);
			getDiff.push(getDiffRR);

		case SetAngle(angle):
			divChange = getDivChange(false);
			pushChange = Push(Float(Reg));
			peekChange = Peek(Float, IntSize); // skip the loop counter
			dropChange = Drop(Float);

			addFromVolatile = Increase(Float(Reg), prop(propType, Angle));

			final getDiffRR:Instruction = GetDiff(Float(Reg), prop(propType, Angle));
			getDiff = angle.load(context);
			getDiff.push(getDiffRR);
		}

		final prepare: AssemblyCode = getDiff.concat(divChange).concat([pushChange]);

		final body: AssemblyCode = [
			Break,
			peekChange,
			addFromVolatile
		];
		// frames should be already loaded to int register in getDivChange()
		final loopedBody = constructLoop(context, Push(Int(Reg)), body);

		final complete: AssemblyCode = [dropChange];

		return [
			prepare,
			loopedBody,
			complete
		].flatten();
	}
}

@:ripper_verified
class SetActorVectorLinear extends SetActorPropertyLinear implements ripper.Data {
	public function new(
		propType: ActorPropertyType,
		vec: VecExpression,
		frames: IntExpression,
		?matrix: Transformation
	) {
		super(propType, SetVector(vec, matrix), frames);
	}

	/**
		Applies transformation on the vector to be set.
	**/
	public function transform(matrix: Transformation): SetActorVectorLinear {
		return switch operation {
		case SetVector(vec, mat):
			new SetActorVectorLinear(
				propType,
				vec,
				frames,
				if (mat != null) Transformation.multiply(mat, matrix) else matrix
			);
		default:
			throw "Invalid operation in SetActorVectorLinear class.";
		}
	}

	public function translate(x: FloatExpression, y: FloatExpression): SetActorVectorLinear
		return this.transform(Transformation.createTranslate(x, y));

	public function rotate(angle: AngleExpression): SetActorVectorLinear
		return this.transform(Transformation.createRotate(angle));

	public function scale(x: FloatExpression, y: FloatExpression): SetActorVectorLinear
		return this.transform(Transformation.createScale(x, y));
}

/**
	Represents a "set" operation on actor's property.
**/
private enum ActorPropertySetOperation {
	SetVector(arg: VecExpression, ?mat: Transformation);
	// SetX(arg: FloatExpression);
	// SetY(arg: FloatExpression);
	SetLength(arg: FloatExpression);
	SetAngle(arg: AngleExpression);
}
