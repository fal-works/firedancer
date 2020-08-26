import firedancer.bytecode.ProgramPackage;
import broker.object.Object;
import broker.image.Tile;
import broker.draw.DrawArea;
import broker.draw.TileDraw;
import broker.draw.BatchDraw;
import reckoner.TmpVec2D;
import firedancer.types.Azimuth;
import firedancer.bytecode.PositionRef;
import actor.*;

class World {
	public static inline final worldWidth: UInt = Global.width;
	public static inline final worldHeight: UInt = Global.height;
	static inline final maxAgentCount: UInt = 256;
	static inline final maxBulletCount: UInt = 4096;

	/**
		The layer that contains all drawable objects in `this` world.
	**/
	public final area: DrawArea;

	final army: Army;

	public function new() {
		final area = this.area = new DrawArea(worldWidth, worldHeight);

		final backgroundTile = Tile.fromArgb(0xff101010, area.width, area.height);
		final background = new TileDraw(backgroundTile);
		area.add(background);

		final armies = new Object();
		armies.setPosition(worldWidth / 2, 0);
		area.add(armies);

		// armies.setFilter(new h2d.filter.Glow(0xFFFFFF, 1.0, 50, 0.5, 0.5, true));

		final targetPositionRef = PositionRef.createImmutable(0, 0.75 * worldHeight);

		final patterns = new BulletPatterns();

		army = WorldBuilder.createArmy(
			armies,
			targetPositionRef,
			worldWidth,
			worldHeight,
			patterns.programPackage
		);

		// first agent
		final position = new TmpVec2D(0, -32);
		final velocity = Azimuth.fromDegrees(180).toVec2D(3);
		army.newAgent(
			position.x,
			position.y,
			velocity.x,
			velocity.y,
			patterns.testPattern
		);
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
		final agentTile = Tile.fromRgb(0xf0f0f0, 48, 48).toCentered();
		final agentBatch = new BatchDraw(
			agentTile.getTexture(),
			areaWidth,
			areaHeight
		);
		parent.addChild(agentBatch);

		final bulletTile = Tile.fromRgb(0xf0f0f0, 16, 16).toCentered();
		final bulletBatch = new BatchDraw(
			bulletTile.getTexture(),
			areaWidth,
			areaHeight
		);
		parent.addChild(bulletBatch);

		final bullets = ArmyBuilder.createActors(
			World.maxBulletCount,
			programPackage,
			bulletBatch,
			bulletTile
		);

		final agents = ArmyBuilder.createActors(
			World.maxAgentCount,
			programPackage,
			agentBatch,
			agentTile,
			bullets
		);

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
