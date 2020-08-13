package firedancer.bytecode;

import banker.binary.ByteStackData;
import haxe.Int32;
import banker.vector.Vector as RVec;
import banker.vector.WritableVector as Vec;
import reckoner.Random;
import firedancer.types.PositionRef;
import firedancer.types.Emitter;
import firedancer.types.EventHandler;
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
	static extern inline final infiniteLoopCheckThreshold: UInt = 4096;

	/**
		Runs firedancer bytecode for a specific actor.
		@return The end code. `0` at default, or any value specified in `End` instruction.
	**/
	public static function run(
		bytecodeTable: RVec<Bytecode>,
		eventHandler: EventHandler,
		threads: ThreadList,
		stackCapacity: UInt,
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
		var stack: ByteStackData;

		var originX: Float;
		var originY: Float;
		var positionX: Float;
		var positionY: Float;

		final reg = new RegisterFile();

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

		inline function readOp(): Opcode {
			final opcode: Opcode = cast code.getUI8(reg.pc);
			#if firedancer_verbose
			println('${opcode.toString()} (pos: $reg.pc)');
			#end
			reg.pc += Opcode.size;
			return opcode;
		}

		inline function readCodeI32(): Int32 {
			final v = code.getI32(reg.pc);
			reg.pc += LEN32;
			return v;
		}

		inline function readCodeF64(): Float {
			final v = code.getF64(reg.pc);
			reg.pc += LEN64;
			return v;
		}

		inline function pushInt(v: Int32): Void
			reg.sp = stack.pushI32(reg.sp, v);

		inline function pushFloat(v: Float): Void
			reg.sp = stack.pushF64(reg.sp, v);

		inline function pushVec(x: Float, y: Float): Void {
			reg.sp = stack.pushF64(reg.sp, x);
			reg.sp = stack.pushF64(reg.sp, y);
		}

		inline function popInt(): Int32 {
			final ret = stack.popI32(reg.sp);
			reg.sp = ret.size;
			return ret.value;
		}

		inline function popFloat(): Float {
			final ret = stack.popF64(reg.sp);
			reg.sp = ret.size;
			return ret.value;
		}

		inline function peekInt(): Int32
			return stack.peekI32(reg.sp);

		inline function peekFloat(): Float
			return stack.peekF64(reg.sp);

		inline function peekFloatSkipped(bytesToSkip: Int): Float
			return stack.peekF64(reg.sp - bytesToSkip);

		inline function peekVecSkipped(bytesToSkip: Int)
			return stack.peekVec2D64(reg.sp - bytesToSkip);

		inline function dropInt(): Void
			reg.sp = stack.drop(reg.sp, Bit32);

		inline function dropFloat(): Void
			reg.sp = stack.drop(reg.sp, Bit64);

		inline function dropVec(): Void
			reg.sp = stack.drop2D(reg.sp, Bit64);

		inline function decrement(): Void
			stack.decrement32(reg.sp);

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

		inline function getLocalInt(address: Int): Int
			return stack.bytesData.getI32(stackCapacity - address - LEN32);

		inline function getLocalFloat(address: Int): Float
			return stack.bytesData.getF64(stackCapacity - address - LEN64);

		inline function setLocalInt(address: Int, value: Int): Void {
			stack.bytesData.setI32(stackCapacity - address - LEN32, value);
		}

		inline function setLocalFloat(address: Int, value: Float): Void {
			stack.bytesData.setF64(stackCapacity - address - LEN64, value);
		}

		inline function addLocalInt(address: Int, value: Int): Void {
			final pos = stackCapacity - address - LEN32;
			stack.bytesData.setI32(pos, stack.bytesData.getI32(pos) + value);
		}

		inline function addLocalFloat(address: Int, value: Float): Void {
			final pos = stackCapacity - address - LEN64;
			stack.bytesData.setF64(pos, stack.bytesData.getF64(pos) + value);
		}

		for (i in 0...threads.length) {
			final thread = threads[i];
			if (!thread.active) continue;

			code = thread.code.unwrap();
			stack = thread.stack;
			reg.reset(thread);

			do {
				if (reg.pcMax <= reg.pc) {
					thread.deactivate();
					break;
				}

				final opcode = readOp();

				switch opcode.category {
					case General:
						switch opcode.op {
							case Break:
								break;
							case CountDownBreak:
								if (0 < peekInt()) {
									decrement();
									reg.pc -= Opcode.size;
									break;
								} else {
									dropInt();
								}
							case Jump:
								final jumpLength = readCodeI32();
								reg.pc += jumpLength;
							case CountDownJump:
								if (0 < peekInt()) {
									decrement();
									reg.pc += LEN32; // skip the operand
								} else {
									dropInt();
									final jumpLength = readCodeI32();
									reg.pc += jumpLength;
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
									reg.pc -= Opcode.size;
									break;
								} else {
									dropInt();
								}
							case End:
								final endCode = readCodeI32();
								threads.deactivateAll();
								updatePosition();
								return endCode;

							case LoadIntCV:
								reg.int = readCodeI32();
							case LoadFloatCV:
								reg.float = readCodeF64();
							case LoadVecCV:
								reg.setVec(readCodeF64(), readCodeF64());
							case SaveIntV:
								reg.saveInt();
							case SaveFloatV:
								reg.saveFloat();
							case LoadIntLV:
								reg.int = getLocalInt(readCodeI32());
							case LoadFloatLV:
								reg.float = getLocalFloat(readCodeI32());
							case StoreIntCL:
								setLocalInt(readCodeI32(), readCodeI32());
							case StoreIntVL:
								setLocalInt(readCodeI32(), reg.int);
							case StoreFloatCL:
								setLocalFloat(readCodeI32(), readCodeF64());
							case StoreFloatVL:
								setLocalFloat(readCodeI32(), reg.float);

							case PushIntC:
								pushInt(readCodeI32());
							case PushIntV:
								pushInt(reg.int);
							case PushFloatC:
								pushFloat(readCodeF64());
							case PushFloatV:
								pushFloat(reg.float);
							case PushVecV:
								pushVec(reg.vecX, reg.vecY);
							case PeekFloat:
								reg.float = peekFloatSkipped(readCodeI32());
							case DropFloat:
								dropFloat();
							case PeekVec:
								final vec = peekVecSkipped(readCodeI32());
								reg.setVec(vec.x, vec.y);
							case DropVec:
								dropVec();

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
									0, // default fire code
									bytecode,
									if (arg.bindPosition) Maybe.from(thisPositionRef) else Maybe.none()
								);
							case FireSimpleWithCode:
								final fireCode = readCodeI32();
								emitter.emit(
									getX() + thread.shotX,
									getY() + thread.shotY,
									thread.shotVx,
									thread.shotVy,
									fireCode,
									Maybe.none(),
									Maybe.none()
								);
							case FireComplexWithCode:
								final arg: FireArgument = readCodeI32();
								final fireCode = readCodeI32();
								final bytecode = Maybe.from(bytecodeTable[arg.bytecodeId]);
								emitter.emit(
									getX() + thread.shotX,
									getY() + thread.shotY,
									thread.shotVx,
									thread.shotVy,
									fireCode,
									bytecode,
									if (arg.bindPosition) Maybe.from(thisPositionRef) else Maybe.none()
								);

							case GlobalEvent:
								eventHandler.onGlobalEvent(reg.int);
							case LocalEvent:
								eventHandler.onLocalEvent(
									reg.int,
									getX(),
									getY(),
									thread,
									originPositionRef,
									targetPositionRef
								);

							#if debug
							case other:
								throw 'Unknown general opcode: $other';
							#end
						}

					case Calc:
						switch opcode.op {
							case AddIntVCV:
								reg.int = reg.int + readCodeI32();
							case AddIntVVV:
								reg.int = reg.intBuf + reg.int;
							case SubIntVCV:
								reg.int = reg.int - readCodeI32();
							case SubIntCVV:
								reg.int = readCodeI32() - reg.int;
							case SubIntVVV:
								reg.int = reg.intBuf - reg.int;
							case MinusIntV:
								reg.int = -reg.int;
							case MultIntVCV:
								reg.int = reg.int * readCodeI32();
							case MultIntVVV:
								reg.int = reg.intBuf * reg.int;
							case DivIntVCV:
								reg.int = Ints.divide(reg.int, readCodeI32());
							case DivIntCVV:
								reg.int = Ints.divide(readCodeI32(), reg.int);
							case DivIntVVV:
								reg.int = Ints.divide(reg.intBuf, reg.int);
							case ModIntVCV:
								reg.int = reg.int % readCodeI32();
							case ModIntCVV:
								reg.int = readCodeI32() % reg.int;
							case ModIntVVV:
								reg.int = reg.intBuf % reg.int;

							case AddFloatVCV:
								reg.float = reg.float + readCodeF64();
							case AddFloatVVV:
								reg.float = reg.floatBuf + reg.float;
							case SubFloatVCV:
								reg.float = reg.float - readCodeF64();
							case SubFloatCVV:
								reg.float = readCodeF64() - reg.float;
							case SubFloatVVV:
								reg.float = reg.floatBuf - reg.float;
							case MinusFloatV:
								reg.float = -reg.float;
							case MultFloatVCV:
								reg.float = reg.float * readCodeF64();
							case MultFloatVVV:
								reg.float = reg.floatBuf * reg.float;
							case DivFloatCVV:
								reg.float = readCodeF64() / reg.float;
							case DivFloatVVV:
								reg.float = reg.floatBuf / reg.float;
							case ModFloatVCV:
								reg.float = reg.float % readCodeF64();
							case ModFloatCVV:
								reg.float = readCodeF64() % reg.float;
							case ModFloatVVV:
								reg.float = reg.floatBuf % reg.float;

							case MinusVecV:
								reg.setVec(-reg.vecX, -reg.vecY);
							case MultVecVCV:
								final multiplier = readCodeF64();
								reg.setVec(reg.vecX * multiplier, reg.vecY * multiplier);
							case MultVecVVV:
								reg.setVec(reg.vecX * reg.float, reg.vecY * reg.float);
							case DivVecVVV:
								reg.setVec(reg.vecX / reg.float, reg.vecY / reg.float);
							case CastIntToFloatVV:
								reg.float = reg.int;
							case CastCartesianVV:
								reg.setVec(reg.floatBuf, reg.float);
							case CastPolarVV:
								final vec = Geometry.toVec(reg.floatBuf, reg.float);
								reg.setVec(vec.x, vec.y);

							case RandomRatioV:
								reg.float = Random.random();
							case RandomFloatCV:
								reg.float = Random.float(readCodeF64());
							case RandomFloatVV:
								reg.float = Random.float(reg.float);
							case RandomFloatSignedCV:
								reg.float = Random.signed(readCodeF64());
							case RandomFloatSignedVV:
								reg.float = Random.signed(reg.float);
							case RandomIntCV:
								reg.int = Random.int(readCodeI32());
							case RandomIntVV:
								reg.int = Random.int(reg.int);
							case RandomIntSignedCV:
								reg.int = Random.signedInt(readCodeI32());
							case RandomIntSignedVV:
								reg.int = Random.signedInt(reg.int);

							case AddIntLCL:
								addLocalInt(readCodeI32(), readCodeI32());
							case AddIntLVL:
								addLocalInt(readCodeI32(), reg.int);
							case IncrementL:
								addLocalInt(readCodeI32(), 1);
							case DecrementL:
								addLocalInt(readCodeI32(), -1);
							case AddFloatLCL:
								addLocalFloat(readCodeI32(), readCodeF64());
							case AddFloatLVL:
								addLocalFloat(readCodeI32(), reg.float);

							#if debug
							case other:
								throw 'Unknown calc opcode: $other';
							#end
						}

					case Read:
						switch opcode.op {
							case LoadTargetPositionV:
								reg.setVec(targetPositionRef.x, targetPositionRef.y);
							case LoadTargetXV:
								reg.float = targetPositionRef.x;
							case LoadTargetYV:
								reg.float = targetPositionRef.y;
							case LoadBearingToTargetV:
								reg.float = Geometry.getAngle(
									targetPositionRef.x - getX(),
									targetPositionRef.y - getY()
								);

							case CalcRelativePositionCV:
								reg.setVec(readCodeF64() - getX(), readCodeF64() - getY());
							case CalcRelativeVelocityCV:
								reg.setVec(readCodeF64() - getVx(), readCodeF64() - getVy());
							case CalcRelativePositionVV:
								reg.setVec(reg.vecX - getX(), reg.vecY - getY());
							case CalcRelativeVelocityVV:
								reg.setVec(reg.vecX - getVx(), reg.vecY - getVy());
							case CalcRelativeDistanceCV:
								reg.float = readCodeF64() - getDistance();
							case CalcRelativeBearingCV:
								reg.float = Geometry.getAngleDifference(
									getBearing(),
									readCodeF64()
								);
							case CalcRelativeSpeedCV:
								reg.float = readCodeF64() - getSpeed();
							case CalcRelativeDirectionCV:
								reg.float = Geometry.getAngleDifference(
									getDirection(),
									readCodeF64()
								);
							case CalcRelativeDistanceVV:
								reg.float = reg.float - getDistance();
							case CalcRelativeBearingVV:
								reg.float = Geometry.getAngleDifference(getBearing(), reg.float);
							case CalcRelativeSpeedVV:
								reg.float = reg.float - getSpeed();
							case CalcRelativeDirectionVV:
								reg.float = Geometry.getAngleDifference(
									getDirection(),
									reg.float
								);

							case CalcRelativeShotPositionCV:
								reg.setVec(
									readCodeF64() - thread.shotX,
									readCodeF64() - thread.shotY
								);
							case CalcRelativeShotVelocityCV:
								reg.setVec(
									readCodeF64() - thread.shotVx,
									readCodeF64() - thread.shotVy
								);
							case CalcRelativeShotPositionVV:
								reg.setVec(reg.vecX - thread.shotX, reg.vecY - thread.shotY);
							case CalcRelativeShotVelocityVV:
								reg.setVec(reg.vecX - thread.shotVx, reg.vecY - thread.shotVy);
							case CalcRelativeShotDistanceCV:
								reg.float = readCodeF64() - thread.getShotDistance();
							case CalcRelativeShotBearingCV:
								reg.float = Geometry.getAngleDifference(
									thread.getShotBearing(),
									readCodeF64()
								);
							case CalcRelativeShotSpeedCV:
								reg.float = readCodeF64() - thread.getShotSpeed();
							case CalcRelativeShotDirectionCV:
								reg.float = Geometry.getAngleDifference(
									thread.getShotDirection(),
									readCodeF64()
								);
							case CalcRelativeShotDistanceVV:
								reg.float = reg.float - thread.getShotDistance();
							case CalcRelativeShotBearingVV:
								reg.float = Geometry.getAngleDifference(
									thread.getShotBearing(),
									reg.float
								);
							case CalcRelativeShotSpeedVV:
								reg.float = reg.float - thread.getShotSpeed();
							case CalcRelativeShotDirectionVV:
								reg.float = Geometry.getAngleDifference(
									thread.getShotDirection(),
									reg.float
								);

							#if debug
							case other:
								throw 'Unknown read opcode: $other';
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
								setPosition(reg.vecX, reg.vecY);
							case AddPositionV:
								addPosition(reg.vecX, reg.vecY);
							case SetVelocityV:
								setVelocity(reg.vecX, reg.vecY);
							case AddVelocityV:
								addVelocity(reg.vecX, reg.vecY);
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
								setDistance(reg.float);
							case AddDistanceV:
								addDistance(reg.float);
							case AddDistanceS:
								addDistance(peekFloat());
							case SetBearingC:
								setBearing(readCodeF64());
							case AddBearingC:
								addBearing(readCodeF64());
							case SetBearingV:
								setBearing(reg.float);
							case AddBearingV:
								addBearing(reg.float);
							case AddBearingS:
								addBearing(peekFloat());
							case SetSpeedC:
								setSpeed(readCodeF64());
							case AddSpeedC:
								addSpeed(readCodeF64());
							case SetSpeedV:
								setSpeed(reg.float);
							case AddSpeedV:
								addSpeed(reg.float);
							case AddSpeedS:
								addSpeed(peekFloat());
							case SetDirectionC:
								setDirection(readCodeF64());
							case AddDirectionC:
								addDirection(readCodeF64());
							case SetDirectionV:
								setDirection(reg.float);
							case AddDirectionV:
								addDirection(reg.float);
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
								thread.setShotPosition(reg.vecX, reg.vecY);
							case AddShotPositionV:
								thread.addShotPosition(reg.vecX, reg.vecY);
							case SetShotVelocityV:
								thread.setShotVelocity(reg.vecX, reg.vecY);
							case AddShotVelocityV:
								thread.addShotVelocity(reg.vecX, reg.vecY);
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
								thread.setShotDistance(reg.float);
							case AddShotDistanceV:
								thread.addShotDistance(reg.float);
							case AddShotDistanceS:
								thread.addShotDistance(peekFloat());
							case SetShotBearingC:
								thread.setShotBearing(readCodeF64());
							case AddShotBearingC:
								thread.addShotBearing(readCodeF64());
							case SetShotBearingV:
								thread.setShotBearing(reg.float);
							case AddShotBearingV:
								thread.addShotBearing(reg.float);
							case AddShotBearingS:
								thread.addShotBearing(peekFloat());
							case SetShotSpeedC:
								thread.setShotSpeed(readCodeF64());
							case AddShotSpeedC:
								thread.addShotSpeed(readCodeF64());
							case SetShotSpeedV:
								thread.setShotSpeed(reg.float);
							case AddShotSpeedV:
								thread.addShotSpeed(reg.float);
							case AddShotSpeedS:
								thread.addShotSpeed(peekFloat());
							case SetShotDirectionC:
								thread.setShotDirection(readCodeF64());
							case AddShotDirectionC:
								thread.addShotDirection(readCodeF64());
							case SetShotDirectionV:
								thread.setShotDirection(reg.float);
							case AddShotDirectionV:
								thread.addShotDirection(reg.float);
							case AddShotDirectionS:
								thread.addShotDirection(peekFloat());

							#if debug
							case other: throw 'Unknown write opcode: $other';
							#end
						}
				}

				#if debug
				reg.cnt += 1;
				if (infiniteLoopCheckThreshold < reg.cnt) throw "Detected infinite loop.";
				#end
			} while (true);

			thread.update(reg.pc, reg.sp);
		}

		updatePosition();

		return 0;
	}

	public static function dryRun(
		pkg: ProgramPackage,
		entryBytecodeName: String,
		stackCapacity: UInt = 256
	): Void {
		final eventHandler = new NullEventHandler();
		final threads = new ThreadList(1, stackCapacity);
		final bytecode = pkg.getBytecodeByName(entryBytecodeName);
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
				pkg.bytecodeTable,
				eventHandler,
				threads,
				stackCapacity,
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
