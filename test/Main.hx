import broker.scene.SceneStack;
import broker.color.ArgbColor;

class Main extends broker.App {
	static function main() {
		new Main(Global.width, Global.height, false);
	}

	var sceneStack: SceneStack;

	override function initialize(): Void {
		Global.initialize();

		final initialScene = new scenes.PlayScene();
		initialScene.fadeInFrom(ArgbColor.WHITE, 30, true);
		sceneStack = new SceneStack(initialScene, 16).newTag("scene stack");
	}

	override function update() {
		Global.update();

		sceneStack.update();
	}
}
