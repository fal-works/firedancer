package firedancer.bytecode;

import banker.vector.Vector as RVec;
import banker.vector.WritableVector as Vec;
import reckoner.Random;
import firedancer.types.PositionRef;
import firedancer.types.Emitter;
import firedancer.types.EventHandler;
import firedancer.types.DebugCode;
import firedancer.assembly.Opcode;
import firedancer.assembly.operation.GeneralOperation;
import firedancer.assembly.operation.CalcOperation;
import firedancer.assembly.operation.ReadOperation;
import firedancer.assembly.operation.WriteOperation;
import firedancer.bytecode.internal.Constants.*;
import firedancer.bytecode.types.FireArgument;
import firedancer.common.Geometry;

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
		programTable: RVec<Program>,
		eventHandler: EventHandler,
		threads: ThreadList,
		memoryCapacity: UInt,
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

		final scan = new Scanner();
		final reg = new DataRegisterFile();
		final mem = new Memory(memoryCapacity);

		for (i in 0...threads.length) {
			final thread = threads[i];
			if (!thread.active) continue;

			scan.reset(thread);
			reg.reset(thread);
			mem.reset(thread);

			do {
				if (scan.reachedEnd()) {
					thread.deactivate();
					break;
				}

				final opcode = scan.opcode();

				switch opcode.category {
					case General:
						switch opcode.op {
							case Break:
								break;
							case CountDownBreak:
								if (0 < mem.peekInt()) {
									mem.decrement();
									scan.pc -= Opcode.size;
									break;
								} else {
									mem.dropInt();
								}
							case Goto:
								final address = scan.int();
								scan.pc = address;
							case CountDownGoto:
								if (0 < mem.peekInt()) {
									mem.decrement();
									scan.pc += LEN32; // skip the operand
								} else {
									mem.dropInt();
									final address = scan.int();
									scan.pc = address;
								}
							case UseThread:
								final programId = scan.int();
								threads.useSubThread(programTable[programId], thread);
							case UseThreadS:
								final programId = scan.int();
								final threadId = threads.useSubThread(
									programTable[programId],
									thread
								);
								mem.pushInt(threadId.int());
							case AwaitThread:
								if (threads[mem.peekInt()].active) {
									scan.pc -= Opcode.size;
									break;
								} else {
									mem.dropInt();
								}
							case End:
								final endCode = scan.int();
								threads.deactivateAll();
								updatePositionAndVelocity();
								return endCode;

							case LoadIntCV:
								reg.int = scan.int();
							case LoadFloatCV:
								reg.float = scan.float();
							case LoadVecCV:
								reg.setVec(scan.float(), scan.float());
							case SaveIntV:
								reg.saveInt();
							case SaveFloatV:
								reg.saveFloat();
							case LoadIntLV:
								reg.int = mem.getLocalInt(scan.int());
							case LoadFloatLV:
								reg.float = mem.getLocalFloat(scan.int());
							case StoreIntCL:
								mem.setLocalInt(scan.int(), scan.int());
							case StoreIntVL:
								mem.setLocalInt(scan.int(), reg.int);
							case StoreFloatCL:
								mem.setLocalFloat(scan.int(), scan.float());
							case StoreFloatVL:
								mem.setLocalFloat(scan.int(), reg.float);

							case PushIntC:
								mem.pushInt(scan.int());
							case PushIntV:
								mem.pushInt(reg.int);
							case PushFloatC:
								mem.pushFloat(scan.float());
							case PushFloatV:
								mem.pushFloat(reg.float);
							case PushVecV:
								mem.pushVec(reg.vecX, reg.vecY);
							case PopInt:
								reg.int = mem.popInt();
							case PopFloat:
								reg.float = mem.popFloat();
							case PeekFloat:
								reg.float = mem.peekFloatSkipped(scan.int());
							case DropFloat:
								mem.dropFloat();
							case PeekVec:
								final vec = mem.peekVecSkipped(scan.int());
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
								final arg: FireArgument = scan.int();
								final bytecode = Maybe.from(programTable[arg.programId]);
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
								final fireCode = scan.int();
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
								final arg: FireArgument = scan.int();
								final fireCode = scan.int();
								final bytecode = Maybe.from(programTable[arg.programId]);
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

							case Debug:
								final debugCode = scan.int();
								switch debugCode {
									case DebugCode.Dump:
										Debugger.dump(scan, mem, reg);
								}

							#if debug
							case other:
								throw 'Unknown general opcode: $other';
							#end
						}

					case Calc:
						switch opcode.op {
							case AddIntVCV:
								reg.int = reg.int + scan.int();
							case AddIntVVV:
								reg.int = reg.intBuf + reg.int;
							case SubIntVCV:
								reg.int = reg.int - scan.int();
							case SubIntCVV:
								reg.int = scan.int() - reg.int;
							case SubIntVVV:
								reg.int = reg.intBuf - reg.int;
							case MinusIntV:
								reg.int = -reg.int;
							case MultIntVCV:
								reg.int = reg.int * scan.int();
							case MultIntVVV:
								reg.int = reg.intBuf * reg.int;
							case DivIntVCV:
								reg.int = Ints.divide(reg.int, scan.int());
							case DivIntCVV:
								reg.int = Ints.divide(scan.int(), reg.int);
							case DivIntVVV:
								reg.int = Ints.divide(reg.intBuf, reg.int);
							case ModIntVCV:
								reg.int = reg.int % scan.int();
							case ModIntCVV:
								reg.int = scan.int() % reg.int;
							case ModIntVVV:
								reg.int = reg.intBuf % reg.int;

							case AddFloatVCV:
								reg.float = reg.float + scan.float();
							case AddFloatVVV:
								reg.float = reg.floatBuf + reg.float;
							case SubFloatVCV:
								reg.float = reg.float - scan.float();
							case SubFloatCVV:
								reg.float = scan.float() - reg.float;
							case SubFloatVVV:
								reg.float = reg.floatBuf - reg.float;
							case MinusFloatV:
								reg.float = -reg.float;
							case MultFloatVCV:
								reg.float = reg.float * scan.float();
							case MultFloatVVV:
								reg.float = reg.floatBuf * reg.float;
							case DivFloatVCV:
								reg.float = reg.float / scan.float();
							case DivFloatCVV:
								reg.float = scan.float() / reg.float;
							case DivFloatVVV:
								reg.float = reg.floatBuf / reg.float;
							case ModFloatVCV:
								reg.float = reg.float % scan.float();
							case ModFloatCVV:
								reg.float = scan.float() % reg.float;
							case ModFloatVVV:
								reg.float = reg.floatBuf % reg.float;

							case MinusVecV:
								reg.setVec(-reg.vecX, -reg.vecY);
							case MultVecVCV:
								final multiplier = scan.float();
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
								reg.float = Random.float(scan.float());
							case RandomFloatVV:
								reg.float = Random.float(reg.float);
							case RandomFloatSignedCV:
								reg.float = Random.signed(scan.float());
							case RandomFloatSignedVV:
								reg.float = Random.signed(reg.float);
							case RandomIntCV:
								reg.int = Random.int(scan.int());
							case RandomIntVV:
								reg.int = Random.int(reg.int);
							case RandomIntSignedCV:
								reg.int = Random.signedInt(scan.int());
							case RandomIntSignedVV:
								reg.int = Random.signedInt(reg.int);
							case Sin:
								reg.float = Geometry.sin(reg.float);
							case Cos:
								reg.float = Geometry.cos(reg.float);

							case AddIntLCL:
								mem.addLocalInt(scan.int(), scan.int());
							case AddIntLVL:
								mem.addLocalInt(scan.int(), reg.int);
							case IncrementL:
								mem.addLocalInt(scan.int(), 1);
							case DecrementL:
								mem.addLocalInt(scan.int(), -1);
							case AddFloatLCL:
								mem.addLocalFloat(scan.int(), scan.float());
							case AddFloatLVL:
								mem.addLocalFloat(scan.int(), reg.float);

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
								reg.setVec(scan.float() - position.x, scan.float() - position.y);
							case CalcRelativeVelocityCV:
								reg.setVec(scan.float() - velocity.x, scan.float() - velocity.y);
							case CalcRelativePositionVV:
								reg.setVec(reg.vecX - position.x, reg.vecY - position.y);
							case CalcRelativeVelocityVV:
								reg.setVec(reg.vecX - velocity.x, reg.vecY - velocity.y);
							case CalcRelativeDistanceCV:
								reg.float = scan.float() - position.getDistance();
							case CalcRelativeBearingCV:
								reg.float = Geometry.getAngleDifference(
									position.getBearing(),
									scan.float()
								);
							case CalcRelativeSpeedCV:
								reg.float = scan.float() - velocity.getSpeed();
							case CalcRelativeDirectionCV:
								reg.float = Geometry.getAngleDifference(
									velocity.getDirection(),
									scan.float()
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
									scan.float() - thread.shotX,
									scan.float() - thread.shotY
								);
							case CalcRelativeShotVelocityCV:
								reg.setVec(
									scan.float() - thread.shotVx,
									scan.float() - thread.shotVy
								);
							case CalcRelativeShotPositionVV:
								reg.setVec(reg.vecX - thread.shotX, reg.vecY - thread.shotY);
							case CalcRelativeShotVelocityVV:
								reg.setVec(reg.vecX - thread.shotVx, reg.vecY - thread.shotVy);
							case CalcRelativeShotDistanceCV:
								reg.float = scan.float() - thread.getShotDistance();
							case CalcRelativeShotBearingCV:
								reg.float = Geometry.getAngleDifference(
									thread.getShotBearing(),
									scan.float()
								);
							case CalcRelativeShotSpeedCV:
								reg.float = scan.float() - thread.getShotSpeed();
							case CalcRelativeShotDirectionCV:
								reg.float = Geometry.getAngleDifference(
									thread.getShotDirection(),
									scan.float()
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
								position.set(scan.float(), scan.float());
							case AddPositionC:
								position.add(scan.float(), scan.float());
							case SetVelocityC:
								velocity.set(scan.float(), scan.float());
							case AddVelocityC:
								velocity.add(scan.float(), scan.float());
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
								position.setDistance(scan.float());
							case AddDistanceC:
								position.addDistance(scan.float());
							case SetDistanceV:
								position.setDistance(reg.float);
							case AddDistanceV:
								position.addDistance(reg.float);
							case AddDistanceS:
								position.addDistance(mem.peekFloat());
							case SetBearingC:
								position.setBearing(scan.float());
							case AddBearingC:
								position.addBearing(scan.float());
							case SetBearingV:
								position.setBearing(reg.float);
							case AddBearingV:
								position.addBearing(reg.float);
							case AddBearingS:
								position.addBearing(mem.peekFloat());
							case SetSpeedC:
								velocity.setSpeed(scan.float());
							case AddSpeedC:
								velocity.addSpeed(scan.float());
							case SetSpeedV:
								velocity.setSpeed(reg.float);
							case AddSpeedV:
								velocity.addSpeed(reg.float);
							case AddSpeedS:
								velocity.addSpeed(mem.peekFloat());
							case SetDirectionC:
								velocity.setDirection(scan.float());
							case AddDirectionC:
								velocity.addDirection(scan.float());
							case SetDirectionV:
								velocity.setDirection(reg.float);
							case AddDirectionV:
								velocity.addDirection(reg.float);
							case AddDirectionS:
								velocity.addDirection(mem.peekFloat());
							case SetShotPositionC:
								thread.setShotPosition(scan.float(), scan.float());
							case AddShotPositionC:
								thread.addShotPosition(scan.float(), scan.float());
							case SetShotVelocityC:
								thread.setShotVelocity(scan.float(), scan.float());
							case AddShotVelocityC:
								thread.addShotVelocity(scan.float(), scan.float());
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
								thread.setShotDistance(scan.float());
							case AddShotDistanceC:
								thread.addShotDistance(scan.float());
							case SetShotDistanceV:
								thread.setShotDistance(reg.float);
							case AddShotDistanceV:
								thread.addShotDistance(reg.float);
							case AddShotDistanceS:
								thread.addShotDistance(mem.peekFloat());
							case SetShotBearingC:
								thread.setShotBearing(scan.float());
							case AddShotBearingC:
								thread.addShotBearing(scan.float());
							case SetShotBearingV:
								thread.setShotBearing(reg.float);
							case AddShotBearingV:
								thread.addShotBearing(reg.float);
							case AddShotBearingS:
								thread.addShotBearing(mem.peekFloat());
							case SetShotSpeedC:
								thread.setShotSpeed(scan.float());
							case AddShotSpeedC:
								thread.addShotSpeed(scan.float());
							case SetShotSpeedV:
								thread.setShotSpeed(reg.float);
							case AddShotSpeedV:
								thread.addShotSpeed(reg.float);
							case AddShotSpeedS:
								thread.addShotSpeed(mem.peekFloat());
							case SetShotDirectionC:
								thread.setShotDirection(scan.float());
							case AddShotDirectionC:
								thread.addShotDirection(scan.float());
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

				scan.checkInfinite(infiniteLoopCheckThreshold);
			} while (true);

			thread.update(scan.pc, mem.sp);
		}

		updatePositionAndVelocity();

		return 0;
	}

	public static function dryRun(
		pkg: ProgramPackage,
		entryBytecodeName: String,
		memoryCapacity: UInt = 256
	): Void {
		final eventHandler = new NullEventHandler();
		final threads = new ThreadList(1, memoryCapacity);
		final bytecode = pkg.getProgramByName(entryBytecodeName);
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
				pkg.programTable,
				eventHandler,
				threads,
				memoryCapacity,
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

}
