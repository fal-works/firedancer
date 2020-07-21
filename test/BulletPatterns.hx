import firedancer.Main.*;
import firedancer.bytecode.Bytecode;

class BulletPatterns {
	public static final none = Bytecode.createEmpty();

	public static final typeA = compile(loop([
		wait(30),
		velocity.set(5, 150),
		wait(30),
		velocity.set(5, 210)
	]).count(2));
}
