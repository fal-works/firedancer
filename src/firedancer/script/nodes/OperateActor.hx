package firedancer.script.nodes;

import firedancer.assembly.Operand;
import firedancer.assembly.AssemblyStatement;
import firedancer.types.NInt;
import firedancer.assembly.AssemblyCode;
import firedancer.script.expression.*;
import firedancer.bytecode.internal.Constants.LEN32;

/**
	Operates actor's attribute (e.g. position).
**/
class OperateActor implements ripper.Data implements AstNode {
	/**
		Creates an `AssemblyCode` instance from `attribute` and `operation`.
	**/
	public static function createAssembly(
		attribute: ActorAttribute,
		operation: ActorAttributeOperation
	): AssemblyCode {
		return switch attribute {
			case Position:
				switch operation {
					case SetVector(e): e.use(SetPositionC, SetPositionV);
					case AddVector(e): e.use(AddPositionC, AddPositionV);
					case SetLength(e): e.use(SetDistanceC, SetDistanceV);
					case AddLength(e): e.use(AddDistanceC, AddDistanceV);
					case SetAngle(e): e.use(SetBearingC, SetBearingV);
					case AddAngle(e): e.use(AddBearingC, AddBearingV);
				}
			case Velocity:
				switch operation {
					case SetVector(e): e.use(SetVelocityC, SetVelocityV);
					case AddVector(e): e.use(AddVelocityC, AddVelocityV);
					case SetLength(e): e.use(SetSpeedC, SetSpeedV);
					case AddLength(e): e.use(AddSpeedC, AddSpeedV);
					case SetAngle(e): e.use(SetDirectionC, SetDirectionV);
					case AddAngle(e): e.use(AddDirectionC, AddDirectionV);
				}
			case ShotPosition:
				switch operation {
					case SetVector(e): e.use(SetShotPositionC, SetShotPositionV);
					case AddVector(e): e.use(AddShotPositionC, AddShotPositionV);
					case SetLength(e): e.use(SetShotDistanceC, SetShotDistanceV);
					case AddLength(e): e.use(AddShotDistanceC, AddShotDistanceV);
					case SetAngle(e): e.use(SetShotBearingC, SetShotBearingV);
					case AddAngle(e): e.use(AddShotBearingC, AddShotBearingV);
				}
			case ShotVelocity:
				switch operation {
					case SetVector(e): e.use(SetShotVelocityC, SetShotVelocityV);
					case AddVector(e): e.use(AddShotVelocityC, AddShotVelocityV);
					case SetLength(e): e.use(SetShotSpeedC, SetShotSpeedV);
					case AddLength(e): e.use(AddShotSpeedC, AddShotSpeedV);
					case SetAngle(e): e.use(SetShotDirectionC, SetShotDirectionV);
					case AddAngle(e): e.use(AddShotDirectionC, AddShotDirectionV);
				}
		}
	}

	final attribute: ActorAttribute;
	final operation: ActorAttributeOperation;

	/**
		Performs this operation gradually in `frames`.
	**/
	public inline function frames(frames: NInt)
		return new OperateActorLinear(attribute, operation, frames);

	public inline function containsWait(): Bool
		return false;

	public function toAssembly(): AssemblyCode
		return createAssembly(attribute, operation);
}

class OperateActorLinear implements ripper.Data implements AstNode {
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

	public inline function containsWait(): Bool
		return true;

