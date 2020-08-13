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
		final originPositionRef = originPositionRefVec[vecIndex];
		final position = new TmpPosition(
			xVec[vecIndex],
			yVec[vecIndex],
			originPositionRef,
			originPositionRefVec,
			vecIndex
		);
		final velocity = new TmpVelocity(vxVec[vecIndex], vyVec[vecIndex]);

		inline function updatePositionAndVelocity(): Void {
			position.x += velocity.x;
			position.y += velocity.y;

			xVec[vecIndex] = position.getAbsoluteX();
			yVec[vecIndex] = position.getAbsoluteY();
			vxVec[vecIndex] = velocity.x;
			vyVec[vecIndex] = velocity.y;
		}

		var code: BytecodeData;
		var stack: ByteStackData;
		final reg = new RegisterFile();

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
								updatePositionAndVelocity();
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
									position.x + thread.shotX,
									position.y + thread.shotY,
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
									position.x + thread.shotX,
									position.y + thread.shotY,
									thread.shotVx,
									thread.shotVy,
									0, // default fire code
									bytecode,
									if (arg.bindPosition) Maybe.from(thisPositionRef) else Maybe.none()
								);
							case FireSimpleWithCode:
								final fireCode = readCodeI32();
								emitter.emit(
									position.x + thread.shotX,
									position.y + thread.shotY,
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
									position.x + thread.shotX,
									position.y + thread.shotY,
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
									position.x,
									position.y,
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
									targetPositionRef.x - position.x,
									targetPositionRef.y - position.y
								);

							case CalcRelativePositionCV:
								reg.setVec(readCodeF64() - position.x, readCodeF64() - position.y);
							case CalcRelativeVelocityCV:
								reg.setVec(readCodeF64() - velocity.x, readCodeF64() - velocity.y);
							case CalcRelativePositionVV:
								reg.setVec(reg.vecX - position.x, reg.vecY - position.y);
							case CalcRelativeVelocityVV:
								reg.setVec(reg.vecX - velocity.x, reg.vecY - velocity.y);
							case CalcRelativeDistanceCV:
								reg.float = readCodeF64() - position.getDistance();
							case CalcRelativeBearingCV:
								reg.float = Geometry.getAngleDifference(
									position.getBearing(),
									readCodeF64()
								);
							case CalcRelativeSpeedCV:
								reg.float = readCodeF64() - velocity.getSpeed();
							case CalcRelativeDirectionCV:
								reg.float = Geometry.getAngleDifference(
									velocity.getDirection(),
									readCodeF64()
								);
							case CalcRelativeDistanceVV:
								reg.float = reg.float - position.getDistance();
							case CalcRelativeBearingVV:
								reg.float = Geometry.getAngleDifference(position.getBearing(), reg.float);
							case CalcRelativeSpeedVV:
								reg.float = reg.float - velocity.getSpeed();
							case CalcRelativeDirectionVV:
								reg.float = Geometry.getAngleDifference(
									velocity.getDirection(),
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
								position.set(readCodeF64(), readCodeF64());
							case AddPositionC:
								position.add(readCodeF64(), readCodeF64());
							case SetVelocityC:
								velocity.set(readCodeF64(), readCodeF64());
							case AddVelocityC:
								velocity.add(readCodeF64(), readCodeF64());
							case SetPositionV:
								position.set(reg.vecX, reg.vecY);
							case AddPositionV:
								position.add(reg.vecX, reg.vecY);
							case SetVelocityV:
								velocity.set(reg.vecX, reg.vecY);
							case AddVelocityV:
								velocity.add(reg.vecX, reg.vecY);
							case AddPositionS:
								final vec = peekVecSkipped(0);
								position.add(vec.x, vec.y);
							case AddVelocityS:
								final vec = peekVecSkipped(0);
								position.add(vec.x, vec.y);
							case SetDistanceC:
								position.setDistance(readCodeF64());
							case AddDistanceC:
								position.addDistance(readCodeF64());
							case SetDistanceV:
								position.setDistance(reg.float);
							case AddDistanceV:
								position.addDistance(reg.float);
							case AddDistanceS:
								position.addDistance(peekFloat());
							case SetBearingC:
								position.setBearing(readCodeF64());
							case AddBearingC:
								position.addBearing(readCodeF64());
							case SetBearingV:
								position.setBearing(reg.float);
							case AddBearingV:
								position.addBearing(reg.float);
							case AddBearingS:
								position.addBearing(peekFloat());
							case SetSpeedC:
								velocity.setSpeed(readCodeF64());
							case AddSpeedC:
								velocity.addSpeed(readCodeF64());
							case SetSpeedV:
								velocity.setSpeed(reg.float);
							case AddSpeedV:
								velocity.addSpeed(reg.float);
							case AddSpeedS:
								velocity.addSpeed(peekFloat());
							case SetDirectionC:
								velocity.setDirection(readCodeF64());
							case AddDirectionC:
								velocity.addDirection(readCodeF64());
							case SetDirectionV:
								velocity.setDirection(reg.float);
							case AddDirectionV:
								velocity.addDirection(reg.float);
							case AddDirectionS:
								velocity.addDirection(peekFloat());
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

		updatePositionAndVelocity();

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
