package firedancer.script.nodes;

import firedancer.types.ActorAttributeType;
import firedancer.assembly.Instruction;
import firedancer.assembly.AssemblyCode;
import firedancer.bytecode.internal.Constants.LEN32;
import firedancer.script.expression.*;

/**
	Sets actor's attribute (e.g. position).
**/
@:ripper_verified
class SetActorAttribute extends AstNode implements ripper.Data {
	final attribute: ActorAttributeType;
	final operation: ActorAttributeSetOperation;

	/**
		Performs this operation gradually in `frames`.
	**/
	public function frames(frames: IntExpression)
		return new SetActorAttributeLinear(attribute, operation, frames);

	override public inline function containsWait(): Bool
		return false;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final c = context;

		return switch attribute {
			case Position:
				switch operation {
					case SetVector(e, mat):
						if (mat != null) e = e.transform(mat);
						e.use(c, SetVector(Position, Vector, Vec(Reg)));
					case SetLength(e): e.use(c, SetVector(Position, Length, Float(Reg)));
					case SetAngle(e): e.use(c, SetVector(Position, Angle, Float(Reg)));
				}
			case Velocity:
				switch operation {
					case SetVector(e, mat):
						if (mat != null) e = e.transform(mat);
						e.use(c, SetVector(Velocity, Vector, Vec(Reg)));
					case SetLength(e): e.use(c, SetVector(Velocity, Length, Vec(Reg)));
					case SetAngle(e): e.use(c, SetVector(Velocity, Angle, Vec(Reg)));
				}
			case ShotPosition:
				switch operation {
					case SetVector(e, mat):
						if (mat != null) e = e.transform(mat);
						e.use(c, SetVector(ShotPosition, Vector, Vec(Reg)));
					case SetLength(e): e.use(c, SetVector(ShotPosition, Length, Float(Reg)));
					case SetAngle(e): e.use(c, SetVector(ShotPosition, Angle, Float(Reg)));
				}
			case ShotVelocity:
				switch operation {
					case SetVector(e, mat):
						if (mat != null) e = e.transform(mat);
						e.use(c, SetVector(ShotVelocity, Vector, Vec(Reg)));
					case SetLength(e): e.use(c, SetVector(ShotVelocity, Length, Vec(Reg)));
					case SetAngle(e): e.use(c, SetVector(ShotVelocity, Angle, Vec(Reg)));
				}
		}
	}
}

@:ripper_verified
class SetActorVector extends SetActorAttribute implements ripper.Data {
	public function new(
		attribute: ActorAttributeType,
		vec: VecExpression,
		?matrix: Transformation
	) {
		super(attribute, SetVector(vec, matrix));
	}

