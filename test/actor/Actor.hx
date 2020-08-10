package actor;

@:banker_verified
class Actor extends broker.entity.BasicBatchEntity {
	/**
		Object for emitting new bullet.
	**/
	@:banker_chunkLevelFinal
	var bytecodeTable: Vector<Bytecode>;

	/**
		Object for emitting new bullet.
	**/
	@:banker_chunkLevelFinal
	var emitter: Emitter;

	/**
		Rotation velocity.
	**/
	@:banker_chunkLevelFinal
	var rotationVelocity: Float = 0.03;

	/**
		`firedancer` threads.
	**/
	@:banker_factory(() -> new ThreadList(THREAD_COUNT, STACK_CAPACITY))
	@:banker_swap
	var threads: ThreadList;

	/**
		Reference to the origin point.
		@see `firedancer.types.Emitter`
	**/
	var originPositionRef: Maybe<PositionRef> = Maybe.none();

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
	static function use(
		sprite: BatchSprite,
		x: WVec<Float>,
		y: WVec<Float>,
		vx: WVec<Float>,
		vy: WVec<Float>,
		threads: ThreadList,
		originPositionRef: WVec<Maybe<PositionRef>>,
		frameCount: WVec<UInt>,
		dead: WVec<Bool>,
		i: Int,
		usedSprites: WVec<BatchSprite>,
		usedCount: Int,
		initialX: Float,
		initialY: Float,
		initialVx: Float,
		initialVy: Float,
		code: Maybe<Bytecode>,
		originPosition: Maybe<PositionRef>
	): Void {
		x[i] = initialX;
		y[i] = initialY;
		vx[i] = initialVx;
		vy[i] = initialVy;

		if (code.isSome()) threads.set(code.unwrap());
		else threads.reset();

		originPositionRef[i] = originPosition;

		frameCount[i] = UInt.zero;
		dead[i] = false;
		usedSprites[usedCount] = sprite;
		++usedCount;
	}

	@:banker_useEntity
	static function emit(
		sprite: BatchSprite,
		x: WVec<Float>,
		y: WVec<Float>,
		vx: WVec<Float>,
		vy: WVec<Float>,
		threads: ThreadList,
		originPositionRef: WVec<Maybe<PositionRef>>,
		frameCount: WVec<UInt>,
		dead: WVec<Bool>,
		i: Int,
		usedSprites: WVec<BatchSprite>,
		usedCount: Int,
		initialX: Float,
		initialY: Float,
		speed: Float,
		direction: Float,
		code: Maybe<Bytecode>,
		originPosition: Maybe<PositionRef>
	): Void {
		x[i] = initialX;
		y[i] = initialY;
		final velocity = Geometry.toVec(speed, direction);
		vx[i] = velocity.x;
		vy[i] = velocity.y;

		if (code.isSome()) threads.set(code.unwrap());
		else threads.reset();

		originPositionRef[i] = originPosition;

		frameCount[i] = UInt.zero;
		dead[i] = false;
		usedSprites[usedCount] = sprite;
		++usedCount;
	}

	/**
		Disuses all entities currently in use.
	**/
	static function crashAll(
		sprite: BatchSprite,
		disuse: Bool,
		disusedSprites: WVec<BatchSprite>,
		disusedCount: Int
	): Void {
		disuse = true;
		disusedSprites[disusedCount] = sprite;
		++disusedCount;

		PositionRef.invalidate(sprite);
	}

	static function update(
		bytecodeTable: Vector<Bytecode>,
		sprite: BatchSprite,
		x: WVec<Float>,
		y: WVec<Float>,
		vx: WVec<Float>,
		vy: WVec<Float>,
		threads: ThreadList,
		originPositionRef: WVec<Maybe<PositionRef>>,
		frameCount: WVec<UInt>,
		i: Int,
		disuse: Bool,
		disusedSprites: WVec<BatchSprite>,
		disusedCount: Int,
		dead: WVec<Bool>,
		rotationVelocity: Float,
		emitter: Emitter,
		targetPositionRef: PositionRef
	): Void {
		if (dead[i] || !HabitableZone.containsPoint(x[i], y[i])) {
			disuse = true;
			disusedSprites[disusedCount] = sprite;
			++disusedCount;
			PositionRef.invalidate(sprite);
		} else {
			final endCode = Vm.run(
				bytecodeTable,
				threads,
				x,
				y,
				vx,
				vy,
				originPositionRef,
				i,
				emitter,
				sprite,
				targetPositionRef
			);

			x[i] += vx[i];
			y[i] += vy[i];

			switch endCode {
				case VANISH: dead[i] = true;
				default:
			}
		}

		sprite.rotation += rotationVelocity;
		++frameCount[i];
	}
}

@:build(banker.aosoa.Chunk.fromStructure(actor.Actor))
@:banker_verified
class ActorChunk {}
