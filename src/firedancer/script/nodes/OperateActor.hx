package firedancer.script.nodes;

import firedancer.types.NInt;
import firedancer.assembly.Opcode.*;
import firedancer.assembly.operation.ReadOperation;
import firedancer.assembly.operation.WriteOperation;
import firedancer.assembly.ConstantOperand;
import firedancer.assembly.Instruction;
import firedancer.assembly.AssemblyCode;
import firedancer.bytecode.internal.Constants.LEN32;
import firedancer.script.expression.*;

/**
	Operates actor's attribute (e.g. position).
**/
@:ripper_verified
class OperateActor extends AstNode implements ripper.Data {
	/**
		Creates an `AssemblyCode` instance from `attribute` and `operation`.
	**/
	public static function createAssembly(
		c: CompileContext,
		attribute: ActorAttribute,
		operation: ActorAttributeOperation
	): AssemblyCode {
		return switch attribute {
			case Position:
				switch operation {
					case SetVector(e): writeVec(c, e, SetPositionC, SetPositionV);
					case AddVector(e): writeVec(c, e, AddPositionC, AddPositionV);
					case SetLength(e): writeF(c, e, SetDistanceC, SetDistanceV);
					case AddLength(e): writeF(c, e, AddDistanceC, AddDistanceV);
					case SetAngle(e): writeA(c, e, SetBearingC, SetBearingV);
					case AddAngle(e): writeA(c, e, AddBearingC, AddBearingV);
				}
			case Velocity:
				switch operation {
					case SetVector(e): writeVec(c, e, SetVelocityC, SetVelocityV);
					case AddVector(e): writeVec(c, e, AddVelocityC, AddVelocityV);
					case SetLength(e): writeF(c, e, SetSpeedC, SetSpeedV);
					case AddLength(e): writeF(c, e, AddSpeedC, AddSpeedV);
					case SetAngle(e): writeA(c, e, SetDirectionC, SetDirectionV);
					case AddAngle(e): writeA(c, e, AddDirectionC, AddDirectionV);
				}
			case ShotPosition:
				switch operation {
					case SetVector(e): writeVec(c, e, SetShotPositionC, SetShotPositionV);
					case AddVector(e): writeVec(c, e, AddShotPositionC, AddShotPositionV);
					case SetLength(e): writeF(c, e, SetShotDistanceC, SetShotDistanceV);
					case AddLength(e): writeF(c, e, AddShotDistanceC, AddShotDistanceV);
					case SetAngle(e): writeA(c, e, SetShotBearingC, SetShotBearingV);
					case AddAngle(e): writeA(c, e, AddShotBearingC, AddShotBearingV);
				}
			case ShotVelocity:
				switch operation {
					case SetVector(e): writeVec(c, e, SetShotVelocityC, SetShotVelocityV);
					case AddVector(e): writeVec(c, e, AddShotVelocityC, AddShotVelocityV);
					case SetLength(e): writeF(c, e, SetShotSpeedC, SetShotSpeedV);
					case AddLength(e): writeF(c, e, AddShotSpeedC, AddShotSpeedV);
					case SetAngle(e): writeA(c, e, SetShotDirectionC, SetShotDirectionV);
					case AddAngle(e): writeA(c, e, AddShotDirectionC, AddShotDirectionV);
				}
		}
	}

	static extern inline function writeVec(
		context: CompileContext,
		expr: VecExpression,
		opC: WriteOperation,
		opV: WriteOperation
	): AssemblyCode
		return expr.use(context, write(opC), write(opV));

	static extern inline function writeF(
		context: CompileContext,
		expr: FloatExpression,
		opC: WriteOperation,
		opV: WriteOperation
	): AssemblyCode
		return expr.use(context, write(opC), write(opV));

	static extern inline function writeA(
		context: CompileContext,
		expr: AngleExpression,
		opC: WriteOperation,
		opV: WriteOperation
	): AssemblyCode
		return expr.use(context, write(opC), write(opV));

	final attribute: ActorAttribute;
	final operation: ActorAttributeOperation;

