package firedancer.script.api_components;

import firedancer.script.expression.FloatLikeExpressionData;

/**
	Provides features for operating actor's position.
**/
class Position extends ActorPropertyApiComponent {
	/**
		Provides functions for operating position in cartesian coordinates.
	**/
	public final cartesian = new CartesianPosition();

	public function new()
		super({ type: Position, component: Vector });

	/**
		Sets position to `(distance, bearing)`.
	**/
	public inline function set(distance: FloatExpression, bearing: AngleExpression) {
		final vec: VecExpression = { length: distance, angle: bearing };
		return new SetActorVector(Position, vec);
	}

	/**
		Adds a vector of `(distance, bearing)` to position.
	**/
	public inline function add(distance: FloatExpression, bearing: AngleExpression) {
		final vec: VecExpression = { length: distance, angle: bearing };
		return new AddActorProperty(Position, AddVector(vec));
	}
}

/**
	Provides functions for operating actor's position in cartesian coordinates.
**/
class CartesianPosition {
	public function new() {}

	/**
		Sets position to `(x, y)`.
	**/
	public inline function set(x: FloatExpression, y: FloatExpression) {
		final vec: VecExpression = { x: x, y: y };
		return new SetActorVector(Position, vec);
	}

	/**
		Adds `(x, y)` to position.
	**/
	public inline function add(x: FloatExpression, y: FloatExpression) {
		final vec: VecExpression = { x: x, y: y };
		return new AddActorProperty(Position, AddVector(vec));
	}
}

/**
	Provides functions for operating the length of actor's position vector.
**/
@:notNull @:forward
abstract Distance(DistanceImpl) {
	public inline function new()
		this = new DistanceImpl();

	@:access(firedancer.script.api_components.ActorPropertyApiComponent)
	@:to function toExpression(): FloatExpression {
		return
			FloatLikeExpressionEnum.Runtime(RuntimeExpressionEnum.Variable(Get(this.property)));
	}

	@:op(-A)
	inline function minus(): FloatExpression
		return -toExpression();

	@:commutative @:op(A + B)
	static inline function addExpr(a: Distance, b: FloatExpression): FloatExpression
		return a.toExpression() + b;

	@:op(A - B)
	static inline function subtractExpr(a: Distance, b: FloatExpression): FloatExpression
		return a.toExpression() - b;

	@:commutative @:op(A * B)
	static inline function multiplyExpr(a: Distance, b: FloatExpression): FloatExpression
		return a.toExpression() * b;

	@:op(A / B)
	static inline function divideExpr(a: Distance, b: FloatExpression): FloatExpression
		return a.toExpression() / b;

	@:op(A % B)
	static inline function moduloExpr(a: Distance, b: FloatExpression): FloatExpression
		return a.toExpression() % b;
}

private class DistanceImpl extends ActorPropertyApiComponent {
	public function new()
		super({ type: Position, component: Length });

	/**
		Sets the length of position vector to `value`.
	**/
	public inline function set(value: FloatExpression) {
		return new SetActorProperty(Position, SetLength(value));
	}

	/**
		Adds `value` to the length of position vector.
	**/
	public inline function add(value: FloatExpression) {
		return new AddActorProperty(Position, AddLength(value));
	}
}

/**
	Provides functions for operating the angle of actor's position vector.
**/
@:notNull @:forward
abstract Bearing(BearingImpl) {
	public inline function new()
		this = new BearingImpl();

	@:access(firedancer.script.api_components.ActorPropertyApiComponent)
	@:to function toExpression(): AngleExpression {
		return
			FloatLikeExpressionEnum.Runtime(RuntimeExpressionEnum.Variable(Get(this.property)));
	}

	@:op(-A)
	inline function minus(): AngleExpression
		return -toExpression();

	@:commutative @:op(A + B)
	static inline function addExpr(a: Bearing, b: AngleExpression): AngleExpression
		return a.toExpression() + b;

	@:op(A - B)
	static inline function subtractExpr(a: Bearing, b: AngleExpression): AngleExpression
		return a.toExpression() - b;

	@:commutative @:op(A * B)
	static inline function multiplyExpr(a: Bearing, b: FloatExpression): AngleExpression
		return a.toExpression() * b;

	@:op(A / B)
	static inline function divideExpr(a: Bearing, b: FloatExpression): AngleExpression
		return a.toExpression() / b;

	@:op(A % B)
	static inline function moduloExpr(a: Bearing, b: FloatExpression): AngleExpression
		return a.toExpression() % b;
}

private class BearingImpl extends ActorPropertyApiComponent {
	public function new()
		super({ type: Position, component: Angle });

	/**
		Sets the angle of position vector to `value`.
	**/
	public inline function set(value: AngleExpression) {
		return new SetActorProperty(Position, SetAngle(value));
	}

	/**
		Adds `value` to the angle of position vector.
	**/
	public inline function add(value: AngleExpression) {
		return new AddActorProperty(Position, AddAngle(value));
	}
}
