package actor;

@:banker_verified
class Actor extends broker.entity.BasicBatchEntity {
	/**
		Clojure function for emitting a new bullet.
	**/
	@:banker_chunkLevelFinal
	var fire: FireCallback;

	/**
		Rotation velocity.
	**/
	@:banker_chunkLevelFinal
	var rotationVelocity: Float = 0.03;

	/**
		`firedancer` bytecode.
	**/
	var fdCode: BytecodeData = BulletPatterns.none.data;

	/**
		The entire length of `fdCode`.
	**/
	var fdCodeLength: UInt = UInt.zero;

	/**
		Current position in `fdCode`.
	**/
	var fdCodePos: UInt = UInt.zero;

	/**
		`firedancer` data stack.
	**/
	@:banker.factory(() -> ByteStackData.alloc(64))
	var fdStack: ByteStackData;

	/**
		Current size of data in `fdStack`.
	**/
	var fdStackSize: UInt = UInt.zero;

	/**
		Elapsed frame count of each entity.
	**/
	var frameCount: UInt = UInt.zero;

	/**
		`true` if the entity should be disused in the next call of `update()`.
		May be set in collision detection process.
	**/
	var dead: Bool = false;

	@:banker_useEntity
	static function emit(
		sprite: BatchSprite,
		x: WVec<Float>,
		y: WVec<Float>,
		vx: WVec<Float>,
		vy: WVec<Float>,
		fdCode: WVec<BytecodeData>,
		fdCodeLength: WVec<UInt>,
		fdCodePos: WVec<UInt>,
		fdStackSize: WVec<UInt>,
		frameCount: WVec<UInt>,
		dead: WVec<Bool>,
		i: Int,
		usedSprites: WVec<BatchSprite>,
		usedCount: Int,
		initialX: Float,
		initialY: Float,
		speed: Float,
		direction: Float,
		pattern: Bytecode
	): Void {
		x[i] = initialX;
		y[i] = initialY;
		vx[i] = speed * Math.cos(direction);
		vy[i] = speed * Math.sin(direction);
		fdCode[i] = pattern.data;
		fdCodeLength[i] = pattern.length;
		fdCodePos[i] = UInt.zero;
		fdStackSize[i] = UInt.zero;
		frameCount[i] = UInt.zero;
		dead[i] = false;
		usedSprites[usedCount] = sprite;
		++usedCount;
	}

	/**
		Disuses all entities currently in use.
	**/
	static function crashAll(
		x: Float,
		y: Float,
		sprite: BatchSprite,
		i: Int,
		disuse: Bool,
		disusedSprites: WVec<BatchSprite>,
		disusedCount: Int
	): Void {
		disuse = true;
		disusedSprites[disusedCount] = sprite;
		++disusedCount;
	}

	static function update(
		sprite: BatchSprite,
		x: WVec<Float>,
		y: WVec<Float>,
		vx: WVec<Float>,
		vy: WVec<Float>,
		fdCode: BytecodeData,
		fdCodeLength: UInt,
		fdCodePos: WVec<UInt>,
		fdStack: ByteStackData,
		fdStackSize: WVec<UInt>,
		frameCount: WVec<UInt>,
		i: Int,
		disuse: Bool,
		disusedSprites: WVec<BatchSprite>,
		disusedCount: Int,
		dead: WVec<Bool>,
		rotationVelocity: Float
	): Void {
		if (dead[i] || !HabitableZone.containsPoint(x[i], y[i])) {
			disuse = true;
			disusedSprites[disusedCount] = sprite;
			++disusedCount;
		} else {
			FdVm.run(fdCode, fdCodeLength, fdCodePos, fdStack, fdStackSize, x, y, vx, vy, i);
			x[i] += vx[i];
			y[i] += vy[i];
		}

		sprite.rotation += rotationVelocity;
		++frameCount[i];
	}

	static function mayFire(
		x: Float,
		y: Float,
		fire: FireCallback
	): Void {
		if (y < 240 && Random.bool(0.01)) {
			final playerPosition = Global.playerPosition;
			final dir = Math.atan2(playerPosition.y() - y, playerPosition.x() - x);
			fire(x, y, 4, dir);
		}
	}
}

@:build(banker.aosoa.Chunk.fromStructure(actor.Actor))
@:banker_verified
class ActorChunk {}
