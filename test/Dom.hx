#if js
import js.Browser.document;
#end

class Dom {
	public static function initialize() {
		#if js
		final selector: js.html.SelectElement = cast document.getElementById("demo-selector");
		selector.onchange = () -> {
			if (Global.world.isNone()) return;

			final pkg = BulletPatterns.get(selector.value);
			if (pkg.isNone()) return;
			final programPackage = pkg.unwrap();

			Global.world.unwrap()
				.reset(
					programPackage,
					programPackage.getProgramByName("main")
				);
		};
		#end
	}

	public static function script(text: String) {
		#if js
		document.getElementById("script").textContent = text;
		#end
	}

	public static function assembly(text: String) {
		#if js
		document.getElementById("assembly").textContent = text;
		#end
	}

	public static function program(text: String) {
		#if js
		document.getElementById("program").textContent = text;
		#end
	}
}
