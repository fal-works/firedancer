import firedancer.Main.*;
import firedancer.bytecode.Bytecode;

class BulletPatterns {
	public static final none = Bytecode.createEmpty();

	public static final typeA = compile([
		wait(60),
		velocity.set(4, 6),
		wait(60),
		velocity.set(-4, 6)
	]);
}
