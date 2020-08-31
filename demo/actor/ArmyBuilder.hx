package actor;

import firedancer.vm.ProgramPackage;

/**
	Functions internally used in `Army.new()`.
**/
class ArmyBuilder {
	static var defaultChunkCapacity: UInt = 64;

	public static function createActors(
		maxEntityCount: UInt,
		programPackage: ProgramPackage,
		batch: BatchDraw,
		tile: Tile,
		?bullets: ActorAosoa
	): ActorAosoa {
		final chunkCapacity = UInts.min(defaultChunkCapacity, maxEntityCount);
		final chunkCount = Math.ceil(maxEntityCount / chunkCapacity);

		var aosoa: ActorAosoa;

		final spriteFactory = () -> new BatchSprite(tile);

		final programTable = programPackage.programTable;
		final eventHandler = new TestEventHandler();
		final emitter = new Emitter(Nulls.coalesce(bullets, aosoa));

		aosoa = new ActorAosoa(
			chunkCapacity,
			chunkCount,
			batch,
			spriteFactory,
			programTable,
			eventHandler,
			emitter
		);
		return aosoa;
	}
}