	public function toAssembly(): AssemblyCode {
		final frames = this.frames;
		var prepare: AssemblyCode;
		var body: AssemblyCode;
		var complete: AssemblyCode;

		switch operation {
			case AddVector(_) | AddLength(_) | AddAngle(_):
				prepare = [];
				body = [
					[breakFrame()],
					OperateActor.createAssembly(attribute, operation.divide(frames))
				].flatten();
				complete = [];
			default:
				final ret = operation.relativeChange(attribute, frames);
				prepare = ret.prepare;
				body = ret.body;
				complete = ret.complete;
		}

		final loopedBody = if (this.loopUnrolling) {
			loopUnrolled(0...frames, _ -> body);
		} else loop(body, frames);

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
	SetVector(arg: VecArgument);
	AddVector(arg: VecArgument);
	// SetX(arg: FloatArgument);
	// AddX(arg: FloatArgument);
	// SetY(arg: FloatArgument);
	// AddY(arg: FloatArgument);
	SetLength(arg: FloatArgument);
	AddLength(arg: FloatArgument);
	SetAngle(arg: AzimuthArgument);
	AddAngle(arg: AzimuthDisplacementArgument);
}

class ActorAttributeOperationExtension {
	/**
		Divides the value to be added by `divisor`.

		Only for ADD operations (such as `AddVector`).
	**/
	public static function divide(addOperation: ActorAttributeOperation, divisor: Int) {
		return switch addOperation {
			case AddVector(arg): AddVector(arg.divide(divisor));
			case AddLength(arg): AddLength(arg.divide(divisor));
			case AddAngle(arg): AddAngle(arg.divide(divisor));
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
		attribute: ActorAttribute,
		frames: NInt
	) {
		var calcRelative: AssemblyCode; // Calculate total change (before the loop)
		var multChangeVCS: AssemblyStatement; // Get change rate (before the loop)
		var peekChange: AssemblyStatement; // Peek change rate (in the loop)
		var addFromVolatile: Opcode; // Apply change rate (in the loop)
		var dropChange: AssemblyStatement; // Drop change rate (after the loop)

		switch setOperation {
			case SetVector(arg):
				multChangeVCS = statement(MultVecVCS, [Float(1.0 / frames)]);
				peekChange = peekVec(LEN32); // skip the loop counter
				dropChange = dropVec();

				addFromVolatile = switch attribute {
					case Position: AddPositionV;
					case Velocity: AddVelocityV;
					case ShotPosition: AddShotPositionV;
					case ShotVelocity: AddShotVelocityV;
				}

				switch arg.toExpression() {
					case CartesianConstant(x, y):
						final opcode = switch attribute {
							case Position: CalcRelativePositionCV;
							case Velocity: CalcRelativeVelocityCV;
							case ShotPosition: CalcRelativeShotPositionCV;
							case ShotVelocity: CalcRelativeShotVelocityCV;
						};
						final operands:Array<Operand> = [Vec(x, y)];
						calcRelative = statement(opcode, operands);
					case CartesianExpression(x, y):
						throw "";
					case PolarConstant(length, angle):
						final opcode = switch attribute {
							case Position: CalcRelativePositionCV;
							case Velocity: CalcRelativeVelocityCV;
							case ShotPosition: CalcRelativeShotPositionCV;
							case ShotVelocity: CalcRelativeShotVelocityCV;
						};
						final x = length * angle.cos();
						final y = length * angle.sin();
						final operands:Array<Operand> = [Vec(x, y)];
						calcRelative = statement(opcode, operands);
					case PolarExpression(length, angle):
						throw "";
					case Variable(loadVolatileOpcode):
						final calcRelativeVV = switch attribute {
							case Position: CalcRelativePositionVV;
							case Velocity: CalcRelativeVelocityVV;
							case ShotPosition: CalcRelativeShotPositionVV;
							case ShotVelocity: CalcRelativeShotVelocityVV;
						};
						calcRelative = [statement(loadVolatileOpcode), statement(calcRelativeVV)];
				}
			case SetLength(arg):
				multChangeVCS = statement(MultFloatVCS, [Float(1.0 / frames)]);
				peekChange = peekFloat(LEN32); // skip the loop counter
				dropChange = dropFloat();

				addFromVolatile = switch attribute {
					case Position: AddDistanceV;
					case Velocity: AddSpeedV;
					case ShotPosition: AddShotDistanceV;
					case ShotVelocity: AddShotSpeedV;
				}

				switch arg.toExpression() {
					case Constant(value):
						final opcode = switch attribute {
							case Position: CalcRelativeDistanceCV;
							case Velocity: CalcRelativeSpeedCV;
							case ShotPosition: CalcRelativeShotDistanceCV;
							case ShotVelocity: CalcRelativeShotSpeedCV;
						};
						final operands:Array<Operand> = [Float(value)];
						calcRelative = statement(opcode, operands);
					case Variable(loadVolatileOpcode):
						final calcRelativeVV = switch attribute {
							case Position: CalcRelativeDistanceVV;
							case Velocity: CalcRelativeSpeedVV;
							case ShotPosition: CalcRelativeShotDistanceVV;
							case ShotVelocity: CalcRelativeShotDirectionVV;
						}
						calcRelative = [
							statement(loadVolatileOpcode),
							statement(calcRelativeVV)
						];
				}
			case SetAngle(arg):
				multChangeVCS = statement(MultFloatVCS, [Float(1.0 / frames)]);
				peekChange = peekFloat(LEN32); // skip the loop counter
				dropChange = dropFloat();

				addFromVolatile = switch attribute {
					case Position: AddBearingV;
					case Velocity: AddDirectionV;
					case ShotPosition: AddShotBearingV;
					case ShotVelocity: AddShotDirectionV;
				}

				switch arg.toExpression() {
					case Constant(value):
						final opcode = switch attribute {
							case Position: CalcRelativeBearingCV;
							case Velocity: CalcRelativeDirectionCV;
							case ShotPosition: CalcRelativeShotBearingCV;
							case ShotVelocity: CalcRelativeShotDirectionCV;
						};
						final operands:Array<Operand> = [Float(value.toRadians())];
						calcRelative = statement(opcode, operands);
					case Variable(loadVolatileOpcode):
						final calcRelativeVV = switch attribute {
							case Position: CalcRelativeBearingVV;
							case Velocity: CalcRelativeDirectionVV;
							case ShotPosition: CalcRelativeShotBearingVV;
							case ShotVelocity: CalcRelativeShotDirectionVV;
						}
						calcRelative = [
							statement(loadVolatileOpcode),
							statement(calcRelativeVV)
						];
				}
			default: throw "Unsupported operation.";
		}

		final prepare: AssemblyCode = calcRelative.concat([multChangeVCS]);
		final body: AssemblyCode = [
			breakFrame(),
			peekChange,
			statement(addFromVolatile)
		];
		final complete: AssemblyCode = [dropChange];

		return {
			prepare: prepare,
			body: body,
			complete: complete
		};
	}
}
