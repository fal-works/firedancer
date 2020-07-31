package firedancer.bytecode;

import banker.binary.ByteStackData;
import haxe.Int32;
import banker.vector.Vector as RVec;
import banker.vector.WritableVector as Vec;
import broker.geometry.Point;
import firedancer.assembly.Opcode;
import firedancer.types.Emitter;
import firedancer.bytecode.internal.Constants.*;
import firedancer.common.MathStatics.*;
import firedancer.common.Vec2DStatics.*;

/**
	Virtual machine for executing bytecode.
**/
class Vm {
	static extern inline final infiniteLoopCheckThreshold = 4096;

	/**
		Runs firedancer bytecode.
	**/
	public static function run(
		bytecodeTable: RVec<Bytecode>,
		threads: ThreadList,
		xVec: Vec<Float>,
		yVec: Vec<Float>,
		vxVec: Vec<Float>,
		vyVec: Vec<Float>,
		vecIndex: UInt,
		emitter: Emitter,
		targetPosition: Point
	): Void {
		var code: BytecodeData;
		var codeLength: UInt;

		var codePos: UInt;
		var stack: ByteStackData;
		var stackSize: UInt;

		var volFloatPrev: Float;
		var volFloat: Float;
		var volX: Float;
		var volY: Float;

		inline function setVolFloat(v: Float): Void {
			volFloatPrev = volFloat;
			volFloat = v;
		}

		inline function setVolX(x: Float): Void
			volX = x;

		inline function setVolY(y: Float): Void
			volY = y;

		inline function setVolVec(x: Float, y: Float): Void {
			setVolX(x);
			setVolY(y);
		}

		inline function readOp(): Int32 {
			final opcode = code.getI32(codePos);
			println('${Opcode.from(opcode).toString()} (pos: $codePos)');
			codePos += LEN32;
			return opcode;
		}

		inline function readCodeI32(): Int32 {
			final v = code.getI32(codePos);
			codePos += LEN32;
			println('  read_int ... $v');
			return v;
		}

		inline function readCodeF64(): Float {
			final v = code.getF64(codePos);
			codePos += LEN64;
			println('  read_float ... $v');
			return v;
		}

		inline function pushInt(v: Int32): Void {
			stackSize = stack.pushI32(stackSize, v);
			println('  push_int -> ${stack.toHex(stackSize, true)}');
		}

		inline function pushFloat(v: Float): Void {
			stackSize = stack.pushF64(stackSize, v);
			println('  push_float -> ${stack.toHex(stackSize, true)}');
		}

		inline function pushVec(x: Float, y: Float): Void {
			stackSize = stack.pushF64(stackSize, x);
			stackSize = stack.pushF64(stackSize, y);
			println('  push_vec -> ${stack.toHex(stackSize, true)}');
		}

		inline function popInt(): Int32 {
			final ret = stack.popI32(stackSize);
			stackSize = ret.size;
			return ret.value;
		}

		inline function popFloat(): Float {
			final ret = stack.popF64(stackSize);
			stackSize = ret.size;
			return ret.value;
		}

		inline function peekInt(): Int32
			return stack.peekI32(stackSize);

		inline function peekFloat(): Float
			return stack.peekF64(stackSize);

		inline function peekFloatSkipped(bytesToSkip: Int): Float
			return stack.peekF64(stackSize - bytesToSkip);

		inline function peekVecSkipped(bytesToSkip: Int)
			return stack.peekVec2D64(stackSize - bytesToSkip);

		inline function dropInt(): Void {
			stackSize = stack.drop(stackSize, Bit32);
			println('  drop_int -> ${stack.toHex(stackSize, true)}');
		}

		inline function dropFloat(): Void {
			stackSize = stack.drop(stackSize, Bit64);
			println('  drop_int -> ${stack.toHex(stackSize, true)}');
		}

		inline function dropVec(): Void {
			stackSize = stack.drop2D(stackSize, Bit64);
			println('  drop_vec -> ${stack.toHex(stackSize, true)}');
		}

		inline function decrement(): Void {
			stack.decrement32(stackSize);
			println('  decrement ... ${stack.toHex(stackSize, true)}');
		}

		inline function getX(): Float
			return xVec[vecIndex];

		inline function getY(): Float
			return yVec[vecIndex];

		inline function getVx(): Float
			return vxVec[vecIndex];

		inline function getVy(): Float
			return vyVec[vecIndex];

		inline function setX(x: Float): Void
			xVec[vecIndex] = x;

		inline function setY(y: Float): Void
			yVec[vecIndex] = y;

		inline function setVx(vx: Float): Void
			vxVec[vecIndex] = vx;

		inline function setVy(vy: Float): Void
			vyVec[vecIndex] = vy;

		inline function addX(x: Float): Void
			xVec[vecIndex] += x;

		inline function addY(y: Float): Void
			yVec[vecIndex] += y;

		inline function addVx(vx: Float): Void
			vxVec[vecIndex] += vx;

		inline function addVy(vy: Float): Void
			vyVec[vecIndex] += vy;

		inline function setPosition(x: Float, y: Float): Void {
			setX(x);
			setY(y);
		}

		inline function addPosition(x: Float, y: Float): Void {
			addX(x);
			addY(y);
		}

		inline function setVelocity(vx: Float, vy: Float): Void {
			setVx(vx);
			setVy(vy);
		}

		inline function addVelocity(vx: Float, vy: Float): Void {
			addVx(vx);
			addVy(vy);
		}

		inline function getDistance(): Float
			return hypot(getX(), getY());

		inline function getBearing(): Float
			return atan2(getY(), getX());

		inline function getSpeed(): Float
			return hypot(getVx(), getVy());

		inline function getDirection(): Float
			return atan2(getVy(), getVx());

		inline function setDistance(value: Float): Void {
			final newPosition = setLength(getX(), getY(), value);
			setPosition(newPosition.x, newPosition.y);
		}

		inline function addDistance(value: Float): Void {
			final newPosition = addLength(getX(), getY(), value);
			setPosition(newPosition.x, newPosition.y);
		}

		inline function setBearing(value: Float): Void {
			final newPosition = setAngle(getX(), getY(), value);
			setPosition(newPosition.x, newPosition.y);
		}

		inline function addBearing(value: Float): Void {
			final newPosition = addAngle(getX(), getY(), value);
			setPosition(newPosition.x, newPosition.y);
		}

		inline function setSpeed(value: Float): Void {
			final newVelocity = setLength(getVx(), getVy(), value);
			setVelocity(newVelocity.x, newVelocity.y);
		}

		inline function addSpeed(value: Float): Void {
			final newVelocity = addLength(getVx(), getVy(), value);
			setVelocity(newVelocity.x, newVelocity.y);
		}

		inline function setDirection(value: Float): Void {
			final newVelocity = setAngle(getVx(), getVy(), value);
			setVelocity(newVelocity.x, newVelocity.y);
		}

		inline function addDirection(value: Float): Void {
			final newVelocity = addAngle(getVx(), getVy(), value);
			setVelocity(newVelocity.x, newVelocity.y);
		}

		for (i in 0...threads.length) {
			final thread = threads[i];
			if (!thread.active) continue;

			code = thread.code.unwrap();
			codeLength = thread.codeLength;

			codePos = thread.codePos;
			stack = thread.stack;
			stackSize = thread.stackSize;

			volFloatPrev = 0.0;
			volFloat = 0.0;
			volX = 0.0;
			volY = 0.0;

			#if debug
			var cnt = 0;
			#end

			do {
				if (codeLength <= codePos) {
					thread.deactivate();
					return;
				}

				switch readOp() {
					case PushInt:
						pushInt(readCodeI32());
					case PeekFloat:
						setVolFloat(peekFloatSkipped(readCodeI32()));
					case DropFloat:
						dropFloat();
					case PeekVec:
						final vec = peekVecSkipped(readCodeI32());
						setVolVec(vec.x, vec.y);
					case DropVec:
						dropVec();
					case CountDownBreak:
						if (0 != peekInt()) {
							decrement();
							codePos -= LEN32;
							break;
						} else {
							dropInt();
						}
					case Break:
						break;
					case Jump:
						final jumpLength = readCodeI32();
						codePos += jumpLength;
					case CountDownJump:
						if (0 != peekInt()) {
							decrement();
							codePos += LEN32; // skip the operand
						} else {
							dropInt();
							final jumpLength = readCodeI32();
							codePos += jumpLength;
						}
					case Decrement:
						decrement();
					case LoadFloatCV:
						setVolFloat(readCodeF64());
					case LoadVecCV:
						setVolVec(readCodeF64(), readCodeF64());
					case LoadVecXCV:
						setVolX(readCodeF64());
					case LoadVecYCV:
						setVolY(readCodeF64());
					case MultFloatVCS:
						final multiplier = readCodeF64();
						pushFloat(volFloat * multiplier);
					case MultVecVCS:
						final multiplier = readCodeF64();
						pushVec(volX * multiplier, volY * multiplier);
					case LoadTargetPositionV:
						setVolVec(targetPosition.x(), targetPosition.y());
					case LoadTargetXV:
						setVolX(targetPosition.x());
					case LoadTargetYV:
						setVolY(targetPosition.y());
					case LoadBearingToTargetV:
						setVolFloat(atan2(
							targetPosition.y() - getY(),
							targetPosition.x() - getX()
						));
					case CastCartesianVV:
						setVolVec(volFloatPrev, volFloat);
					case CastPolarVV:
						setVolVec(volFloatPrev * cos(volFloat), volFloatPrev * sin(volFloat));
					case SetPositionC:
						setPosition(readCodeF64(), readCodeF64());
					case AddPositionC:
						addPosition(readCodeF64(), readCodeF64());
					case SetVelocityC:
						setVelocity(readCodeF64(), readCodeF64());
					case AddVelocityC:
						addVelocity(readCodeF64(), readCodeF64());
					case SetPositionS:
						final vec = peekVecSkipped(0);
						setPosition(vec.x, vec.y);
					case AddPositionS:
						final vec = peekVecSkipped(0);
						addPosition(vec.x, vec.y);
					case SetVelocityS:
						final vec = peekVecSkipped(0);
						setPosition(vec.x, vec.y);
					case AddVelocityS:
						final vec = peekVecSkipped(0);
						addPosition(vec.x, vec.y);
					case SetPositionV:
						setPosition(volX, volY);
					case AddPositionV:
						addPosition(volX, volY);
					case SetVelocityV:
						setVelocity(volX, volY);
					case AddVelocityV:
						addVelocity(volX, volY);
					case CalcRelativePositionCV:
						setVolVec(readCodeF64() - getX(), readCodeF64() - getY());
					case CalcRelativeVelocityCV:
						setVolVec(readCodeF64() - getVx(), readCodeF64() - getVy());
					case CalcRelativePositionVV:
						setVolVec(volX - getX(), volY - getY());
					case CalcRelativeVelocityVV:
						setVolVec(volX - getVx(), volY - getVy());
					case SetDistanceC:
						setDistance(readCodeF64());
					case AddDistanceC:
						addDistance(readCodeF64());
					case SetBearingC:
						setBearing(readCodeF64());
					case AddBearingC:
						addBearing(readCodeF64());
					case SetSpeedC:
						setSpeed(readCodeF64());
					case AddSpeedC:
						addSpeed(readCodeF64());
					case SetDirectionC:
						setDirection(readCodeF64());
					case AddDirectionC:
						addDirection(readCodeF64());
					case SetDistanceS:
						setDistance(peekFloat());
					case AddDistanceS:
						addDistance(peekFloat());
					case SetBearingS:
						setBearing(peekFloat());
					case AddBearingS:
						addBearing(peekFloat());
					case SetSpeedS:
						setSpeed(peekFloat());
					case AddSpeedS:
						addSpeed(peekFloat());
					case SetDirectionS:
						setDirection(peekFloat());
					case AddDirectionS:
						addDirection(peekFloat());
					case SetDistanceV:
						setDistance(volFloat);
					case AddDistanceV:
						addDistance(volFloat);
					case SetBearingV:
						setBearing(volFloat);
					case AddBearingV:
						addBearing(volFloat);
					case SetSpeedV:
						setSpeed(volFloat);
					case AddSpeedV:
						addSpeed(volFloat);
					case SetDirectionV:
						setDirection(volFloat);
					case AddDirectionV:
						addDirection(volFloat);
					case CalcRelativeDistanceCV:
						setVolFloat(readCodeF64() - getDistance());
					case CalcRelativeBearingCV:
						setVolFloat(normalizeAngle(readCodeF64() - getBearing()));
					case CalcRelativeSpeedCV:
						setVolFloat(readCodeF64() - getSpeed());
					case CalcRelativeDirectionCV:
						setVolFloat(normalizeAngle(readCodeF64() - getDirection()));
					case CalcRelativeDistanceVV:
						setVolFloat(volFloat - getDistance());
					case CalcRelativeBearingVV:
						setVolFloat(normalizeAngle(volFloat - getBearing()));
					case CalcRelativeSpeedVV:
						setVolFloat(volFloat - getSpeed());
					case CalcRelativeDirectionVV:
						setVolFloat(normalizeAngle(volFloat - getDirection()));
					case SetShotPositionC:
						thread.setShotPosition(readCodeF64(), readCodeF64());
					case AddShotPositionC:
						thread.addShotPosition(readCodeF64(), readCodeF64());
					case SetShotVelocityC:
						thread.setShotVelocity(readCodeF64(), readCodeF64());
					case AddShotVelocityC:
						thread.addShotVelocity(readCodeF64(), readCodeF64());
					case SetShotPositionS:
						final vec = peekVecSkipped(0);
						thread.setShotPosition(vec.x, vec.y);
					case AddShotPositionS:
						final vec = peekVecSkipped(0);
						thread.addShotPosition(vec.x, vec.y);
					case SetShotVelocityS:
						final vec = peekVecSkipped(0);
						thread.setShotVelocity(vec.x, vec.y);
					case AddShotVelocityS:
						final vec = peekVecSkipped(0);
						thread.addShotVelocity(vec.x, vec.y);
					case SetShotPositionV:
						thread.setShotPosition(volX, volY);
					case AddShotPositionV:
						thread.addShotPosition(volX, volY);
					case SetShotVelocityV:
						thread.setShotVelocity(volX, volY);
					case AddShotVelocityV:
						thread.addShotVelocity(volX, volY);
					case CalcRelativeShotPositionCV:
						setVolVec(readCodeF64() - thread.shotX, readCodeF64() - thread.shotY);
					case CalcRelativeShotVelocityCV:
						setVolVec(
							readCodeF64() - thread.shotVx,
							readCodeF64() - thread.shotVy
						);
					case CalcRelativeShotPositionVV:
						setVolVec(volX - thread.shotX, volY - thread.shotY);
					case CalcRelativeShotVelocityVV:
						setVolVec(volX - thread.shotVx, volY - thread.shotVy);
					case SetShotDistanceC:
						thread.setShotDistance(readCodeF64());
					case AddShotDistanceC:
						thread.addShotDistance(readCodeF64());
					case SetShotBearingC:
						thread.setShotBearing(readCodeF64());
					case AddShotBearingC:
						thread.addShotBearing(readCodeF64());
					case SetShotSpeedC:
						thread.setShotSpeed(readCodeF64());
					case AddShotSpeedC:
						thread.addShotSpeed(readCodeF64());
					case SetShotDirectionC:
						thread.setShotDirection(readCodeF64());
					case AddShotDirectionC:
						thread.addShotDirection(readCodeF64());
					case SetShotDistanceS:
						thread.setShotDistance(peekFloat());
					case AddShotDistanceS:
						thread.addShotDistance(peekFloat());
					case SetShotBearingS:
						thread.setShotBearing(peekFloat());
					case AddShotBearingS:
						thread.addShotBearing(peekFloat());
					case SetShotSpeedS:
						thread.setShotSpeed(peekFloat());
					case AddShotSpeedS:
						thread.addShotSpeed(peekFloat());
					case SetShotDirectionS:
						thread.setShotDirection(peekFloat());
					case AddShotDirectionS:
						thread.addShotDirection(peekFloat());
					case SetShotDistanceV:
						thread.setShotDistance(volFloat);
					case AddShotDistanceV:
						thread.addShotDistance(volFloat);
					case SetShotBearingV:
						thread.setShotBearing(volFloat);
					case AddShotBearingV:
						thread.addShotBearing(volFloat);
					case SetShotSpeedV:
						thread.setShotSpeed(volFloat);
					case AddShotSpeedV:
						thread.addShotSpeed(volFloat);
					case SetShotDirectionV:
						thread.setShotDirection(volFloat);
					case AddShotDirectionV:
						thread.addShotDirection(volFloat);
					case CalcRelativeShotDistanceCV:
						setVolFloat(readCodeF64() - thread.getShotDistance());
					case CalcRelativeShotBearingCV:
						setVolFloat(normalizeAngle(readCodeF64() - thread.getShotBearing()));
					case CalcRelativeShotSpeedCV:
						setVolFloat(readCodeF64() - thread.getShotSpeed());
					case CalcRelativeShotDirectionCV:
						setVolFloat(normalizeAngle(readCodeF64() - thread.getShotDirection()));
					case CalcRelativeShotDistanceVV:
						setVolFloat(volFloat - thread.getShotDistance());
					case CalcRelativeShotBearingVV:
						setVolFloat(normalizeAngle(volFloat - thread.getShotBearing()));
					case CalcRelativeShotSpeedVV:
						setVolFloat(volFloat - thread.getShotSpeed());
					case CalcRelativeShotDirectionVV:
						setVolFloat(normalizeAngle(volFloat - thread.getShotDirection()));
					case Fire:
						final bytecodeId = readCodeI32();
						final bytecode = if (bytecodeId < 0) Maybe.none() else
							Maybe.from(bytecodeTable[bytecodeId]);
						emitter.emit(
							xVec[vecIndex] + thread.shotX,
							yVec[vecIndex] + thread.shotY,
							thread.shotVx,
							thread.shotVy,
							bytecode
						);
					case other:
						#if debug
						throw 'Unknown opcode: $other';
						#end
				}

				#if debug
				if (infiniteLoopCheckThreshold < ++cnt) throw "Detected infinite loop.";
				#end
			} while (true);

			thread.update(codePos, stackSize);

			println("");
		}
	}

