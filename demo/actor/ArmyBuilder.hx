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
		eventHandler: EventHandler,
		emitter: Emitter
	): ActorAosoa {
		final chunkCapacity = UInts.min(defaultChunkCapacity, maxEntityCount);
		final chunkCount = Math.ceil(maxEntityCount / chunkCapacity);

		final spriteFactory = () -> new BatchSprite(tile);
		final programTable = programPackage.programTable;

		final aosoa = new ActorAosoa(
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
