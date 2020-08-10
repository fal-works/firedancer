package firedancer.bytecode;

import banker.binary.ByteStackData;
import haxe.Int32;
import banker.vector.Vector as RVec;
import banker.vector.WritableVector as Vec;
import reckoner.Random;
import firedancer.types.PositionRef;
import firedancer.types.Emitter;
import firedancer.assembly.Opcode;
import firedancer.assembly.operation.GeneralOperation;
import firedancer.assembly.operation.CalcOperation;
import firedancer.assembly.operation.ReadOperation;
import firedancer.assembly.operation.WriteOperation;
import firedancer.bytecode.internal.Constants.*;
import firedancer.bytecode.types.FireArgument;
import firedancer.common.Geometry;

#if firedancer_verbose
using firedancer.assembly.OpcodeExtension;
#end

/**
	Virtual machine for executing bytecode.
**/
class Vm {
	static extern inline final infiniteLoopCheckThreshold = 4096;

	/**
		Runs firedancer bytecode for a specific actor.
		@return The end code. `0` at default, or any value specified in `End` instruction.
	**/
	public static function run(
		bytecodeTable: RVec<Bytecode>,
		threads: ThreadList,
		xVec: Vec<Float>,
		yVec: Vec<Float>,
		vxVec: Vec<Float>,
		vyVec: Vec<Float>,
		originPositionRefVec: Vec<Maybe<PositionRef>>,
		vecIndex: UInt,
		emitter: Emitter,
		thisPositionRef: PositionRef,
		targetPositionRef: PositionRef
	): Int {
		var code: BytecodeData;
		var codeLength: UInt;

		var codePos: UInt;
		var stack: ByteStackData;
		var stackSize: UInt;

		var volIntSaved: Int;
		var volInt: Int;
		var volFloatSaved: Float;
		var volFloat: Float;
		var volX: Float;
		var volY: Float;

		var originX: Float;
		var originY: Float;
		var positionX: Float;
		var positionY: Float;

		var originPositionRef = originPositionRefVec[vecIndex];
		if (originPositionRef.isNone()) {
			originX = originY = 0.0;
			positionX = xVec[vecIndex];
			positionY = yVec[vecIndex];
		} else {
			final origin = originPositionRef.unwrap();
			if (origin.isValid()) {
				originX = origin.x;
				originY = origin.y;
				positionX = xVec[vecIndex] - originX;
				positionY = yVec[vecIndex] - originY;
			} else {
				originPositionRefVec[vecIndex] = Maybe.none();
				originX = originY = 0.0;
				positionX = xVec[vecIndex];
				positionY = yVec[vecIndex];
			}
		}

		inline function updatePosition(): Void {
			xVec[vecIndex] = originX + positionX;
			yVec[vecIndex] = originY + positionY;
		}

		inline function setVolInt(v: Int): Void
			volInt = v;

		inline function saveInt(v: Int): Void
			volIntSaved = v;

		inline function setVolFloat(v: Float): Void
			volFloat = v;

		inline function saveFloat(v: Float): Void
			volFloatSaved = v;

		inline function setVolX(x: Float): Void
			volX = x;

		inline function setVolY(y: Float): Void
			volY = y;

		inline function setVolVec(x: Float, y: Float): Void {
			setVolX(x);
			setVolY(y);
		}

		inline function readOp(): Opcode {
			final opcode: Opcode = cast code.getUI8(codePos);
			#if firedancer_verbose
			println('${opcode.toString()} (pos: $codePos)');
			#end
			codePos += Opcode.size;
			return opcode;
		}

		inline function readCodeI32(): Int32 {
			final v = code.getI32(codePos);
			codePos += LEN32;
			return v;
		}

		inline function readCodeF64(): Float {
			final v = code.getF64(codePos);
			codePos += LEN64;
			return v;
		}

		inline function pushInt(v: Int32): Void
			stackSize = stack.pushI32(stackSize, v);

		inline function pushFloat(v: Float): Void
			stackSize = stack.pushF64(stackSize, v);

		inline function pushVec(x: Float, y: Float): Void {
			stackSize = stack.pushF64(stackSize, x);
			stackSize = stack.pushF64(stackSize, y);
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

		inline function dropInt(): Void
			stackSize = stack.drop(stackSize, Bit32);

		inline function dropFloat(): Void
			stackSize = stack.drop(stackSize, Bit64);

		inline function dropVec(): Void
			stackSize = stack.drop2D(stackSize, Bit64);

		inline function decrement(): Void
			stack.decrement32(stackSize);

		inline function getX(): Float
			return positionX;

		inline function getY(): Float
			return positionY;

		inline function getVx(): Float
			return vxVec[vecIndex];

		inline function getVy(): Float
			return vyVec[vecIndex];

		inline function setX(x: Float): Void
			positionX = x;

		inline function setY(y: Float): Void
			positionY = y;

		inline function setVx(vx: Float): Void
			vxVec[vecIndex] = vx;

		inline function setVy(vy: Float): Void
			vyVec[vecIndex] = vy;

		inline function addX(x: Float): Void
			positionX += x;

		inline function addY(y: Float): Void
			positionY += y;

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
			return Geometry.getLength(getX(), getY());

		inline function getBearing(): Float
			return Geometry.getAngle(getX(), getY());

		inline function getSpeed(): Float
			return Geometry.getLength(getVx(), getVy());

		inline function getDirection(): Float
			return Geometry.getAngle(getVx(), getVy());

		inline function setDistance(value: Float): Void {
			final newPosition = Geometry.setLength(getX(), getY(), value);
			setPosition(newPosition.x, newPosition.y);
		}

		inline function addDistance(value: Float): Void {
			final newPosition = Geometry.addLength(getX(), getY(), value);
			setPosition(newPosition.x, newPosition.y);
		}

		inline function setBearing(value: Float): Void {
			final newPosition = Geometry.setAngle(getX(), getY(), value);
			setPosition(newPosition.x, newPosition.y);
		}

		inline function addBearing(value: Float): Void {
			final newPosition = Geometry.addAngle(getX(), getY(), value);
			setPosition(newPosition.x, newPosition.y);
		}

		inline function setSpeed(value: Float): Void {
			final newVelocity = Geometry.setLength(getVx(), getVy(), value);
			setVelocity(newVelocity.x, newVelocity.y);
		}

		inline function addSpeed(value: Float): Void {
			final newVelocity = Geometry.addLength(getVx(), getVy(), value);
			setVelocity(newVelocity.x, newVelocity.y);
		}

		inline function setDirection(value: Float): Void {
			final newVelocity = Geometry.setAngle(getVx(), getVy(), value);
			setVelocity(newVelocity.x, newVelocity.y);
		}

		inline function addDirection(value: Float): Void {
			final newVelocity = Geometry.addAngle(getVx(), getVy(), value);
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

			volIntSaved = 0;
			volInt = 0;
			volFloatSaved = 0.0;
			volFloat = 0.0;
			volX = 0.0;
			volY = 0.0;

			#if debug
			var cnt = 0;
			#end

			do {
				if (codeLength <= codePos) {
					thread.deactivate();
					break;
				}

				final opcode = readOp();

				switch opcode.category {
					case General:
						switch opcode.op {
							case PushIntC:
								pushInt(readCodeI32());
							case PushIntV:
								pushInt(volInt);
							case PushFloatC:
								pushFloat(readCodeF64());
							case PushFloatV:
								pushFloat(volFloat);
							case PushVecV:
								pushVec(volX, volY);
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
								if (0 < peekInt()) {
									decrement();
									codePos -= Opcode.size;
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
								if (0 < peekInt()) {
									decrement();
									codePos += LEN32; // skip the operand
								} else {
									dropInt();
									final jumpLength = readCodeI32();
									codePos += jumpLength;
								}
							case UseThread:
								final bytecodeId = readCodeI32();
								threads.useSubThread(bytecodeTable[bytecodeId], thread);
							case UseThreadS:
								final bytecodeId = readCodeI32();
								final threadId = threads.useSubThread(
									bytecodeTable[bytecodeId],
									thread
								);
								pushInt(threadId.int());
							case AwaitThread:
								if (threads[peekInt()].active) {
									codePos -= Opcode.size;
									break;
								} else {
									dropInt();
								}
							case End:
								final endCode = readCodeI32();
								threads.deactivateAll();
								updatePosition();
								return endCode;

							case FireSimple:
								emitter.emit(
									getX() + thread.shotX,
									getY() + thread.shotY,
									thread.shotVx,
									thread.shotVy,
									0,
									Maybe.none(),
									Maybe.none()
								);
							case FireComplex:
								final arg: FireArgument = readCodeI32();
								final bytecode = Maybe.from(bytecodeTable[arg.bytecodeId]);
								emitter.emit(
									getX() + thread.shotX,
									getY() + thread.shotY,
									thread.shotVx,
									thread.shotVy,
									0, // default fire type
									bytecode,
									if (arg.bindPosition) Maybe.from(thisPositionRef) else Maybe.none()
								);
							case FireSimpleWithType:
								final fireType = readCodeI32();
								emitter.emit(
									getX() + thread.shotX,
									getY() + thread.shotY,
									thread.shotVx,
									thread.shotVy,
									fireType,
									Maybe.none(),
									Maybe.none()
								);
							case FireComplexWithType:
								final arg: FireArgument = readCodeI32();
								final fireType = readCodeI32();
								final bytecode = Maybe.from(bytecodeTable[arg.bytecodeId]);
								emitter.emit(
									getX() + thread.shotX,
									getY() + thread.shotY,
									thread.shotVx,
									thread.shotVy,
									fireType,
									bytecode,
									if (arg.bindPosition) Maybe.from(thisPositionRef) else Maybe.none()
								);

							#if debug
							case other:
								throw 'Unknown opcode: $other';
							#end
						}

					case Calc:
						switch opcode.op {
							case LoadFloatCV:
								setVolFloat(readCodeF64());
							case LoadVecCV:
								setVolVec(readCodeF64(), readCodeF64());

							case AddIntVCV:
								setVolInt(volInt + readCodeI32());
							case AddIntVVV:
								setVolInt(volIntSaved + volInt);
							case SubIntVCV:
								setVolInt(volInt - readCodeI32());
							case SubIntCVV:
								setVolInt(readCodeI32() - volInt);
							case SubIntVVV:
								setVolInt(volIntSaved - volInt);
							case MinusIntV:
								setVolInt(-volInt);
							case MultIntVCV:
								setVolInt(volInt * readCodeI32());
							case MultIntVVV:
								setVolInt(volIntSaved * volInt);
							case DivIntVCV:
								setVolInt(Ints.divide(volInt, readCodeI32()));
							case DivIntCVV:
								setVolInt(Ints.divide(readCodeI32(), volInt));
							case DivIntVVV:
								setVolInt(Ints.divide(volIntSaved, volInt));
							case ModIntVCV:
								setVolInt(volInt % readCodeI32());
							case ModIntCVV:
								setVolInt(readCodeI32() % volInt);
							case ModIntVVV:
								setVolInt(volIntSaved % volInt);

							case AddFloatVCV:
								setVolFloat(volFloat + readCodeF64());
							case AddFloatVVV:
								setVolFloat(volFloatSaved + volFloat);
							case SubFloatVCV:
								setVolFloat(volFloat - readCodeF64());
							case SubFloatCVV:
								setVolFloat(readCodeF64() - volFloat);
							case SubFloatVVV:
								setVolFloat(volFloatSaved - volFloat);
							case MinusFloatV:
								setVolFloat(-volFloat);
							case MultFloatVCV:
								setVolFloat(volFloat * readCodeF64());
							case MultFloatVVV:
								setVolFloat(volFloatSaved * volFloat);
							case DivFloatCVV:
								setVolFloat(readCodeF64() / volFloat);
							case DivFloatVVV:
								setVolFloat(volFloatSaved / volFloat);
							case ModFloatVCV:
								setVolFloat(volFloat % readCodeF64());
							case ModFloatCVV:
								setVolFloat(readCodeF64() % volFloat);
							case ModFloatVVV:
								setVolFloat(volFloatSaved % volFloat);
							case MultVecVCV:
								final multiplier = readCodeF64();
								setVolVec(volX * multiplier, volY * multiplier);
							case MultVecVVV:
								setVolVec(volX * volFloat, volY * volFloat);
							case DivVecVVV:
								setVolVec(volX / volFloat, volY / volFloat);
							case SaveIntV:
								saveInt(volInt);
							case SaveFloatV:
								saveFloat(volFloat);
							case CastIntToFloatVV:
								setVolFloat(volInt);
							case CastCartesianVV:
								setVolVec(volFloatSaved, volFloat);
							case CastPolarVV:
								final vec = Geometry.toVec(volFloatSaved, volFloat);
								setVolVec(vec.x, vec.y);
							case RandomRatioV:
								setVolFloat(Random.random());
							case RandomFloatCV:
								setVolFloat(Random.float(readCodeF64()));
							case RandomFloatVV:
								setVolFloat(Random.float(volFloat));
							case RandomFloatSignedCV:
								setVolFloat(Random.signed(readCodeF64()));
							case RandomFloatSignedVV:
								setVolFloat(Random.signed(volFloat));
							case RandomIntCV:
								setVolInt(Random.int(readCodeI32()));
							case RandomIntVV:
								setVolInt(Random.int(volInt));
							case RandomIntSignedCV:
								setVolInt(Random.signedInt(readCodeI32()));
							case RandomIntSignedVV:
								setVolInt(Random.signedInt(volInt));
						}

					case Read:
						switch opcode.op {
							case LoadTargetPositionV:
								setVolVec(targetPositionRef.x, targetPositionRef.y);
							case LoadTargetXV:
								setVolFloat(targetPositionRef.x);
							case LoadTargetYV:
								setVolFloat(targetPositionRef.y);
							case LoadBearingToTargetV:
								setVolFloat(Geometry.getAngle(
									targetPositionRef.x - getX(),
									targetPositionRef.y - getY()
								));

							case CalcRelativePositionCV:
								setVolVec(readCodeF64() - getX(), readCodeF64() - getY());
							case CalcRelativeVelocityCV:
								setVolVec(readCodeF64() - getVx(), readCodeF64() - getVy());
							case CalcRelativePositionVV:
								setVolVec(volX - getX(), volY - getY());
							case CalcRelativeVelocityVV:
								setVolVec(volX - getVx(), volY - getVy());
							case CalcRelativeDistanceCV:
								setVolFloat(readCodeF64() - getDistance());
							case CalcRelativeBearingCV:
								setVolFloat(Geometry.getAngleDifference(
									getBearing(),
									readCodeF64()
								));
							case CalcRelativeSpeedCV:
								setVolFloat(readCodeF64() - getSpeed());
							case CalcRelativeDirectionCV:
								setVolFloat(Geometry.getAngleDifference(
									getDirection(),
									readCodeF64()
								));
							case CalcRelativeDistanceVV:
								setVolFloat(volFloat - getDistance());
							case CalcRelativeBearingVV:
								setVolFloat(Geometry.getAngleDifference(getBearing(), volFloat));
							case CalcRelativeSpeedVV:
								setVolFloat(volFloat - getSpeed());
							case CalcRelativeDirectionVV:
								setVolFloat(Geometry.getAngleDifference(
									getDirection(),
									volFloat
								));

							case CalcRelativeShotPositionCV:
								setVolVec(
									readCodeF64() - thread.shotX,
									readCodeF64() - thread.shotY
								);
							case CalcRelativeShotVelocityCV:
								setVolVec(
									readCodeF64() - thread.shotVx,
									readCodeF64() - thread.shotVy
								);
							case CalcRelativeShotPositionVV:
								setVolVec(volX - thread.shotX, volY - thread.shotY);
							case CalcRelativeShotVelocityVV:
								setVolVec(volX - thread.shotVx, volY - thread.shotVy);
							case CalcRelativeShotDistanceCV:
								setVolFloat(readCodeF64() - thread.getShotDistance());
							case CalcRelativeShotBearingCV:
								setVolFloat(Geometry.getAngleDifference(
									thread.getShotBearing(),
									readCodeF64()
								));
							case CalcRelativeShotSpeedCV:
								setVolFloat(readCodeF64() - thread.getShotSpeed());
							case CalcRelativeShotDirectionCV:
								setVolFloat(Geometry.getAngleDifference(
									thread.getShotDirection(),
									readCodeF64()
								));
							case CalcRelativeShotDistanceVV:
								setVolFloat(volFloat - thread.getShotDistance());
							case CalcRelativeShotBearingVV:
								setVolFloat(Geometry.getAngleDifference(
									thread.getShotBearing(),
									volFloat
								));
							case CalcRelativeShotSpeedVV:
								setVolFloat(volFloat - thread.getShotSpeed());
							case CalcRelativeShotDirectionVV:
								setVolFloat(Geometry.getAngleDifference(
									thread.getShotDirection(),
									volFloat
								));

							#if debug
							case other:
								throw 'Unknown opcode: $other';
							#end
						}

					case Write:
						switch opcode.op {
							case SetPositionC:
								setPosition(readCodeF64(), readCodeF64());
							case AddPositionC:
								addPosition(readCodeF64(), readCodeF64());
							case SetVelocityC:
								setVelocity(readCodeF64(), readCodeF64());
							case AddVelocityC:
								addVelocity(readCodeF64(), readCodeF64());
							case SetPositionV:
								setPosition(volX, volY);
							case AddPositionV:
								addPosition(volX, volY);
							case SetVelocityV:
								setVelocity(volX, volY);
							case AddVelocityV:
								addVelocity(volX, volY);
							case AddPositionS:
								final vec = peekVecSkipped(0);
								addPosition(vec.x, vec.y);
							case AddVelocityS:
								final vec = peekVecSkipped(0);
								addPosition(vec.x, vec.y);
							case SetDistanceC:
								setDistance(readCodeF64());
							case AddDistanceC:
								addDistance(readCodeF64());
							case SetDistanceV:
								setDistance(volFloat);
							case AddDistanceV:
								addDistance(volFloat);
							case AddDistanceS:
								addDistance(peekFloat());
							case SetBearingC:
								setBearing(readCodeF64());
							case AddBearingC:
								addBearing(readCodeF64());
							case SetBearingV:
								setBearing(volFloat);
							case AddBearingV:
								addBearing(volFloat);
							case AddBearingS:
								addBearing(peekFloat());
							case SetSpeedC:
								setSpeed(readCodeF64());
							case AddSpeedC:
								addSpeed(readCodeF64());
							case SetSpeedV:
								setSpeed(volFloat);
							case AddSpeedV:
								addSpeed(volFloat);
							case AddSpeedS:
								addSpeed(peekFloat());
							case SetDirectionC:
								setDirection(readCodeF64());
							case AddDirectionC:
								addDirection(readCodeF64());
							case SetDirectionV:
								setDirection(volFloat);
							case AddDirectionV:
								addDirection(volFloat);
							case AddDirectionS:
								addDirection(peekFloat());
							case SetShotPositionC:
								thread.setShotPosition(readCodeF64(), readCodeF64());
							case AddShotPositionC:
								thread.addShotPosition(readCodeF64(), readCodeF64());
							case SetShotVelocityC:
								thread.setShotVelocity(readCodeF64(), readCodeF64());
							case AddShotVelocityC:
								thread.addShotVelocity(readCodeF64(), readCodeF64());
							case SetShotPositionV:
								thread.setShotPosition(volX, volY);
							case AddShotPositionV:
								thread.addShotPosition(volX, volY);
							case SetShotVelocityV:
								thread.setShotVelocity(volX, volY);
							case AddShotVelocityV:
								thread.addShotVelocity(volX, volY);
							case AddShotPositionS:
								final vec = peekVecSkipped(0);
								thread.addShotPosition(vec.x, vec.y);
							case AddShotVelocityS:
								final vec = peekVecSkipped(0);
								thread.addShotVelocity(vec.x, vec.y);
							case SetShotDistanceC:
								thread.setShotDistance(readCodeF64());
							case AddShotDistanceC:
								thread.addShotDistance(readCodeF64());
							case SetShotDistanceV:
								thread.setShotDistance(volFloat);
							case AddShotDistanceV:
								thread.addShotDistance(volFloat);
							case AddShotDistanceS:
								thread.addShotDistance(peekFloat());
							case SetShotBearingC:
								thread.setShotBearing(readCodeF64());
							case AddShotBearingC:
								thread.addShotBearing(readCodeF64());
							case SetShotBearingV:
								thread.setShotBearing(volFloat);
							case AddShotBearingV:
								thread.addShotBearing(volFloat);
							case AddShotBearingS:
								thread.addShotBearing(peekFloat());
							case SetShotSpeedC:
								thread.setShotSpeed(readCodeF64());
							case AddShotSpeedC:
								thread.addShotSpeed(readCodeF64());
							case SetShotSpeedV:
								thread.setShotSpeed(volFloat);
							case AddShotSpeedV:
								thread.addShotSpeed(volFloat);
							case AddShotSpeedS:
								thread.addShotSpeed(peekFloat());
							case SetShotDirectionC:
								thread.setShotDirection(readCodeF64());
							case AddShotDirectionC:
								thread.addShotDirection(readCodeF64());
							case SetShotDirectionV:
								thread.setShotDirection(volFloat);
							case AddShotDirectionV:
								thread.addShotDirection(volFloat);
							case AddShotDirectionS:
								thread.addShotDirection(peekFloat());

							#if debug
							case other: throw 'Unknown opcode: $other';
							#end
						}
				}

				#if debug
				if (infiniteLoopCheckThreshold < ++cnt) throw "Detected infinite loop.";
				#end
			} while (true);

			thread.update(codePos, stackSize);
		}

		updatePosition();

		return 0;
	}

	public static function dryRun(
		context: RuntimeContext,
		bytecode: Bytecode,
		stackCapacity: UInt = 256
	): Void {
		final threads = new ThreadList(1, stackCapacity);
		threads.set(bytecode);
		final xVec = Vec.fromArrayCopy([0.0]);
		final yVec = Vec.fromArrayCopy([0.0]);
		final vxVec = Vec.fromArrayCopy([0.0]);
		final vyVec = Vec.fromArrayCopy([0.0]);
		final originPositionRefVec: Vec<Maybe<PositionRef>> = new Vec(UInt.one);
		final vecIndex = UInt.zero;
		final emitter = new NullEmitter();
		final targetPositionRef = PositionRef.createZero();

		var frame = UInt.zero;

		while (threads.main.active) {
			if (infiniteLoopCheckThreshold < frame)
				throw 'Exceeded $infiniteLoopCheckThreshold frames.';

			Vm.run(
				context.bytecodeTable,
				threads,
				xVec,
				yVec,
				vxVec,
				vyVec,
				originPositionRefVec,
				vecIndex,
				emitter,
				PositionRef.createZero(),
				targetPositionRef
			);
			++frame;
		}
	}

	#if firedancer_verbose
	static function println(s: String): Void
		sneaker.print.Printer.println(s);
	#end
}
