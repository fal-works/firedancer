import firedancer.Main.*;
import firedancer.bytecode.Bytecode;

class BulletPatterns {
	public static final none = Bytecode.createEmpty();

	public static final typeA = compile(loop([
		wait(30),
		velocity.set(4, 6),
		wait(30),
		velocity.set(-4, 6)
	]).count(2));
}
