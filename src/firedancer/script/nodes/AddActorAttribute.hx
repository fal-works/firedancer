package firedancer.script.nodes;

import firedancer.types.ActorAttributeType;
import firedancer.types.NInt;
import firedancer.assembly.operation.WriteOperation;
import firedancer.assembly.AssemblyCode;
import firedancer.script.expression.*;

/**
	Operates actor's attribute (e.g. position).
**/
@:ripper_verified
class AddActorAttribute extends AstNode implements ripper.Data {
	/**
		Creates an `AssemblyCode` instance from `attribute` and `operation`.
	**/
	public static function createAssembly(
		c: CompileContext,
		attribute: ActorAttributeType,
		operation: ActorAttributeOperation
	): AssemblyCode {
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

	final attribute: ActorAttributeType;
	final operation: ActorAttributeOperation;

	/**
		Performs this operation gradually in `frames`.
	**/
	public inline function frames(frames: NInt)
		return new AddActorAttributeLinear(attribute, operation, frames);

	override public inline function containsWait(): Bool
		return false;

	override public function toAssembly(context: CompileContext): AssemblyCode
		return createAssembly(context, attribute, operation);
}

@:ripper_verified
class AddActorAttributeLinear extends AstNode implements ripper.Data {
	final attribute: ActorAttributeType;
	final operation: ActorAttributeOperation;
	final frames: NInt;
	var loopUnrolling = false;

	/**
		Unrolls iteration when converting to `AssemblyCode`.
	**/
	public inline function unroll(): AddActorAttributeLinear {
		this.loopUnrolling = true;
		return this;
	}

	override public inline function containsWait(): Bool
		return true;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final frames = this.frames;

		final body: AssemblyCode = [
			[breakFrame()],
			AddActorAttribute.createAssembly(context, attribute, operation.divide(frames))
		].flatten();

		return if (this.loopUnrolling) {
			loopUnrolled(0...frames, _ -> body);
		} else loop(context, body, frames);
	}
}

/**
	Represents an operation on actor's attribute.
**/
@:using(firedancer.script.nodes.AddActorAttribute.ActorAttributeOperationExtension)
enum ActorAttributeOperation {
	AddVector(arg: VecExpression);
	// AddX(arg: FloatExpression);
	// AddY(arg: FloatExpression);
	AddLength(arg: FloatExpression);
	AddAngle(arg: AngleExpression);
}

class ActorAttributeOperationExtension {
	/**
		Divides the value to be added by `divisor`.
	**/
	public static function divide(addOperation: ActorAttributeOperation, divisor: Int) {
		return switch addOperation {
			case AddVector(arg): AddVector(arg / divisor);
			case AddLength(arg): AddLength(arg / divisor);
			case AddAngle(arg): AddAngle(arg / divisor);
			default: throw "Unsupported operation.";
		}
	}
}