	public static function dryRun(context: RuntimeContext, bytecode: Bytecode, stackCapacity: UInt = 256): Void {
		final threads = new ThreadList(1, stackCapacity);
		threads.set(bytecode);
		final xVec = Vec.fromArrayCopy([0.0]);
		final yVec = Vec.fromArrayCopy([0.0]);
		final vxVec = Vec.fromArrayCopy([0.0]);
		final vyVec = Vec.fromArrayCopy([0.0]);
		final vecIndex = UInt.zero;
		final emitter = new NullEmitter();
		final targetPosition = new Point(0, 0);

		var frame = UInt.zero;

		while (threads.main.active) {
			if (infiniteLoopCheckThreshold < frame)
				throw 'Exceeded $infiniteLoopCheckThreshold frames.';

			println('[frame $frame]');
			Vm.run(
				context.bytecodeTable,
				threads,
				xVec,
				yVec,
				vxVec,
				vyVec,
				vecIndex,
				emitter,
				targetPosition
			);
			++frame;
		}
	}

	static function println(s: String): Void {
		#if firedancer_verbose
		Printer.println(s);
		#end
	}
}

private class NullEmitter implements Emitter {
	public function new() {}

	public function emit(
		x: Float,
		y: Float,
		vx: Float,
		vy: Float,
		code: Maybe<Bytecode>
	): Void {}
}
