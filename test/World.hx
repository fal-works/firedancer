import broker.App;
import broker.object.Object;
import broker.image.Tile;
import broker.draw.DrawArea;
import broker.draw.TileDraw;
import broker.draw.BatchDraw;
import broker.geometry.Point;
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

		army = WorldBuilder.createArmy(
			armies,
			Global.playerPosition,
			worldWidth,
			worldHeight
		);

		// first agent
		army.newAgent(0, -32, 3, Math.PI, BulletPatterns.testPattern);
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
		targetPosition: Point,
		areaWidth: UInt,
		areaHeight: UInt
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
			bulletBatch,
			bulletTile
		);

		final agents = ArmyBuilder.createActors(
			World.maxAgentCount,
			agentBatch,
			agentTile,
			bullets
		);

		return new Army(agents, bullets, targetPosition);
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
