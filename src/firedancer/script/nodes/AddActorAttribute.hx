package firedancer.script.nodes;

import firedancer.types.ActorAttributeType;
import firedancer.assembly.operation.GeneralOperation;
import firedancer.assembly.operation.CalcOperation;
import firedancer.assembly.operation.WriteOperation;
import firedancer.assembly.Instruction;
import firedancer.assembly.AssemblyCode;
import firedancer.bytecode.internal.Constants.LEN32;
import firedancer.script.expression.*;

/**
	Operates actor's attribute (e.g. position).
**/
@:ripper_verified
class AddActorAttribute extends AstNode implements ripper.Data {
	final attribute: ActorAttributeType;
	final operation: ActorAttributeAddOperation;

	/**
		Performs this operation gradually in `frames`.
	**/
	public inline function frames(frames: IntExpression)
		return new AddActorAttributeLinear(attribute, operation, frames);

	override public inline function containsWait(): Bool
		return false;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final c = context;
		return switch attribute {
			case Position:
				switch operation {
					case AddVector(e): e.use(c, AddPositionC, AddPositionV);
					case AddLength(e): e.use(c, AddDistanceC, AddDistanceV);
					case AddAngle(e): e.use(c, AddBearingC, AddBearingV);
				}
			case Velocity:
				switch operation {
					case AddVector(e): e.use(c, AddVelocityC, AddVelocityV);
					case AddLength(e): e.use(c, AddSpeedC, AddSpeedV);
					case AddAngle(e): e.use(c, AddDirectionC, AddDirectionV);
				}
			case ShotPosition:
				switch operation {
					case AddVector(e): e.use(c, AddShotPositionC, AddShotPositionV);
					case AddLength(e): e.use(c, AddShotDistanceC, AddShotDistanceV);
					case AddAngle(e): e.use(c, AddShotBearingC, AddShotBearingV);
				}
			case ShotVelocity:
				switch operation {
					case AddVector(e): e.use(c, AddShotVelocityC, AddShotVelocityV);
					case AddLength(e): e.use(c, AddShotSpeedC, AddShotSpeedV);
					case AddAngle(e): e.use(c, AddShotDirectionC, AddShotDirectionV);
				}
		}
	}
}

@:ripper_verified
class AddActorAttributeLinear extends AstNode implements ripper.Data {
	final attribute: ActorAttributeType;
	final operation: ActorAttributeAddOperation;
	final frames: IntExpression;
	var loopUnrolling = false;

	/**
		Unrolls iteration when converting to `AssemblyCode`.
	**/
	public inline function unroll(): AddActorAttributeLinear {
		this.loopUnrolling = true;
		return this;
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

		var loadChange: AssemblyCode; // Load the total change (before the loop)
		var divChange: AssemblyCode; // Get change rate (before the loop)
		var pushChange: Instruction; // Push change rate (before the loop)
		var peekChange: Instruction; // Peek change rate (in the loop)
		var addFromVolatile: Opcode; // Apply change rate (in the loop)
		var dropChange: Instruction; // Drop change rate (after the loop)

		switch operation {
			case AddVector(vec):
				final immediate = vec.tryMakeImmediate();
				loadChange = if (immediate.isSome()) {
					instruction(LoadVecCV, [immediate.unwrap()]);
				} else {
					vec.loadToVolatile(context);
				}
				divChange = getDivChange(true);
				pushChange = instruction(PushVecV);
				peekChange = peekVec(LEN32); // skip the loop counter
				addFromVolatile = switch attribute {
					case Position: AddPositionV;
					case Velocity: AddVelocityV;
					case ShotPosition: AddShotPositionV;
					case ShotVelocity: AddShotVelocityV;
				};
				dropChange = dropVec();

			case AddLength(length):
				loadChange = switch length.toEnum() {
					case Constant(value):
						instruction(LoadFloatCV, [value.toImmediate()]);
					case Runtime(expression):
						expression.loadToVolatile(context);
				}
				divChange = getDivChange(false);
				pushChange = instruction(PushFloatV);
				peekChange = peekFloat(LEN32); // skip the loop counter
				addFromVolatile = switch attribute {
					case Position: AddDistanceV;
					case Velocity: AddSpeedV;
					case ShotPosition: AddShotDistanceV;
					case ShotVelocity: AddShotSpeedV;
				}
				dropChange = dropFloat();

			case AddAngle(angle):
				loadChange = switch angle.toEnum() {
					case Constant(value):
						instruction(LoadFloatCV, [value.toImmediate()]);
					case Runtime(expression):
						expression.loadToVolatile(context);
				}
				divChange = getDivChange(false);
				pushChange = instruction(PushFloatV);
				peekChange = peekFloat(LEN32); // skip the loop counter
				addFromVolatile = switch attribute {
					case Position: AddBearingV;
					case Velocity: AddDirectionV;
					case ShotPosition: AddShotBearingV;
					case ShotVelocity: AddShotDirectionV;
				}
				dropChange = dropFloat();
		}

		final prepare: AssemblyCode = loadChange.concat(divChange).concat([pushChange]);

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

/**
	Represents an operation on actor's attribute.
**/
@:using(firedancer.script.nodes.AddActorAttribute.ActorAttributeAddOperationExtension)
enum ActorAttributeAddOperation {
	AddVector(arg: VecExpression);
	// AddX(arg: FloatExpression);
	// AddY(arg: FloatExpression);
	AddLength(arg: FloatExpression);
	AddAngle(arg: AngleExpression);
}

class ActorAttributeAddOperationExtension {
	/**
		Divides the value to be added by `divisor`.
	**/
	public static function divide(
		addOperation: ActorAttributeAddOperation,
		divisor: IntExpression
	) {
		return switch addOperation {
			case AddVector(arg): AddVector(arg / divisor);
			case AddLength(arg): AddLength(arg / divisor);
			case AddAngle(arg): AddAngle(arg / divisor);
			default: throw "Unsupported operation.";
		}
	}
}