	public function transform(matrix: Transformation): SetActorVector {
		return switch operation {
			case SetVector(vec, mat):
				new SetActorVector(
					attribute,
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

class SetActorAttributeLinear extends AstNode {
	final attribute: ActorAttributeType;
	final operation: ActorAttributeSetOperation;
	final frames: IntExpression;
	final loopUnrolling: Bool;

	public function new(
		attribute: ActorAttributeType,
		operation: ActorAttributeSetOperation,
		frames: IntExpression,
		loopUnrolling = false
	) {
		this.attribute = attribute;
		this.operation = operation;
		this.frames = frames;
		this.loopUnrolling = loopUnrolling;
	}

	/**
		Unrolls iteration when converting to `AssemblyCode`.
	**/
	public function unroll(): SetActorAttributeLinear {
		return new SetActorAttributeLinear(attribute, operation, frames, true);
	}

	override public inline function containsWait(): Bool {
		final constFrames = this.frames.tryGetConstant();
		return if (constFrames.isSome()) 0 < constFrames.unwrap() else true;
	}

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final frames = this.frames;
		final constFrames = frames.tryGetConstant();

		inline function getDivChange(isVec: Bool): AssemblyCode {
			return {
				final divVVV: Instruction = Div(isVec ? Vec(Reg) : Float(RegBuf), Float(Reg));
				final code: AssemblyCode = isVec ? [] : [Save(Float)];
				final loadFramesAsFloat = (frames : FloatExpression).loadToVolatile(context);
				code.pushFromArray(loadFramesAsFloat);
				code.push(divVVV);
				code;
			};
		}

		var calcRelative: AssemblyCode; // Calculate total change (before the loop)
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
				peekChange = Peek(Vec, LEN32); // skip the loop counter
				dropChange = Drop(Vec);

				addFromVolatile = SetVector(attribute, Vector, Vec(Reg));

				final calcRelativeVV: Instruction = CalcRelative(attribute, Vector, Vec(Reg));
				calcRelative = [vec.loadToVolatile(context), [calcRelativeVV]].flatten();

			case SetLength(length):
				divChange = getDivChange(false);
				pushChange = Push(Float(Reg));
				peekChange = Peek(Float, LEN32); // skip the loop counter
				dropChange = Drop(Float);

				addFromVolatile = AddVector(attribute, Length, Float(Reg));

				final calcRelativeVV: Instruction = CalcRelative(attribute, Length, Float(Reg));
				calcRelative = length.loadToVolatile(context);
				calcRelative.push(calcRelativeVV);

			case SetAngle(angle):
				divChange = getDivChange(false);
				pushChange = Push(Float(Reg));
				peekChange = Peek(Float, LEN32); // skip the loop counter
				dropChange = Drop(Float);

				addFromVolatile = AddVector(attribute, Angle, Float(Reg));

				final calcRelativeVV:Instruction = CalcRelative(attribute, Angle, Float(Reg));
				calcRelative = angle.loadToVolatile(context);
				calcRelative.push(calcRelativeVV);
		}

		final prepare: AssemblyCode = calcRelative.concat(divChange).concat([pushChange]);

		final body: AssemblyCode = [
			Break,
			peekChange,
			addFromVolatile
		];
		final loopedBody = if (constFrames.isSome()) {
			if (this.loopUnrolling) {
				loopUnrolled(0...constFrames.unwrap(), _ -> body);
			} else {
				final pushLoopCount = Push(Int(Imm(constFrames.unwrap())));
				constructLoop(context, pushLoopCount, body);
			}
		} else {
			// frames should be already loaded to int register in getDivChange() if it's not a constant
			constructLoop(context, Push(Int(Reg)), body);
		};

		final complete: AssemblyCode = [dropChange];

		return [
			prepare,
			loopedBody,
			complete
		].flatten();
	}
}

@:ripper_verified
class SetActorVectorLinear extends SetActorAttributeLinear implements ripper.Data {
	public function new(
		attribute: ActorAttributeType,
		vec: VecExpression,
		frames: IntExpression,
		loopUnrolling: Bool,
		?matrix: Transformation
	) {
		super(attribute, SetVector(vec, matrix), frames);
	}

	/**
		Unrolls iteration when converting to `AssemblyCode`.
	**/
	override public function unroll(): SetActorAttributeLinear {
		return switch operation {
			case SetVector(arg, mat):
				new SetActorVectorLinear(attribute, arg, frames, true, mat);
			default:
				throw "Invalid operation in SetActorVectorLinear class.";
		}
	}

	/**
		Applies transformation on the vector to be set.
	**/
	public function transform(matrix: Transformation): SetActorVectorLinear {
		return switch operation {
			case SetVector(vec, mat):
				new SetActorVectorLinear(
					attribute,
					vec,
					frames,
					loopUnrolling,
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
	Represents a "set" operation on actor's attribute.
**/
private enum ActorAttributeSetOperation {
	SetVector(arg: VecExpression, ?mat: Transformation);
	// SetX(arg: FloatExpression);
	// SetY(arg: FloatExpression);
	SetLength(arg: FloatExpression);
	SetAngle(arg: AngleExpression);
}