	/**
		Performs this operation gradually in `frames`.
	**/
	public inline function frames(frames: NInt)
		return new OperateActorLinear(attribute, operation, frames);

	override public inline function containsWait(): Bool
		return false;

	override public function toAssembly(context: CompileContext): AssemblyCode
		return createAssembly(context, attribute, operation);
}

@:ripper_verified
class OperateActorLinear extends AstNode implements ripper.Data {
	final attribute: ActorAttribute;
	final operation: ActorAttributeOperation;
	final frames: NInt;
	var loopUnrolling = false;

	/**
		Unrolls iteration when converting to `AssemblyCode`.
	**/
	public inline function unroll(): OperateActorLinear {
		this.loopUnrolling = true;
		return this;
	}

	override public inline function containsWait(): Bool
		return true;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final frames = this.frames;
		var prepare: AssemblyCode;
		var body: AssemblyCode;
		var complete: AssemblyCode;

		switch operation {
			case AddVector(_) | AddLength(_) | AddAngle(_):
				prepare = [];
				body = [
					[breakFrame()],
					OperateActor.createAssembly(context, attribute, operation.divide(frames))
				].flatten();
				complete = [];
			default:
				final ret = operation.relativeChange(context, attribute, frames);
				prepare = ret.prepare;
				body = ret.body;
				complete = ret.complete;
		}

		final loopedBody = if (this.loopUnrolling) {
			loopUnrolled(0...frames, _ -> body);
		} else loop(context, body, frames);

		return [
			prepare,
			loopedBody,
			complete
		].flatten();
	}
}

/**
	Type of actor's attribute to be operated.
**/
enum abstract ActorAttribute(Int) {
	final Position;
	final Velocity;
	final ShotPosition;
	final ShotVelocity;
}

/**
	Represents an operation on actor's attribute.
**/
@:using(firedancer.script.nodes.OperateActor.ActorAttributeOperationExtension)
enum ActorAttributeOperation {
	SetVector(arg: VecExpression);
	AddVector(arg: VecExpression);
	// SetX(arg: FloatExpression);
	// AddX(arg: FloatExpression);
	// SetY(arg: FloatExpression);
	// AddY(arg: FloatExpression);
	SetLength(arg: FloatExpression);
	AddLength(arg: FloatExpression);
	SetAngle(arg: AngleExpression);
	AddAngle(arg: AngleExpression);
}

class ActorAttributeOperationExtension {
	/**
		Divides the value to be added by `divisor`.

		Only for ADD operations (such as `AddVector`).
	**/
	public static function divide(addOperation: ActorAttributeOperation, divisor: Int) {
		return switch addOperation {
			case AddVector(arg): AddVector(arg / divisor);
			case AddLength(arg): AddLength(arg / divisor);
			case AddAngle(arg): AddAngle(arg / divisor);
			default: throw "Unsupported operation.";
		}
	}

