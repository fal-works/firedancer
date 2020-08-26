package firedancer.script.nodes;

import firedancer.vm.Constants.IntSize;
import firedancer.assembly.Instruction;
import firedancer.assembly.AssemblyCode;
import firedancer.assembly.types.ActorProperty.create as prop;
import firedancer.assembly.types.ActorPropertyType;
import firedancer.script.expression.*;

/**
	Operates actor's property (e.g. position).
**/
@:ripper_verified
class AddActorProperty extends AstNode implements ripper.Data {
	final propType: ActorPropertyType;
	final operation: ActorPropertyAddOperation;

	/**
		Performs this operation gradually in `frames`.
	**/
	public inline function frames(frames: IntExpression)
		return new AddActorPropertyLinear(propType, operation, frames);

	override public inline function containsWait(): Bool
		return false;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final c = context;
		return switch propType {
		case Position:
			switch operation {
			case AddVector(e): e.use(c, Increase(Vec(Reg), prop(Position, Vector)));
			case AddLength(e): e.use(c, Increase(Float(Reg), prop(Position, Length)));
			case AddAngle(e): e.use(c, Increase(Float(Reg), prop(Position, Angle)));
			}
		case Velocity:
			switch operation {
			case AddVector(e): e.use(c, Increase(Vec(Reg), prop(Velocity, Vector)));
			case AddLength(e): e.use(c, Increase(Float(Reg), prop(Velocity, Length)));
			case AddAngle(e): e.use(c, Increase(Float(Reg), prop(Velocity, Angle)));
			}
		case ShotPosition:
			switch operation {
			case AddVector(e): e.use(c, Increase(Vec(Reg), prop(ShotPosition, Vector)));
			case AddLength(e): e.use(c, Increase(Float(Reg), prop(ShotPosition, Length)));
			case AddAngle(e): e.use(c, Increase(Float(Reg), prop(ShotPosition, Angle)));
			}
		case ShotVelocity:
			switch operation {
			case AddVector(e): e.use(c, Increase(Vec(Reg), prop(ShotVelocity, Vector)));
			case AddLength(e): e.use(c, Increase(Float(Reg), prop(ShotVelocity, Length)));
			case AddAngle(e): e.use(c, Increase(Float(Reg), prop(ShotVelocity, Angle)));
			}
		}
	}
}

@:ripper_verified
class AddActorPropertyLinear extends AstNode implements ripper.Data {
	final propType: ActorPropertyType;
	final operation: ActorPropertyAddOperation;
	final frames: IntExpression;

	override public inline function containsWait(): Bool {
		final constFrames = this.frames.tryGetConstant();
		return if (constFrames.isSome()) 0 < constFrames.unwrap() else true;
	}

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final frames = this.frames;

		inline function getDivChange(isVec: Bool): AssemblyCode {
			final divRRR: Instruction = Div(isVec ? Vec(Reg) : Float(RegBuf), Float(Reg));
			final code: AssemblyCode = isVec ? [] : [Save(Float(Reg))];
			final loadFramesAsFloat = (frames : FloatExpression).loadToVolatile(context);
			code.pushFromArray(loadFramesAsFloat);
			code.push(divRRR);
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
			pushChange = Push(Vec(Reg));
			peekChange = Peek(Vec, IntSize); // skip the loop counter
			addFromVolatile = Increase(Vec(Reg), prop(propType, Vector));
			dropChange = Drop(Vec);

		case AddLength(length):
			loadChange = length.loadToVolatile(context);
			divChange = getDivChange(false);
			pushChange = Push(Float(Reg));
			peekChange = Peek(Float, IntSize); // skip the loop counter
			addFromVolatile = Increase(Float(Reg), prop(propType, Length));
			dropChange = Drop(Float);

		case AddAngle(angle):
			loadChange = angle.loadToVolatile(context);
			divChange = getDivChange(false);
			pushChange = Push(Float(Reg));
			peekChange = Peek(Float, IntSize); // skip the loop counter
			addFromVolatile = Increase(Float(Reg), prop(propType, Angle));
			dropChange = Drop(Float);
		}

		final prepare: AssemblyCode = loadChange.concat(divChange).concat([pushChange]);

		final body: AssemblyCode = [
			Break,
			peekChange,
			addFromVolatile
		];

		// frames should be already loaded to int register in getDivChange() if it's not a constant
		final loopedBody = constructLoop(context, Push(Int(Reg)), body);

		final complete: AssemblyCode = [dropChange];

		return [
			prepare,
			loopedBody,
			complete
		].flatten();
	}
}

/**
	Represents an operation on actor's property.
**/
@:using(firedancer.script.nodes.AddActorProperty.ActorPropertyAddOperationExtension)
enum ActorPropertyAddOperation {
	AddVector(arg: VecExpression);
	// AddX(arg: FloatExpression);
	// AddY(arg: FloatExpression);
	AddLength(arg: FloatExpression);
	AddAngle(arg: AngleExpression);
}

class ActorPropertyAddOperationExtension {
	/**
		Divides the value to be added by `divisor`.
	**/
	public static function divide(
		addOperation: ActorPropertyAddOperation,
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
