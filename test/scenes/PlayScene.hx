package scenes;

import broker.App;
import broker.scene.Scene;

class PlayScene extends Scene {
	var world: World;

	override function initialize(): Void {
		super.initialize();

		this.world = new World();
		final worldArea = this.world.area;
		worldArea.setCenterPosition(App.width / 2, App.height / 2);
		this.layers.main.add(worldArea);

		Global.world = Maybe.from(this.world);
	}

	override function update(): Void {
		super.update();
		this.world.update();

		if (false) {
			// TODO: user input
			this.newPlayScene();
			return;
		}
	}

	override function destroy(): Void {
		this.world.dispose();
		Global.world = Maybe.none();
	}

	function newPlayScene(): Void {
		if (this.isTransitioning) return;
		final nextScene = new PlayScene();
		this.switchTo(nextScene, UInt.zero, true, true);
	}
}