	/**
		Creates loop components for constructing `AssemblyCode` that gradually changes actor's attribute
		relatively from a start value.

		Only for SET operations (such as `SetVector`).
	**/
	public static function relativeChange(
		setOperation: ActorAttributeOperation,
		context: CompileContext,
		attribute: ActorAttribute,
		frames: NInt
	) {
		var calcRelative: AssemblyCode; // Calculate total change (before the loop)
		var multChange: Instruction; // Get change rate (before the loop)
		var pushChange: Instruction; // Push change rate (before the loop)
		var peekChange: Instruction; // Peek change rate (in the loop)
		var addFromVolatile: Opcode; // Apply change rate (in the loop)
		var dropChange: Instruction; // Drop change rate (after the loop)

		switch setOperation {
			case SetVector(vec):
				multChange = instruction(calc(MultVecVCV), [Float(1.0 / frames)]);
				pushChange = instruction(general(PushVecV));
				peekChange = peekVec(LEN32); // skip the loop counter
				dropChange = dropVec();

				addFromVolatile = switch attribute {
					case Position: write(AddPositionV);
					case Velocity: write(AddVelocityV);
					case ShotPosition: write(AddShotPositionV);
					case ShotVelocity: write(AddShotVelocityV);
				};

				final const = vec.tryGetConstantOperand();
				if (const.isSome()) {
					final calcRelativeCV: ReadOperation = switch attribute {
						case Position: CalcRelativePositionCV;
						case Velocity: CalcRelativeVelocityCV;
						case ShotPosition: CalcRelativeShotPositionCV;
						case ShotVelocity: CalcRelativeShotVelocityCV;
					};
					calcRelative = instruction(read(calcRelativeCV), [const.unwrap()]);
				} else {
					final calcRelativeVV: ReadOperation = switch attribute {
						case Position: CalcRelativePositionVV;
						case Velocity: CalcRelativeVelocityVV;
						case ShotPosition: CalcRelativeShotPositionVV;
						case ShotVelocity: CalcRelativeShotVelocityVV;
					};
					calcRelative = [
						vec.loadToVolatile(context),
						[instruction(read(calcRelativeVV))]
					].flatten();
				}

			case SetLength(length):
				multChange = instruction(calc(MultFloatVCV), [Float(1.0 / frames)]);
				pushChange = instruction(general(PushFloatV));
				peekChange = peekFloat(LEN32); // skip the loop counter
				dropChange = dropFloat();

				addFromVolatile = switch attribute {
					case Position: write(AddDistanceV);
					case Velocity: write(AddSpeedV);
					case ShotPosition: write(AddShotDistanceV);
					case ShotVelocity: write(AddShotSpeedV);
				}

				switch length.toEnum() {
					case Constant(value):
						final operation:ReadOperation = switch attribute {
							case Position: CalcRelativeDistanceCV;
							case Velocity: CalcRelativeSpeedCV;
							case ShotPosition: CalcRelativeShotDistanceCV;
							case ShotVelocity: CalcRelativeShotSpeedCV;
						};
						final operands:Array<ConstantOperand> = [value.toOperand()];
						calcRelative = instruction(read(operation), operands);
					case Runtime(expression):
						final calcRelativeVV:ReadOperation = switch attribute {
							case Position: CalcRelativeDistanceVV;
							case Velocity: CalcRelativeSpeedVV;
							case ShotPosition: CalcRelativeShotDistanceVV;
							case ShotVelocity: CalcRelativeShotDirectionVV;
						}
						calcRelative = expression.loadToVolatile(context);
						calcRelative.push(instruction(read(calcRelativeVV)));
				}

			case SetAngle(angle):
				multChange = instruction(calc(MultFloatVCV), [Float(1.0 / frames)]);
				pushChange = instruction(general(PushFloatV));
				peekChange = peekFloat(LEN32); // skip the loop counter
				dropChange = dropFloat();

				addFromVolatile = switch attribute {
					case Position: write(AddBearingV);
					case Velocity: write(AddDirectionV);
					case ShotPosition: write(AddShotBearingV);
					case ShotVelocity: write(AddShotDirectionV);
				}

				switch angle.toEnum() {
					case Constant(value):
						final operation:ReadOperation = switch attribute {
							case Position: CalcRelativeBearingCV;
							case Velocity: CalcRelativeDirectionCV;
							case ShotPosition: CalcRelativeShotBearingCV;
							case ShotVelocity: CalcRelativeShotDirectionCV;
						};
						final operands:Array<ConstantOperand> = [value.toOperand()];
						calcRelative = instruction(read(operation), operands);
					case Runtime(expression):
						final calcRelativeVV:ReadOperation = switch attribute {
							case Position: CalcRelativeBearingVV;
							case Velocity: CalcRelativeDirectionVV;
							case ShotPosition: CalcRelativeShotBearingVV;
							case ShotVelocity: CalcRelativeShotDirectionVV;
						}
						calcRelative = expression.loadToVolatile(context);
						calcRelative.push(instruction(read(calcRelativeVV)));
				}

			default: throw "Unsupported operation.";
		}

		final prepare: AssemblyCode = calcRelative.concat([multChange, pushChange]);
		final body: AssemblyCode = [
			breakFrame(),
			peekChange,
			instruction(addFromVolatile)
		];
		final complete: AssemblyCode = [dropChange];

		return {
			prepare: prepare,
			body: body,
			complete: complete
		};
	}
}
