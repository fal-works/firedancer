package firedancer.script.api_components;

import firedancer.script.expression.FloatLikeExpressionData;

/**
	Provides features for operating actor's shot velocity.
**/
class ShotVelocity extends ActorPropertyApiComponent {
	/**
		Provides functions for operating shot velocity in cartesian coordinates.
	**/
	public final cartesian = new CartesianShotVelocity();

	public function new()
		super({ type: ShotVelocity, component: Vector });

	/**
		Sets shot velocity to a vector of `(speed, direction)`.
	**/
	public inline function set(speed: FloatExpression, direction: AngleExpression) {
		final vec: VecExpression = { length: speed, angle: direction };
		return new SetActorVector(ShotVelocity, vec);
	}

	/**
		Adds a vector of `(speed, direction)` to shot velocity.
	**/
	public inline function add(speed: FloatExpression, direction: AngleExpression) {
		final vec: VecExpression = { length: speed, angle: direction };
		return new AddActorProperty(ShotVelocity, AddVector(vec));
	}
}

/**
	Provides functions for operating actor's shot velocity in cartesian coordinates.
**/
class CartesianShotVelocity {
	public function new() {}

	/**
		Sets shot velocity to `(vx, vy)`.
	**/
	public inline function set(vx: FloatExpression, vy: FloatExpression) {
		final vec: VecExpression = { x: vx, y: vy };
		return new SetActorVector(ShotVelocity, vec);
	}

	/**
		Adds `(vx, vy)` to shot velocity.
	**/
	public inline function add(vx: FloatExpression, vy: FloatExpression) {
		final vec: VecExpression = { x: vx, y: vy };
		return new AddActorProperty(ShotVelocity, AddVector(vec));
	}
}

/**
	Provides functions for operating the length of actor's shot velocity vector.
**/
@:notNull @:forward
abstract ShotSpeed(ShotSpeedImpl) {
	public inline function new()
		this = new ShotSpeedImpl();

	@:access(firedancer.script.api_components.ActorPropertyApiComponent)
	@:to function toExpression(): FloatExpression {
		return
			FloatLikeExpressionEnum.Runtime(RuntimeExpressionEnum.Variable(Get(this.property)));
	}

	@:op(-A)
	inline function minus(): FloatExpression
		return -toExpression();

	@:commutative @:op(A + B)
	static inline function addExpr(a: ShotSpeed, b: FloatExpression): FloatExpression
		return a.toExpression() + b;

	@:op(A - B)
	static inline function subtractExpr(a: ShotSpeed, b: FloatExpression): FloatExpression
		return a.toExpression() - b;

	@:commutative @:op(A * B)
	static inline function multiplyExpr(a: ShotSpeed, b: FloatExpression): FloatExpression
		return a.toExpression() * b;

	@:op(A / B)
	static inline function divideExpr(a: ShotSpeed, b: FloatExpression): FloatExpression
		return a.toExpression() / b;

	@:op(A % B)
	static inline function moduloExpr(a: ShotSpeed, b: FloatExpression): FloatExpression
		return a.toExpression() % b;
}

private class ShotSpeedImpl extends ActorPropertyApiComponent {
	public function new()
		super({ type: ShotVelocity, component: Length });

	/**
		Sets the length of shot velocity vector to `value`.
	**/
	public inline function set(value: FloatExpression) {
		return new SetActorProperty(ShotVelocity, SetLength(value));
	}

	/**
		Adds `value` to the length of shot velocity vector.
	**/
	public inline function add(value: FloatExpression) {
		return new AddActorProperty(ShotVelocity, AddLength(value));
	}
}

/**
	Provides functions for operating the angle of actor's shot velocity vector.
**/
@:notNull @:forward
abstract ShotDirection(ShotDirectionImpl) {
	public inline function new()
		this = new ShotDirectionImpl();

	@:access(firedancer.script.api_components.ActorPropertyApiComponent)
	@:to function toExpression(): AngleExpression {
		return
			FloatLikeExpressionEnum.Runtime(RuntimeExpressionEnum.Variable(Get(this.property)));
	}

	@:op(-A)
	inline function minus(): AngleExpression
		return -toExpression();

	@:commutative @:op(A + B)
	static inline function addExpr(a: ShotDirection, b: AngleExpression): AngleExpression
		return a.toExpression() + b;

	@:op(A - B)
	static inline function subtractExpr(
		a: ShotDirection,
		b: AngleExpression
	): AngleExpression
		return a.toExpression() - b;

	@:commutative @:op(A * B)
	static inline function multiplyExpr(
		a: ShotDirection,
		b: FloatExpression
	): AngleExpression
		return a.toExpression() * b;

	@:op(A / B)
	static inline function divideExpr(
		a: ShotDirection,
		b: FloatExpression
	): AngleExpression
		return a.toExpression() / b;

	@:op(A % B)
	static inline function moduloExpr(
		a: ShotDirection,
		b: FloatExpression
	): AngleExpression
		return a.toExpression() % b;
}

private class ShotDirectionImpl extends ActorPropertyApiComponent {
	public function new()
		super({ type: ShotVelocity, component: Angle });

	/**
		Sets the angle of shot velocity vector to `value`.
	**/
	public inline function set(value: AngleExpression) {
		return new SetActorProperty(ShotVelocity, SetAngle(value));
	}

	/**
		Adds `value` to the angle of shot velocity vector.
	**/
	public inline function add(value: AngleExpression) {
		return new AddActorProperty(ShotVelocity, AddAngle(value));
	}
}
