import broker.object.Object;
import broker.image.Tile;
import broker.draw.DrawArea;
import broker.draw.TileDraw;
import broker.draw.BatchDraw;
import firedancer.vm.Program;
import firedancer.vm.ProgramPackage;
import firedancer.vm.PositionRef;
import actor.*;

class World {
	public static inline final worldWidth: UInt = Global.width;
	public static inline final worldHeight: UInt = Global.height;
	static inline final maxAgentCount: UInt = 64;
	static inline final maxBulletCount: UInt = 4096;

	/**
		The layer that contains all drawable objects in `this` world.
	**/
	public final area: DrawArea;

	final armiesContainer: Object;

	var army: Army;

	public function new() {
		final area = this.area = new DrawArea(worldWidth, worldHeight);

		final backgroundTile = Tile.fromArgb(0xfffefdff, area.width, area.height);
		final background = new TileDraw(backgroundTile);
		area.add(background);

		armiesContainer = new Object();
		armiesContainer.setPosition(worldWidth / 2, 0);
		area.add(armiesContainer);
		// armiesContainer.setFilter(new h2d.filter.Glow(0xFFFFFF, 1.0, 50, 0.5, 0.5, true));

		final programPackage = BulletPatterns.defaultPattern();
		this.reset(programPackage, programPackage.getProgramByName("main"));
	}

	public function reset(programPackage: ProgramPackage, mainProgram: Program): Void {
		this.armiesContainer.removeChildren();

		final targetPositionRef = PositionRef.createImmutable(0, 0.75 * worldHeight);
		army = WorldBuilder.createArmy(
			this.armiesContainer,
			targetPositionRef,
			worldWidth,
			worldHeight,
			programPackage
		);

		army.crashAll();

		final x = 0.0;
		final y = 200.0;
		army.newAgent(x, y, 0.0, 0.0, Maybe.from(mainProgram));
	}

	public function update(): Void {
		army.update();
		army.synchronize();
	}

	public function dispose(): Void {}
}

/**
	Functions internally used in `World.new()`.
**/
@:access(World)
private class WorldBuilder {
	public static function createArmy(
		parent: Object,
		targetPositionRef: PositionRef,
		areaWidth: UInt,
		areaHeight: UInt,
		programPackage: ProgramPackage
	) {
		final agentTile = Tile.fromImage(hxd.Res.agent).toCentered();
		final agentBatch = new BatchDraw(
			agentTile.getTexture(),
			areaWidth,
			areaHeight
		);
		parent.addChild(agentBatch);

		final bulletTile = Tile.fromImage(hxd.Res.bullet).toCentered();
		final bulletBatch = new BatchDraw(
			bulletTile.getTexture(),
			areaWidth,
			areaHeight
		);
		parent.addChild(bulletBatch);

		final eventHandler = new EventHandler();
		final emitter = new Emitter();

		final bullets = ArmyBuilder.createActors(
			World.maxBulletCount,
			programPackage,
			bulletBatch,
			bulletTile,
			eventHandler,
			emitter
		);

		final agents = ArmyBuilder.createActors(
			World.maxAgentCount,
			programPackage,
			agentBatch,
			agentTile,
			eventHandler,
			emitter
		);

		emitter.initialize(bullets);

		return new Army(agents, bullets, targetPositionRef);
	}
}

/**
	Bounds of the habitable zone of actors.
	Horizontally centered.
**/
class HabitableZone {
	static extern inline final margin: Float = 64;
	public static extern inline final leftX: Float = -World.worldWidth / 2 - margin;
	public static extern inline final topY: Float = 0 - margin;
	public static extern inline final rightX: Float = World.worldWidth / 2 + margin;
	public static extern inline final bottomY: Float = World.worldHeight + margin;

	public static extern inline function containsPoint(x: Float, y: Float): Bool
		return y < bottomY && topY <= y && leftX <= x && x < rightX;
}
