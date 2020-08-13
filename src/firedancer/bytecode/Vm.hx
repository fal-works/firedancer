package firedancer.bytecode;

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
		final reg = new RegisterFile();
		final mem = new Memory(stackCapacity);

		inline function readOp(): Opcode {
			final opcode: Opcode = cast code.getUI8(reg.pc);
			#if firedancer_verbose
			println('${opcode.toString()} (pos: $reg.pc)');
			#end
			reg.pc += Opcode.size;
			return opcode;
		}

		inline function readI32(): Int32 {
			final v = code.getI32(reg.pc);
			reg.pc += LEN32;
			return v;
		}

		inline function readF64(): Float {
			final v = code.getF64(reg.pc);
			reg.pc += LEN64;
			return v;
		}

		for (i in 0...threads.length) {
			final thread = threads[i];
			if (!thread.active) continue;

			code = thread.code.unwrap();
			reg.reset(thread);
			mem.reset(thread);

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
								if (0 < mem.peekInt()) {
									mem.decrement();
									reg.pc -= Opcode.size;
									break;
								} else {
									mem.dropInt();
								}
							case Jump:
								final jumpLength = readI32();
								reg.pc += jumpLength;
							case CountDownJump:
								if (0 < mem.peekInt()) {
									mem.decrement();
									reg.pc += LEN32; // skip the operand
								} else {
									mem.dropInt();
									final jumpLength = readI32();
									reg.pc += jumpLength;
								}
							case UseThread:
								final bytecodeId = readI32();
								threads.useSubThread(bytecodeTable[bytecodeId], thread);
							case UseThreadS:
								final bytecodeId = readI32();
								final threadId = threads.useSubThread(
									bytecodeTable[bytecodeId],
									thread
								);
								mem.pushInt(threadId.int());
							case AwaitThread:
								if (threads[mem.peekInt()].active) {
									reg.pc -= Opcode.size;
									break;
								} else {
									mem.dropInt();
								}
							case End:
								final endCode = readI32();
								threads.deactivateAll();
								updatePositionAndVelocity();
								return endCode;

							case LoadIntCV:
								reg.int = readI32();
							case LoadFloatCV:
								reg.float = readF64();
							case LoadVecCV:
								reg.setVec(readF64(), readF64());
							case SaveIntV:
								reg.saveInt();
							case SaveFloatV:
								reg.saveFloat();
							case LoadIntLV:
								reg.int = mem.getLocalInt(readI32());
							case LoadFloatLV:
								reg.float = mem.getLocalFloat(readI32());
							case StoreIntCL:
								mem.setLocalInt(readI32(), readI32());
							case StoreIntVL:
								mem.setLocalInt(readI32(), reg.int);
							case StoreFloatCL:
								mem.setLocalFloat(readI32(), readF64());
							case StoreFloatVL:
								mem.setLocalFloat(readI32(), reg.float);

							case PushIntC:
								mem.pushInt(readI32());
							case PushIntV:
								mem.pushInt(reg.int);
							case PushFloatC:
								mem.pushFloat(readF64());
							case PushFloatV:
								mem.pushFloat(reg.float);
							case PushVecV:
								mem.pushVec(reg.vecX, reg.vecY);
							case PeekFloat:
								reg.float = mem.peekFloatSkipped(readI32());
							case DropFloat:
								mem.dropFloat();
							case PeekVec:
								final vec = mem.peekVecSkipped(readI32());
								reg.setVec(vec.x, vec.y);
							case DropVec:
								mem.dropVec();

							case FireSimple:
								emitter.emit(
									position.getAbsoluteX() + thread.shotX,
									position.getAbsoluteY() + thread.shotY,
									thread.shotVx,
									thread.shotVy,
									0,
									Maybe.none(),
									Maybe.none()
								);
							case FireComplex:
								final arg: FireArgument = readI32();
								final bytecode = Maybe.from(bytecodeTable[arg.bytecodeId]);
								emitter.emit(
									position.getAbsoluteX() + thread.shotX,
									position.getAbsoluteY() + thread.shotY,
									thread.shotVx,
									thread.shotVy,
									0, // default fire code
									bytecode,
									if (arg.bindPosition) Maybe.from(thisPositionRef) else Maybe.none()
								);
							case FireSimpleWithCode:
								final fireCode = readI32();
								emitter.emit(
									position.getAbsoluteX() + thread.shotX,
									position.getAbsoluteY() + thread.shotY,
									thread.shotVx,
									thread.shotVy,
									fireCode,
									Maybe.none(),
									Maybe.none()
								);
							case FireComplexWithCode:
								final arg: FireArgument = readI32();
								final fireCode = readI32();
								final bytecode = Maybe.from(bytecodeTable[arg.bytecodeId]);
								emitter.emit(
									position.getAbsoluteX() + thread.shotX,
									position.getAbsoluteY() + thread.shotY,
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
								reg.int = reg.int + readI32();
							case AddIntVVV:
								reg.int = reg.intBuf + reg.int;
							case SubIntVCV:
								reg.int = reg.int - readI32();
							case SubIntCVV:
								reg.int = readI32() - reg.int;
							case SubIntVVV:
								reg.int = reg.intBuf - reg.int;
							case MinusIntV:
								reg.int = -reg.int;
							case MultIntVCV:
								reg.int = reg.int * readI32();
							case MultIntVVV:
								reg.int = reg.intBuf * reg.int;
							case DivIntVCV:
								reg.int = Ints.divide(reg.int, readI32());
							case DivIntCVV:
								reg.int = Ints.divide(readI32(), reg.int);
							case DivIntVVV:
								reg.int = Ints.divide(reg.intBuf, reg.int);
							case ModIntVCV:
								reg.int = reg.int % readI32();
							case ModIntCVV:
								reg.int = readI32() % reg.int;
							case ModIntVVV:
								reg.int = reg.intBuf % reg.int;

							case AddFloatVCV:
								reg.float = reg.float + readF64();
							case AddFloatVVV:
								reg.float = reg.floatBuf + reg.float;
							case SubFloatVCV:
								reg.float = reg.float - readF64();
							case SubFloatCVV:
								reg.float = readF64() - reg.float;
							case SubFloatVVV:
								reg.float = reg.floatBuf - reg.float;
							case MinusFloatV:
								reg.float = -reg.float;
							case MultFloatVCV:
								reg.float = reg.float * readF64();
							case MultFloatVVV:
								reg.float = reg.floatBuf * reg.float;
							case DivFloatCVV:
								reg.float = readF64() / reg.float;
							case DivFloatVVV:
								reg.float = reg.floatBuf / reg.float;
							case ModFloatVCV:
								reg.float = reg.float % readF64();
							case ModFloatCVV:
								reg.float = readF64() % reg.float;
							case ModFloatVVV:
								reg.float = reg.floatBuf % reg.float;

							case MinusVecV:
								reg.setVec(-reg.vecX, -reg.vecY);
							case MultVecVCV:
								final multiplier = readF64();
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
								reg.float = Random.float(readF64());
							case RandomFloatVV:
								reg.float = Random.float(reg.float);
							case RandomFloatSignedCV:
								reg.float = Random.signed(readF64());
							case RandomFloatSignedVV:
								reg.float = Random.signed(reg.float);
							case RandomIntCV:
								reg.int = Random.int(readI32());
							case RandomIntVV:
								reg.int = Random.int(reg.int);
							case RandomIntSignedCV:
								reg.int = Random.signedInt(readI32());
							case RandomIntSignedVV:
								reg.int = Random.signedInt(reg.int);

							case AddIntLCL:
								mem.addLocalInt(readI32(), readI32());
							case AddIntLVL:
								mem.addLocalInt(readI32(), reg.int);
							case IncrementL:
								mem.addLocalInt(readI32(), 1);
							case DecrementL:
								mem.addLocalInt(readI32(), -1);
							case AddFloatLCL:
								mem.addLocalFloat(readI32(), readF64());
							case AddFloatLVL:
								mem.addLocalFloat(readI32(), reg.float);

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
								reg.setVec(readF64() - position.x, readF64() - position.y);
							case CalcRelativeVelocityCV:
								reg.setVec(readF64() - velocity.x, readF64() - velocity.y);
							case CalcRelativePositionVV:
								reg.setVec(reg.vecX - position.x, reg.vecY - position.y);
							case CalcRelativeVelocityVV:
								reg.setVec(reg.vecX - velocity.x, reg.vecY - velocity.y);
							case CalcRelativeDistanceCV:
								reg.float = readF64() - position.getDistance();
							case CalcRelativeBearingCV:
								reg.float = Geometry.getAngleDifference(
									position.getBearing(),
									readF64()
								);
							case CalcRelativeSpeedCV:
								reg.float = readF64() - velocity.getSpeed();
							case CalcRelativeDirectionCV:
								reg.float = Geometry.getAngleDifference(
									velocity.getDirection(),
									readF64()
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
									readF64() - thread.shotX,
									readF64() - thread.shotY
								);
							case CalcRelativeShotVelocityCV:
								reg.setVec(
									readF64() - thread.shotVx,
									readF64() - thread.shotVy
								);
							case CalcRelativeShotPositionVV:
								reg.setVec(reg.vecX - thread.shotX, reg.vecY - thread.shotY);
							case CalcRelativeShotVelocityVV:
								reg.setVec(reg.vecX - thread.shotVx, reg.vecY - thread.shotVy);
							case CalcRelativeShotDistanceCV:
								reg.float = readF64() - thread.getShotDistance();
							case CalcRelativeShotBearingCV:
								reg.float = Geometry.getAngleDifference(
									thread.getShotBearing(),
									readF64()
								);
							case CalcRelativeShotSpeedCV:
								reg.float = readF64() - thread.getShotSpeed();
							case CalcRelativeShotDirectionCV:
								reg.float = Geometry.getAngleDifference(
									thread.getShotDirection(),
									readF64()
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
								position.set(readF64(), readF64());
							case AddPositionC:
								position.add(readF64(), readF64());
							case SetVelocityC:
								velocity.set(readF64(), readF64());
							case AddVelocityC:
								velocity.add(readF64(), readF64());
							case SetPositionV:
								position.set(reg.vecX, reg.vecY);
							case AddPositionV:
								position.add(reg.vecX, reg.vecY);
							case SetVelocityV:
								velocity.set(reg.vecX, reg.vecY);
							case AddVelocityV:
								velocity.add(reg.vecX, reg.vecY);
							case AddPositionS:
								final vec = mem.peekVecSkipped(0);
								position.add(vec.x, vec.y);
							case AddVelocityS:
								final vec = mem.peekVecSkipped(0);
								position.add(vec.x, vec.y);
							case SetDistanceC:
								position.setDistance(readF64());
							case AddDistanceC:
								position.addDistance(readF64());
							case SetDistanceV:
								position.setDistance(reg.float);
							case AddDistanceV:
								position.addDistance(reg.float);
							case AddDistanceS:
								position.addDistance(mem.peekFloat());
							case SetBearingC:
								position.setBearing(readF64());
							case AddBearingC:
								position.addBearing(readF64());
							case SetBearingV:
								position.setBearing(reg.float);
							case AddBearingV:
								position.addBearing(reg.float);
							case AddBearingS:
								position.addBearing(mem.peekFloat());
							case SetSpeedC:
								velocity.setSpeed(readF64());
							case AddSpeedC:
								velocity.addSpeed(readF64());
							case SetSpeedV:
								velocity.setSpeed(reg.float);
							case AddSpeedV:
								velocity.addSpeed(reg.float);
							case AddSpeedS:
								velocity.addSpeed(mem.peekFloat());
							case SetDirectionC:
								velocity.setDirection(readF64());
							case AddDirectionC:
								velocity.addDirection(readF64());
							case SetDirectionV:
								velocity.setDirection(reg.float);
							case AddDirectionV:
								velocity.addDirection(reg.float);
							case AddDirectionS:
								velocity.addDirection(mem.peekFloat());
							case SetShotPositionC:
								thread.setShotPosition(readF64(), readF64());
							case AddShotPositionC:
								thread.addShotPosition(readF64(), readF64());
							case SetShotVelocityC:
								thread.setShotVelocity(readF64(), readF64());
							case AddShotVelocityC:
								thread.addShotVelocity(readF64(), readF64());
							case SetShotPositionV:
								thread.setShotPosition(reg.vecX, reg.vecY);
							case AddShotPositionV:
								thread.addShotPosition(reg.vecX, reg.vecY);
							case SetShotVelocityV:
								thread.setShotVelocity(reg.vecX, reg.vecY);
							case AddShotVelocityV:
								thread.addShotVelocity(reg.vecX, reg.vecY);
							case AddShotPositionS:
								final vec = mem.peekVecSkipped(0);
								thread.addShotPosition(vec.x, vec.y);
							case AddShotVelocityS:
								final vec = mem.peekVecSkipped(0);
								thread.addShotVelocity(vec.x, vec.y);
							case SetShotDistanceC:
								thread.setShotDistance(readF64());
							case AddShotDistanceC:
								thread.addShotDistance(readF64());
							case SetShotDistanceV:
								thread.setShotDistance(reg.float);
							case AddShotDistanceV:
								thread.addShotDistance(reg.float);
							case AddShotDistanceS:
								thread.addShotDistance(mem.peekFloat());
							case SetShotBearingC:
								thread.setShotBearing(readF64());
							case AddShotBearingC:
								thread.addShotBearing(readF64());
							case SetShotBearingV:
								thread.setShotBearing(reg.float);
							case AddShotBearingV:
								thread.addShotBearing(reg.float);
							case AddShotBearingS:
								thread.addShotBearing(mem.peekFloat());
							case SetShotSpeedC:
								thread.setShotSpeed(readF64());
							case AddShotSpeedC:
								thread.addShotSpeed(readF64());
							case SetShotSpeedV:
								thread.setShotSpeed(reg.float);
							case AddShotSpeedV:
								thread.addShotSpeed(reg.float);
							case AddShotSpeedS:
								thread.addShotSpeed(mem.peekFloat());
							case SetShotDirectionC:
								thread.setShotDirection(readF64());
							case AddShotDirectionC:
								thread.addShotDirection(readF64());
							case SetShotDirectionV:
								thread.setShotDirection(reg.float);
							case AddShotDirectionV:
								thread.addShotDirection(reg.float);
							case AddShotDirectionS:
								thread.addShotDirection(mem.peekFloat());

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

			thread.update(reg.pc, mem.sp);
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
