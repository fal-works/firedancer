package firedancer.script.nodes;

import firedancer.types.ActorAttributeType;
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
					case AddVector(e): e.use(c, AddVector(Position, Vector, Reg(Rvec)));
					case AddLength(e): e.use(c, AddVector(Position, Length, Reg(Rf)));
					case AddAngle(e): e.use(c, AddVector(Position, Angle, Reg(Rf)));
				}
			case Velocity:
				switch operation {
					case AddVector(e): e.use(c, AddVector(Velocity, Vector, Reg(Rvec)));
					case AddLength(e): e.use(c, AddVector(Velocity, Length, Reg(Rf)));
					case AddAngle(e): e.use(c, AddVector(Velocity, Angle, Reg(Rf)));
				}
			case ShotPosition:
				switch operation {
					case AddVector(e): e.use(c, AddVector(ShotPosition, Vector, Reg(Rvec)));
					case AddLength(e): e.use(c, AddVector(ShotPosition, Length, Reg(Rf)));
					case AddAngle(e): e.use(c, AddVector(ShotPosition, Angle, Reg(Rf)));
				}
			case ShotVelocity:
				switch operation {
					case AddVector(e): e.use(c, AddVector(ShotVelocity, Vector, Reg(Rvec)));
					case AddLength(e): e.use(c, AddVector(Velocity, Length, Reg(Rf)));
					case AddAngle(e): e.use(c, AddVector(Velocity, Angle, Reg(Rf)));
				}
		}
	}
}

@:ripper_verified
class AddActorAttributeLinear extends AstNode implements ripper.Data {
	final attribute: ActorAttributeType;
	final operation: ActorAttributeAddOperation;
	final frames: IntExpression;

	override public inline function containsWait(): Bool {
		final constFrames = this.frames.tryGetConstant();
		return if (constFrames.isSome()) 0 < constFrames.unwrap() else true;
	}

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final frames = this.frames;

		inline function getDivChange(isVec: Bool): AssemblyCode {
			final divVVV: Instruction = Div(Reg(isVec ? Rvec : Rfb), Reg(Rf));
			final code: AssemblyCode = isVec ? [] : [Save(Float)];
			final loadFramesAsFloat = (frames : FloatExpression).loadToVolatile(context);
			code.pushFromArray(loadFramesAsFloat);
			code.push(divVVV);
			return code;
		}

		var loadChange: AssemblyCode; // Load the total change (before the loop)
		var divChange: AssemblyCode; // Get change rate (before the loop)
		var pushChange: Instruction; // Push change rate (before the loop)
		var peekChange: Instruction; // Peek change rate (in the loop)
		var addFromVolatile: Instruction; // Apply change rate (in the loop)
		var dropChange: Instruction; // Drop change rate (after the loop)

		switch operation {
			case AddVector(vec):
				loadChange = vec.loadToVolatile(context);
				divChange = getDivChange(true);
				pushChange = Push(Reg(Rvec));
				peekChange = Peek(Vec, LEN32); // skip the loop counter
				addFromVolatile = AddVector(attribute, Vector, Reg(Rvec));
				dropChange = Drop(Vec);

			case AddLength(length):
				loadChange = length.loadToVolatile(context);
				divChange = getDivChange(false);
				pushChange = Push(Reg(Rf));
				peekChange = Peek(Float, LEN32); // skip the loop counter
				addFromVolatile = AddVector(attribute, Length, Reg(Rf));
				dropChange = Drop(Float);

			case AddAngle(angle):
				loadChange = angle.loadToVolatile(context);
				divChange = getDivChange(false);
				pushChange = Push(Reg(Rf));
				peekChange = Peek(Float, LEN32); // skip the loop counter
				addFromVolatile = AddVector(attribute, Angle, Reg(Rf));
				dropChange = Drop(Float);
		}

		final prepare: AssemblyCode = loadChange.concat(divChange).concat([pushChange]);

		final body: AssemblyCode = [
			Break,
			peekChange,
			addFromVolatile
		];

		// frames should be already loaded to int register in getDivChange() if it's not a constant
		final loopedBody = constructLoop(context, Push(Reg(Ri)), body);

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