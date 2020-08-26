package firedancer.bytecode;

// @formatter:off
#if (firedancer_positionref_type == "broker_BatchSprite")
import broker.draw.BatchSprite;
typedef PositionRefData = BatchSprite;
#elseif (heaps && firedancer_positionref_type == "heaps_BatchElement")
import h2d.SpriteBatch.BatchElement;
typedef PositionRefData = BatchElement;
#else
typedef PositionRefData = { x: Float, y: Float };
#end
// @formatter:on
//

/**
	Reference object that provides read-only access to the position of an actor.

	The underlying type can be switched by the compiler flag `firedancer_positionref_type`.
**/
abstract PositionRef(PositionRefData) from PositionRefData {
	/**
		The minimum finite `Float` value.

		Used for marking a `PositionRef` value as invalid by assigning this value to the `x` component.
		@see `invalidate()`
	**/
	public static extern inline final MIN_FLOAT: Float = -3.402823e+38;

	/**
		Marks a `PositionRef` as invalid so that the referrer object can detect and
		unlink automatically in the next frame.

		As `PositionRef` is read-only, you have to pass the underlying object to this method.
	**/
	public static extern inline function invalidate(data: PositionRefData): Void
		data.x = MIN_FLOAT;

	/**
		Creates a `PositionRef` instance with fixed `(x, y)` coordinates.
	**/
	public static extern inline function createImmutable(x: Float, y: Float): PositionRef {
		#if (firedancer_positionref_type == "broker_BatchSprite")
		final sprite = new BatchSprite(cast null);
		sprite.x = x;
		sprite.y = y;
		return sprite;
		#elseif (firedancer_positionref_type == "heaps_BatchElement")
		final sprite = new BatchElement(cast null);
		sprite.x = x;
		sprite.y = y;
		return sprite;
		#else
		return { x: x, y: y };
		#end
	}

	/**
		Creates a `PositionRef` instance with fixed `(0, 0)` coordinates.
	**/
	public static extern inline function createZero(): PositionRef
		return createImmutable(0.0, 0.0);

	public var x(get, never): Float;
	public var y(get, never): Float;

	/**
		`true` if `this` reference is marked as invalid and should no more be used.
		@see `invalidate()`
	**/
	public extern inline function isInvalid(): Bool
		return this.x == MIN_FLOAT;

	/**
		`true` if `this` reference is not marked as invalid.
		@see `invalidate()`
	**/
	public extern inline function isValid(): Bool
		return this.x != MIN_FLOAT;

	extern inline function get_x()
		return this.x;

	extern inline function get_y()
		return this.y;
}
