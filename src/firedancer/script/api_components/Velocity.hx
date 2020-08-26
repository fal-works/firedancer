package firedancer.script.api_components;

import firedancer.script.expression.FloatLikeExpressionData;

/**
	Provides features for operating actor's velocity.
**/
class Velocity extends ActorPropertyApiComponent {
	/**
		Provides functions for operating velocity in cartesian coordinates.
	**/
	public final cartesian = new CartesianVelocity();

	public function new()
		super({ type: Velocity, component: Vector });

	/**
		Sets velocity to `(speed, direction)`.
	**/
	public inline function set(speed: FloatExpression, direction: AngleExpression) {
		final vec: VecExpression = { length: speed, angle: direction };
		return new SetActorVector(Velocity, vec);
	}

	/**
		Adds a vector of `(speed, direction)` to velocity.
	**/
	public inline function add(speed: FloatExpression, direction: AngleExpression) {
		final vec: VecExpression = { length: speed, angle: direction };
		return new AddActorProperty(Velocity, AddVector(vec));
	}
}

/**
	Provides functions for operating actor's velocity in cartesian coordinates.
**/
class CartesianVelocity {
	public function new() {}

	/**
		Sets velocity to `(vx, vy)`.
	**/
	public inline function set(vx: FloatExpression, vy: FloatExpression) {
		final vec: VecExpression = { x: vx, y: vy };
		return new SetActorVector(ShotVelocity, vec);
	}

	/**
		Adds `(vx, vy)` to velocity.
	**/
	public inline function add(vx: FloatExpression, vy: FloatExpression) {
		final vec: VecExpression = { x: vx, y: vy };
		return new AddActorProperty(ShotVelocity, AddVector(vec));
	}
}

/**
	Provides functions for operating the length of actor's velocity vector.
**/
@:notNull @:forward
abstract Speed(SpeedImpl) {
	public inline function new()
		this = new SpeedImpl();

	@:access(firedancer.script.api_components.ActorPropertyApiComponent)
	@:to function toExpression(): FloatExpression {
		return
			FloatLikeExpressionEnum.Runtime(RuntimeExpressionEnum.Variable(Get(this.property)));
	}

	@:op(-A)
	inline function minus(): FloatExpression
		return -toExpression();

	@:commutative @:op(A + B)
	static inline function addExpr(a: Speed, b: FloatExpression): FloatExpression
		return a.toExpression() + b;

	@:op(A - B)
	static inline function subtractExpr(a: Speed, b: FloatExpression): FloatExpression
		return a.toExpression() - b;

	@:commutative @:op(A * B)
	static inline function multiplyExpr(a: Speed, b: FloatExpression): FloatExpression
		return a.toExpression() * b;

	@:op(A / B)
	static inline function divideExpr(a: Speed, b: FloatExpression): FloatExpression
		return a.toExpression() / b;

	@:op(A % B)
	static inline function moduloExpr(a: Speed, b: FloatExpression): FloatExpression
		return a.toExpression() % b;
}

private class SpeedImpl extends ActorPropertyApiComponent {
	public function new()
		super({ type: Velocity, component: Length });

	/**
		Sets the length of velocity vector to `value`.
	**/
	public inline function set(value: FloatExpression) {
		return new SetActorProperty(Velocity, SetLength(value));
	}

	/**
		Adds `value` to the length of velocity vector.
	**/
	public inline function add(value: FloatExpression) {
		return new AddActorProperty(Velocity, AddLength(value));
	}
}

/**
	Provides functions for operating the angle of actor's velocity vector.
**/
@:notNull @:forward
abstract Direction(DirectionImpl) {
	public inline function new()
		this = new DirectionImpl();

	@:access(firedancer.script.api_components.ActorPropertyApiComponent)
	@:to function toExpression(): AngleExpression {
		return
			FloatLikeExpressionEnum.Runtime(RuntimeExpressionEnum.Variable(Get(this.property)));
	}

	@:op(-A)
	inline function minus(): AngleExpression
		return -toExpression();

	@:commutative @:op(A + B)
	static inline function addExpr(a: Direction, b: AngleExpression): AngleExpression
		return a.toExpression() + b;

	@:op(A - B)
	static inline function subtractExpr(a: Direction, b: AngleExpression): AngleExpression
		return a.toExpression() - b;

	@:commutative @:op(A * B)
	static inline function multiplyExpr(a: Direction, b: FloatExpression): AngleExpression
		return a.toExpression() * b;

	@:op(A / B)
	static inline function divideExpr(a: Direction, b: FloatExpression): AngleExpression
		return a.toExpression() / b;

	@:op(A % B)
	static inline function moduloExpr(a: Direction, b: FloatExpression): AngleExpression
		return a.toExpression() % b;
}

private class DirectionImpl extends ActorPropertyApiComponent {
	public function new()
		super({ type: Velocity, component: Angle });

	/**
		Sets the angle of velocity vector to `value`.
	**/
	public inline function set(value: AngleExpression) {
		return new SetActorProperty(Velocity, SetAngle(value));
	}

	/**
		Adds `value` to the angle of velocity vector.
	**/
	public inline function add(value: AngleExpression) {
		return new AddActorProperty(Velocity, AddAngle(value));
	}
}
