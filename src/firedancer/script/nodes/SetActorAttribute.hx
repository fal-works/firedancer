package firedancer.script.nodes;

import firedancer.types.ActorAttributeType;
import firedancer.types.NInt;
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
	public function frames(frames: NInt)
		return new SetActorAttributeLinear(attribute, operation, frames);

	override public inline function containsWait(): Bool
		return false;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final c = context;

		return switch attribute {
			case Position:
				switch operation {
					case SetVector(e): e.use(c, SetPositionC, SetPositionV);
					case SetLength(e): e.use(c, SetDistanceC, SetDistanceV);
					case SetAngle(e): e.use(c, SetBearingC, SetBearingV);
				}
			case Velocity:
				switch operation {
					case SetVector(e): e.use(c, SetVelocityC, SetVelocityV);
					case SetLength(e): e.use(c, SetSpeedC, SetSpeedV);
					case SetAngle(e): e.use(c, SetDirectionC, SetDirectionV);
				}
			case ShotPosition:
				switch operation {
					case SetVector(e): e.use(c, SetShotPositionC, SetShotPositionV);
					case SetLength(e): e.use(c, SetShotDistanceC, SetShotDistanceV);
					case SetAngle(e): e.use(c, SetShotBearingC, SetShotBearingV);
				}
			case ShotVelocity:
				switch operation {
					case SetVector(e): e.use(c, SetShotVelocityC, SetShotVelocityV);
					case SetLength(e): e.use(c, SetShotSpeedC, SetShotSpeedV);
					case SetAngle(e): e.use(c, SetShotDirectionC, SetShotDirectionV);
				}
		}
	}
}

@:ripper_verified
class SetActorAttributeLinear extends AstNode implements ripper.Data {
	final attribute: ActorAttributeType;
	final operation: ActorAttributeSetOperation;
	final frames: NInt;
	var loopUnrolling = false;

	/**
		Unrolls iteration when converting to `AssemblyCode`.
	**/
	public inline function unroll(): SetActorAttributeLinear {
		this.loopUnrolling = true;
		return this;
	}

	override public inline function containsWait(): Bool
		return true;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final frames = this.frames;

		var calcRelative: AssemblyCode; // Calculate total change (before the loop)
		var multChange: Instruction; // Get change rate (before the loop)
		var pushChange: Instruction; // Push change rate (before the loop)
		var peekChange: Instruction; // Peek change rate (in the loop)
		var addFromVolatile: Opcode; // Apply change rate (in the loop)
		var dropChange: Instruction; // Drop change rate (after the loop)

		switch operation {
			case SetVector(vec):
				multChange = instruction(MultVecVCV, [Float(1.0 / frames)]);
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
					calcRelative = [
						vec.loadToVolatile(context),
						[instruction(calcRelativeVV)]
					].flatten();
				}

			case SetLength(length):
				multChange = instruction(MultFloatVCV, [Float(1.0 / frames)]);
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
				multChange = instruction(MultFloatVCV, [Float(1.0 / frames)]);
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

		final prepare: AssemblyCode = calcRelative.concat([multChange, pushChange]);

		final body: AssemblyCode = [
			breakFrame(),
			peekChange,
			instruction(addFromVolatile)
		];
		final loopedBody = if (this.loopUnrolling) {
			loopUnrolled(0...frames, _ -> body);
		} else loop(context, body, frames);

		final complete: AssemblyCode = [dropChange];

		return [
			prepare,
			loopedBody,
			complete
		].flatten();
	}
}

/**
	Represents a "set" operation on actor's attribute.
**/
private enum ActorAttributeSetOperation {
	SetVector(arg: VecExpression);
	// SetX(arg: FloatExpression);
	// SetY(arg: FloatExpression);
	SetLength(arg: FloatExpression);
	SetAngle(arg: AngleExpression);
}
