package actor;

/**
	Functions internally used in `Army.new()`.
**/
class ArmyBuilder {
	static var defaultChunkCapacity: UInt = 64;

	public static function createActors(
		maxEntityCount: UInt,
		batch: BatchDraw,
		tile: Tile,
		?bullets: ActorAosoa
	): ActorAosoa {
		final chunkCapacity = UInts.min(defaultChunkCapacity, maxEntityCount);
		final chunkCount = Math.ceil(maxEntityCount / chunkCapacity);

		var aosoa: ActorAosoa;

		final spriteFactory = () -> new BatchSprite(tile);

		final fireCallback = if (bullets != null) {
			function(x, y, speed, direction) {
				bullets.emit(x, y, speed, direction, BulletPatterns.none);
			}
		} else {
			function(x, y, speed, direction) {
				aosoa.emit(x, y, speed, direction, BulletPatterns.none);
			}
		};

		aosoa = new ActorAosoa(
			chunkCapacity,
			chunkCount,
			batch,
			spriteFactory,
			fireCallback
		);
		return aosoa;
	}
}
