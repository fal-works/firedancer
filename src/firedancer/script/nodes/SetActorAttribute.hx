package firedancer.script.nodes;

import firedancer.types.ActorAttributeType;
import firedancer.assembly.operation.GeneralOperation;
import firedancer.assembly.operation.CalcOperation;
import firedancer.assembly.operation.ReadOperation;
import firedancer.assembly.operation.WriteOperation;
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
						e.use(c, SetPositionC, SetPositionV);
					case SetLength(e): e.use(c, SetDistanceC, SetDistanceV);
					case SetAngle(e): e.use(c, SetBearingC, SetBearingV);
				}
			case Velocity:
				switch operation {
					case SetVector(e, mat):
						if (mat != null) e = e.transform(mat);
						e.use(c, SetVelocityC, SetVelocityV);
					case SetLength(e): e.use(c, SetSpeedC, SetSpeedV);
					case SetAngle(e): e.use(c, SetDirectionC, SetDirectionV);
				}
			case ShotPosition:
				switch operation {
					case SetVector(e, mat):
						if (mat != null) e = e.transform(mat);
						e.use(c, SetShotPositionC, SetShotPositionV);
					case SetLength(e): e.use(c, SetShotDistanceC, SetShotDistanceV);
					case SetAngle(e): e.use(c, SetShotBearingC, SetShotBearingV);
				}
			case ShotVelocity:
				switch operation {
					case SetVector(e, mat):
						if (mat != null) e = e.transform(mat);
						e.use(c, SetShotVelocityC, SetShotVelocityV);
					case SetLength(e): e.use(c, SetShotSpeedC, SetShotSpeedV);
					case SetAngle(e): e.use(c, SetShotDirectionC, SetShotDirectionV);
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
			return if (constFrames.isSome()) {
				final multVCV = isVec ? MultVecVCV : MultFloatVCV;
				instruction(multVCV, [Float(1.0 / constFrames.unwrap())]);
			} else {
				final divVVV = isVec ? DivVecVVV : DivFloatVVV;
				final code: AssemblyCode = isVec ? [] : [instruction(SaveFloatV)];
				final loadFramesAsFloat = (frames : FloatExpression).loadToVolatile(context);
				code.pushFromArray(loadFramesAsFloat);
				code.pushInstruction(divVVV);
				code;
			};
		}

		var calcRelative: AssemblyCode; // Calculate total change (before the loop)
		var divChange: AssemblyCode; // Get change rate (before the loop)
		var pushChange: Instruction; // Push change rate (before the loop)
		var peekChange: Instruction; // Peek change rate (in the loop)
		var addFromVolatile: Opcode; // Apply change rate (in the loop)
		var dropChange: Instruction; // Drop change rate (after the loop)

		switch operation {
			case SetVector(vec, mat):
				if (mat != null) vec = vec.transform(mat);

				divChange = getDivChange(true);
				pushChange = instruction(PushVecV);
				peekChange = peekVec(LEN32); // skip the loop counter
				dropChange = dropVec();

				addFromVolatile = switch attribute {
					case Position: AddPositionV;
					case Velocity: AddVelocityV;
					case ShotPosition: AddShotPositionV;
					case ShotVelocity: AddShotVelocityV;
				};

				final immediate = vec.tryMakeImmediate();
				if (immediate.isSome()) {
					final calcRelativeCV: ReadOperation = switch attribute {
						case Position: CalcRelativePositionCV;
						case Velocity: CalcRelativeVelocityCV;
						case ShotPosition: CalcRelativeShotPositionCV;
						case ShotVelocity: CalcRelativeShotVelocityCV;
					};
					calcRelative = instruction(calcRelativeCV, [immediate.unwrap()]);
				} else {
					final calcRelativeVV: ReadOperation = switch attribute {
						case Position: CalcRelativePositionVV;
						case Velocity: CalcRelativeVelocityVV;
						case ShotPosition: CalcRelativeShotPositionVV;
						case ShotVelocity: CalcRelativeShotVelocityVV;
					};
					calcRelative = [vec.loadToVolatile(context), [instruction(calcRelativeVV)]].flatten();
				}

			case SetLength(length):
				divChange = getDivChange(false);
				pushChange = instruction(PushFloatV);
				peekChange = peekFloat(LEN32); // skip the loop counter
				dropChange = dropFloat();

				addFromVolatile = switch attribute {
					case Position: AddDistanceV;
					case Velocity: AddSpeedV;
					case ShotPosition: AddShotDistanceV;
					case ShotVelocity: AddShotSpeedV;
				}

				switch length.toEnum() {
					case Constant(value):
						final operation:ReadOperation = switch attribute {
							case Position: CalcRelativeDistanceCV;
							case Velocity: CalcRelativeSpeedCV;
							case ShotPosition: CalcRelativeShotDistanceCV;
							case ShotVelocity: CalcRelativeShotSpeedCV;
						};
						calcRelative = instruction(operation, [value.toImmediate()]);
					case Runtime(expression):
						final calcRelativeVV:ReadOperation = switch attribute {
							case Position: CalcRelativeDistanceVV;
							case Velocity: CalcRelativeSpeedVV;
							case ShotPosition: CalcRelativeShotDistanceVV;
							case ShotVelocity: CalcRelativeShotDirectionVV;
						}
						calcRelative = expression.loadToVolatile(context);
						calcRelative.push(instruction(calcRelativeVV));
				}

			case SetAngle(angle):
				divChange = getDivChange(false);
				pushChange = instruction(PushFloatV);
				peekChange = peekFloat(LEN32); // skip the loop counter
				dropChange = dropFloat();

				addFromVolatile = switch attribute {
					case Position: AddBearingV;
					case Velocity: AddDirectionV;
					case ShotPosition: AddShotBearingV;
					case ShotVelocity: AddShotDirectionV;
				}

				switch angle.toEnum() {
					case Constant(value):
						final operation:ReadOperation = switch attribute {
							case Position: CalcRelativeBearingCV;
							case Velocity: CalcRelativeDirectionCV;
							case ShotPosition: CalcRelativeShotBearingCV;
							case ShotVelocity: CalcRelativeShotDirectionCV;
						};
						calcRelative = instruction(operation, [value.toImmediate()]);
					case Runtime(expression):
						final calcRelativeVV:ReadOperation = switch attribute {
							case Position: CalcRelativeBearingVV;
							case Velocity: CalcRelativeDirectionVV;
							case ShotPosition: CalcRelativeShotBearingVV;
							case ShotVelocity: CalcRelativeShotDirectionVV;
						}
						calcRelative = expression.loadToVolatile(context);
						calcRelative.push(instruction(calcRelativeVV));
				}
		}

		final prepare: AssemblyCode = calcRelative.concat(divChange).concat([pushChange]);

		final body: AssemblyCode = [
			breakFrame(),
			peekChange,
			instruction(addFromVolatile)
		];
		final loopedBody = if (constFrames.isSome()) {
			if (this.loopUnrolling) {
				loopUnrolled(0...constFrames.unwrap(), _ -> body);
			} else {
				final pushLoopCount = instruction(PushIntC, [Int(constFrames.unwrap())]);
				constructLoop(pushLoopCount, body);
			}
		} else {
			// frames should be already loaded to int register in getDivChange() if it's not a constant
			final pushLoopCount = instruction(PushIntV);
			constructLoop(pushLoopCount, body);
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
