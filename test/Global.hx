import broker.geometry.Point;

class Global {
	public static inline final width: UInt = 720;
	public static inline final height: UInt = 960;

	public static final playerPosition = new Point(0.5 * width, 0.8 * height);

	public static function initialize(): Void {}

	public static function update(): Void {}
}
