package firedancer.script.api_components;

import firedancer.script.expression.FloatLikeExpressionData;

/**
	Provides features for operating actor's shot position.
**/
class ShotPosition extends ActorPropertyApiComponent {
	/**
		Provides functions for operating shot position in cartesian coordinates.
	**/
	public final cartesian = new CartesianShotPosition();

	public function new()
		super({ type: ShotPosition, component: Vector });

	/**
		Sets shot position to a vector of `(distance, bearing)`.
	**/
	public inline function set(distance: FloatExpression, bearing: AngleExpression) {
		final vec: VecExpression = { length: distance, angle: bearing };
		return new SetActorVector(ShotPosition, vec);
	}

	/**
		Adds a vector of `(distance, bearing)` to shot position.
	**/
	public inline function add(distance: FloatExpression, bearing: AngleExpression) {
		final vec: VecExpression = { length: distance, angle: bearing };
		return new AddActorProperty(ShotPosition, AddVector(vec));
	}
}

/**
	Provides functions for operating actor's shot position in cartesian coordinates.
**/
class CartesianShotPosition {
	public function new() {}

	/**
		Sets shot position to `(x, y)`.
	**/
	public inline function set(x: FloatExpression, y: FloatExpression) {
		final vec: VecExpression = { x: x, y: y };
		return new SetActorVector(ShotPosition, vec);
	}

	/**
		Adds `(x, y)` to shot position.
	**/
	public inline function add(x: FloatExpression, y: FloatExpression) {
		final vec: VecExpression = { x: x, y: y };
		return new AddActorProperty(ShotPosition, AddVector(vec));
	}
}

/**
	Provides functions for operating the length of actor's shot position vector.
**/
@:notNull @:forward
abstract ShotDistance(ShotDistanceImpl) {
	public inline function new()
		this = new ShotDistanceImpl();

	@:access(firedancer.script.api_components.ActorPropertyApiComponent)
	@:to function toExpression(): FloatExpression {
		return
			FloatLikeExpressionEnum.Runtime(RuntimeExpressionEnum.Variable(Get(this.property)));
	}

	@:op(-A)
	inline function minus(): FloatExpression
		return -toExpression();

	@:commutative @:op(A + B)
	static inline function addExpr(a: ShotDistance, b: FloatExpression): FloatExpression
		return a.toExpression() + b;

	@:op(A - B)
	static inline function subtractExpr(
		a: ShotDistance,
		b: FloatExpression
	): FloatExpression
		return a.toExpression() - b;

	@:commutative @:op(A * B)
	static inline function multiplyExpr(
		a: ShotDistance,
		b: FloatExpression
	): FloatExpression
		return a.toExpression() * b;

	@:op(A / B)
	static inline function divideExpr(a: ShotDistance, b: FloatExpression): FloatExpression
		return a.toExpression() / b;

	@:op(A % B)
	static inline function moduloExpr(a: ShotDistance, b: FloatExpression): FloatExpression
		return a.toExpression() % b;
}

private class ShotDistanceImpl extends ActorPropertyApiComponent {
	public function new()
		super({ type: ShotPosition, component: Length });

	/**
		Sets the length of shot position vector to `value`.
	**/
	public inline function set(value: FloatExpression) {
		return new SetActorProperty(ShotPosition, SetLength(value));
	}

	/**
		Adds `value` to the length of shot position vector.
	**/
	public inline function add(value: FloatExpression) {
		return new AddActorProperty(ShotPosition, AddLength(value));
	}
}

/**
	Provides functions for operating the angle of actor's shot position vector.
**/
@:notNull @:forward
abstract ShotBearing(ShotBearingImpl) {
	public inline function new()
		this = new ShotBearingImpl();

	@:access(firedancer.script.api_components.ActorPropertyApiComponent)
	@:to function toExpression(): AngleExpression {
		return
			FloatLikeExpressionEnum.Runtime(RuntimeExpressionEnum.Variable(Get(this.property)));
	}

	@:op(-A)
	inline function minus(): AngleExpression
		return -toExpression();

	@:commutative @:op(A + B)
	static inline function addExpr(a: ShotBearing, b: AngleExpression): AngleExpression
		return a.toExpression() + b;

	@:op(A - B)
	static inline function subtractExpr(
		a: ShotBearing,
		b: AngleExpression
	): AngleExpression
		return a.toExpression() - b;

	@:commutative @:op(A * B)
	static inline function multiplyExpr(
		a: ShotBearing,
		b: FloatExpression
	): AngleExpression
		return a.toExpression() * b;

	@:op(A / B)
	static inline function divideExpr(a: ShotBearing, b: FloatExpression): AngleExpression
		return a.toExpression() / b;

	@:op(A % B)
	static inline function moduloExpr(a: ShotBearing, b: FloatExpression): AngleExpression
		return a.toExpression() % b;
}

private class ShotBearingImpl extends ActorPropertyApiComponent {
	public function new()
		super({ type: ShotPosition, component: Angle });

	/**
		Sets the angle of shot position vector to `value`.
	**/
	public inline function set(value: AngleExpression) {
		return new SetActorProperty(ShotPosition, SetAngle(value));
	}

	/**
		Adds `value` to the angle of shot position vector.
	**/
	public inline function add(value: AngleExpression) {
		return new AddActorProperty(ShotPosition, AddAngle(value));
	}
}
