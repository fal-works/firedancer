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

		var endCode = 0;
		var deactivateAllThreads = false;

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
						endCode = scan.int();
						deactivateAllThreads = true;
						break;
					case NoOperation:
						// Does nothing

					case LoadIntCR:
						reg.int = scan.int();
					case LoadIntBR:
						reg.int = reg.intBuf;
					case LoadFloatCR:
						reg.float = scan.float();
					case LoadFloatBR:
						reg.float = reg.floatBuf;
					case LoadVecCR:
						reg.setVec(scan.float(), scan.float());
					case SaveIntC:
						reg.intBuf = scan.int();
					case SaveIntR:
						reg.saveInt();
					case SaveFloatC:
						reg.floatBuf = scan.float();
					case SaveFloatR:
						reg.saveFloat();
					case LoadIntVR:
						reg.int = mem.getLocalInt(scan.int());
					case LoadFloatVR:
						reg.float = mem.getLocalFloat(scan.int());
					case StoreIntCV:
						mem.setLocalInt(scan.int(), scan.int());
					case StoreIntRV:
						mem.setLocalInt(scan.int(), reg.int);
					case StoreFloatCV:
						mem.setLocalFloat(scan.int(), scan.float());
					case StoreFloatRV:
						mem.setLocalFloat(scan.int(), reg.float);

					case PushIntC:
						mem.pushInt(scan.int());
					case PushIntR:
						mem.pushInt(reg.int);
					case PushFloatC:
						mem.pushFloat(scan.float());
					case PushFloatR:
						mem.pushFloat(reg.float);
					case PushVecR:
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
						final arg:FireArgument = scan.int();
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
						final arg:FireArgument = scan.int();
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

					case GlobalEventR:
						eventHandler.onGlobalEvent(reg.int);
					case LocalEventR:
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
					case AddIntRCR:
						reg.int = reg.int + scan.int();
					case AddIntRRR:
						reg.int = reg.intBuf + reg.int;
					case SubIntRCR:
						reg.int = reg.int - scan.int();
					case SubIntCRR:
						reg.int = scan.int() - reg.int;
					case SubIntRRR:
						reg.int = reg.intBuf - reg.int;
					case MinusIntRR:
						reg.int = -reg.int;
					case MultIntRCR:
						reg.int = reg.int * scan.int();
					case MultIntRRR:
						reg.int = reg.intBuf * reg.int;
					case DivIntRCR:
						reg.int = Ints.divide(reg.int, scan.int());
					case DivIntCRR:
						reg.int = Ints.divide(scan.int(), reg.int);
					case DivIntRRR:
						reg.int = Ints.divide(reg.intBuf, reg.int);
					case ModIntRCR:
						reg.int = reg.int % scan.int();
					case ModIntCRR:
						reg.int = scan.int() % reg.int;
					case ModIntRRR:
						reg.int = reg.intBuf % reg.int;

					case AddFloatRCR:
						reg.float = reg.float + scan.float();
					case AddFloatRRR:
						reg.float = reg.floatBuf + reg.float;
					case SubFloatRCR:
						reg.float = reg.float - scan.float();
					case SubFloatCRR:
						reg.float = scan.float() - reg.float;
					case SubFloatRRR:
						reg.float = reg.floatBuf - reg.float;
					case MinusFloatRR:
						reg.float = -reg.float;
					case MultFloatRCR:
						reg.float = reg.float * scan.float();
					case MultFloatRRR:
						reg.float = reg.floatBuf * reg.float;
					case DivFloatRCR:
						reg.float = reg.float / scan.float();
					case DivFloatCRR:
						reg.float = scan.float() / reg.float;
					case DivFloatRRR:
						reg.float = reg.floatBuf / reg.float;
					case ModFloatRCR:
						reg.float = reg.float % scan.float();
					case ModFloatCRR:
						reg.float = scan.float() % reg.float;
					case ModFloatRRR:
						reg.float = reg.floatBuf % reg.float;

					case MinusVecRR:
						reg.setVec(-reg.vecX, -reg.vecY);
					case MultVecRCR:
						final multiplier = scan.float();
						reg.setVec(reg.vecX * multiplier, reg.vecY * multiplier);
					case MultVecRRR:
						reg.setVec(reg.vecX * reg.float, reg.vecY * reg.float);
					case DivVecRRR:
						reg.setVec(reg.vecX / reg.float, reg.vecY / reg.float);
					case CastIntToFloatRR:
						reg.float = reg.int;
					case CastCartesianRR:
						reg.setVec(reg.floatBuf, reg.float);
					case CastPolarRR:
						final vec = Geometry.toVec(reg.floatBuf, reg.float);
						reg.setVec(vec.x, vec.y);

					case RandomRatioR:
						reg.float = Random.random();
					case RandomFloatCR:
						reg.float = Random.float(scan.float());
					case RandomFloatRR:
						reg.float = Random.float(reg.float);
					case RandomFloatSignedCR:
						reg.float = Random.signed(scan.float());
					case RandomFloatSignedRR:
						reg.float = Random.signed(reg.float);
					case RandomIntCR:
						reg.int = Random.int(scan.int());
					case RandomIntRR:
						reg.int = Random.int(reg.int);
					case RandomIntSignedCR:
						reg.int = Random.signedInt(scan.int());
					case RandomIntSignedRR:
						reg.int = Random.signedInt(reg.int);
					case SinRR:
						reg.float = Geometry.sin(reg.float);
					case CosRR:
						reg.float = Geometry.cos(reg.float);

					case AddIntVCV:
						mem.addLocalInt(scan.int(), scan.int());
					case AddIntVRV:
						mem.addLocalInt(scan.int(), reg.int);
					case IncrementVV:
						mem.addLocalInt(scan.int(), 1);
					case DecrementVV:
						mem.addLocalInt(scan.int(), -1);
					case AddFloatVCV:
						mem.addLocalFloat(scan.int(), scan.float());
					case AddFloatVRV:
						mem.addLocalFloat(scan.int(), reg.float);

						#if debug
						case other:
							throw 'Unknown calc opcode: $other';
						#end
					}

				case Read:
					switch opcode.op {
					case LoadPositionR:
						reg.setVec(position.x, position.y);
					case LoadDistanceR:
						reg.float = position.getDistance();
					case LoadBearingR:
						reg.float = position.getBearing();
					case LoadVelocityR:
						reg.setVec(velocity.x, velocity.y);
					case LoadSpeedR:
						reg.float = velocity.getSpeed();
					case LoadDirectionR:
						reg.float = velocity.getDirection();
					case LoadShotPositionR:
						reg.setVec(thread.shotX, thread.shotY);
					case LoadShotDistanceR:
						reg.float = thread.getShotDistance();
					case LoadShotBearingR:
						reg.float = thread.getShotBearing();
					case LoadShotVelocityR:
						reg.setVec(thread.shotVx, thread.shotVy);
					case LoadShotSpeedR:
						reg.float = thread.getShotSpeed();
					case LoadShotDirectionR:
						reg.float = thread.getShotDirection();

					case LoadTargetPositionR:
						reg.setVec(targetPositionRef.x, targetPositionRef.y);
					case LoadTargetXR:
						reg.float = targetPositionRef.x;
					case LoadTargetYR:
						reg.float = targetPositionRef.y;
					case LoadAngleToTargetR:
						reg.float = Geometry.getAngle(
							targetPositionRef.x - (position.getAbsoluteX() + thread.shotX),
							targetPositionRef.y - (position.getAbsoluteY() + thread.shotY)
						);

					case GetDiffPositionCR:
						reg.setVec(scan.float() - position.x, scan.float() - position.y);
					case GetDiffVelocityCR:
						reg.setVec(scan.float() - velocity.x, scan.float() - velocity.y);
					case GetDiffPositionRR:
						reg.setVec(reg.vecX - position.x, reg.vecY - position.y);
					case GetDiffVelocityRR:
						reg.setVec(reg.vecX - velocity.x, reg.vecY - velocity.y);
					case GetDiffDistanceCR:
						reg.float = scan.float() - position.getDistance();
					case GetDiffBearingCR:
						reg.float = Geometry.getAngleDifference(
							position.getBearing(),
							scan.float()
						);
					case GetDiffSpeedCR:
						reg.float = scan.float() - velocity.getSpeed();
					case GetDiffDirectionCR:
						reg.float = Geometry.getAngleDifference(
							velocity.getDirection(),
							scan.float()
						);
					case GetDiffDistanceRR:
						reg.float = reg.float - position.getDistance();
					case GetDiffBearingRR:
						reg.float = Geometry.getAngleDifference(position.getBearing(), reg.float);
					case GetDiffSpeedRR:
						reg.float = reg.float - velocity.getSpeed();
					case GetDiffDirectionRR:
						reg.float = Geometry.getAngleDifference(
							velocity.getDirection(),
							reg.float
						);

					case GetDiffShotPositionCR:
						reg.setVec(
							scan.float() - thread.shotX,
							scan.float() - thread.shotY
						);
					case GetDiffShotVelocityCR:
						reg.setVec(
							scan.float() - thread.shotVx,
							scan.float() - thread.shotVy
						);
					case GetDiffShotPositionRR:
						reg.setVec(reg.vecX - thread.shotX, reg.vecY - thread.shotY);
					case GetDiffShotVelocityRR:
						reg.setVec(reg.vecX - thread.shotVx, reg.vecY - thread.shotVy);
					case GetDiffShotDistanceCR:
						reg.float = scan.float() - thread.getShotDistance();
					case GetDiffShotBearingCR:
						reg.float = Geometry.getAngleDifference(
							thread.getShotBearing(),
							scan.float()
						);
					case GetDiffShotSpeedCR:
						reg.float = scan.float() - thread.getShotSpeed();
					case GetDiffShotDirectionCR:
						reg.float = Geometry.getAngleDifference(
							thread.getShotDirection(),
							scan.float()
						);
					case GetDiffShotDistanceRR:
						reg.float = reg.float - thread.getShotDistance();
					case GetDiffShotBearingRR:
						reg.float = Geometry.getAngleDifference(
							thread.getShotBearing(),
							reg.float
						);
					case GetDiffShotSpeedRR:
						reg.float = reg.float - thread.getShotSpeed();
					case GetDiffShotDirectionRR:
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
					case SetPositionR:
						position.set(reg.vecX, reg.vecY);
					case AddPositionR:
						position.add(reg.vecX, reg.vecY);
					case SetVelocityR:
						velocity.set(reg.vecX, reg.vecY);
					case AddVelocityR:
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
					case SetDistanceR:
						position.setDistance(reg.float);
					case AddDistanceR:
						position.addDistance(reg.float);
					case AddDistanceS:
						position.addDistance(mem.peekFloat());
					case SetBearingC:
						position.setBearing(scan.float());
					case AddBearingC:
						position.addBearing(scan.float());
					case SetBearingR:
						position.setBearing(reg.float);
					case AddBearingR:
						position.addBearing(reg.float);
					case AddBearingS:
						position.addBearing(mem.peekFloat());
					case SetSpeedC:
						velocity.setSpeed(scan.float());
					case AddSpeedC:
						velocity.addSpeed(scan.float());
					case SetSpeedR:
						velocity.setSpeed(reg.float);
					case AddSpeedR:
						velocity.addSpeed(reg.float);
					case AddSpeedS:
						velocity.addSpeed(mem.peekFloat());
					case SetDirectionC:
						velocity.setDirection(scan.float());
					case AddDirectionC:
						velocity.addDirection(scan.float());
					case SetDirectionR:
						velocity.setDirection(reg.float);
					case AddDirectionR:
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
					case SetShotPositionR:
						thread.setShotPosition(reg.vecX, reg.vecY);
					case AddShotPositionR:
						thread.addShotPosition(reg.vecX, reg.vecY);
					case SetShotVelocityR:
						thread.setShotVelocity(reg.vecX, reg.vecY);
					case AddShotVelocityR:
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
					case SetShotDistanceR:
						thread.setShotDistance(reg.float);
					case AddShotDistanceR:
						thread.addShotDistance(reg.float);
					case AddShotDistanceS:
						thread.addShotDistance(mem.peekFloat());
					case SetShotBearingC:
						thread.setShotBearing(scan.float());
					case AddShotBearingC:
						thread.addShotBearing(scan.float());
					case SetShotBearingR:
						thread.setShotBearing(reg.float);
					case AddShotBearingR:
						thread.addShotBearing(reg.float);
					case AddShotBearingS:
						thread.addShotBearing(mem.peekFloat());
					case SetShotSpeedC:
						thread.setShotSpeed(scan.float());
					case AddShotSpeedC:
						thread.addShotSpeed(scan.float());
					case SetShotSpeedR:
						thread.setShotSpeed(reg.float);
					case AddShotSpeedR:
						thread.addShotSpeed(reg.float);
					case AddShotSpeedS:
						thread.addShotSpeed(mem.peekFloat());
					case SetShotDirectionC:
						thread.setShotDirection(scan.float());
					case AddShotDirectionC:
						thread.addShotDirection(scan.float());
					case SetShotDirectionR:
						thread.setShotDirection(reg.float);
					case AddShotDirectionR:
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
		if (deactivateAllThreads) threads.deactivateAll();

		return endCode;
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
