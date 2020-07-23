import broker.App;
import broker.object.Object;
import broker.image.Tile;
import broker.draw.DrawArea;
import broker.draw.TileDraw;
import broker.draw.BatchDraw;
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
		area.add(armies);

		final filter = new h2d.filter.Glow(0xFFFFFF, 1.0, 50, 0.5, 0.5, true);
		armies.setFilter(filter);

		army = WorldBuilder.createArmy(armies);

		// first agent
		army.newAgent(
			0.5 * worldWidth,
			-32,
			3,
			0.5 * Math.PI,
			BulletPatterns.typeA
		);
	}

	public function update(): Void {
		army.update();

		// if (Math.random() < 0.03) newAgent();

		army.synchronize();
	}

	public function dispose(): Void {
	}

	function newAgent(): Void {
		army.newAgent(
			(0.1 + 0.8 * Math.random()) * worldWidth,
			-32,
			1 + Math.random() * 1,
			0.5 * Math.PI,
			BulletPatterns.typeA
		);
	}
}

/**
	Functions internally used in `World.new()`.
**/
@:access(World)
private class WorldBuilder {
	public static function createArmy(parent: Object) {
		final agentTile = Tile.fromRgb(0xf0f0f0, 48, 48).toCentered();
		final agentBatch = new BatchDraw(agentTile.getTexture(), App.width, App.height);
		parent.addChild(agentBatch);

		final bulletTile = Tile.fromRgb(0xf0f0f0, 16, 16).toCentered();
		final bulletBatch = new BatchDraw(bulletTile.getTexture(), App.width, App.height);
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

		return new Army(agents, bullets);
	}
}

class HabitableZone {
	static extern inline final margin: Float = 64;
	public static extern inline final leftX: Float = 0 - margin;
	public static extern inline final topY: Float = 0 - margin;
	public static extern inline final rightX: Float = World.worldWidth + margin;
	public static extern inline final bottomY: Float = World.worldHeight + margin;

	public static extern inline function containsPoint(x: Float, y: Float): Bool
		return y < bottomY && topY <= y && leftX <= x && x < rightX;
}
