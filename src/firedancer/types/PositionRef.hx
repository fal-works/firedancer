package firedancer.types;

// @formatter:off
#if (firedancer_positionref_type == "broker_BatchSprite")
import broker.draw.BatchSprite;
private typedef Data = BatchSprite;
#elseif (heaps && firedancer_positionref_type == "heaps_BatchElement")
import h2d.SpriteBatch.BatchElement;
private typedef Data = BatchElement;
#else
private typedef Data = { x: Float, y: Float };
#end
// @formatter:on
//

/**
	Reference object that provides read-only access to the position of an actor.
**/
abstract PositionRef(Data) from Data {
	/**
		Creates a `PositionRef` instance with fixed `(x, y)` coordinates.
	**/
	public static extern inline function create(x: Float, y: Float): PositionRef {
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
		return create(0.0, 0.0);

	public var x(get, never): Float;
	public var y(get, never): Float;

	extern inline function get_x()
		return this.x;

	extern inline function get_y()
		return this.y;
}
