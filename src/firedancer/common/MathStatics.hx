package firedancer.common;

/**
	Static constants and functions for numeric operation.
**/
class MathStatics {
	// TODO: optimize???

	public static extern inline final PI = 3.1415926535897932;
	public static extern inline final TWO_PI = 2.0 * PI;
	public static extern inline final HALF_PI = 0.5 * PI;
	public static extern inline final THIRD_PI = PI / 3.0;
	public static extern inline final ONE_OVER_TWO_PI = 1.0 / TWO_PI;
	public static extern inline final DEG_TO_RAD = TWO_PI / 360.0;
	public static extern inline final RAD_TO_DEG = 360.0 / TWO_PI;
	public static extern inline final EPSILON = 1.77635683940025e-015; // pow(2, 1-50)

	/**
		@return Trigonometric cosine of `radians`.
	**/
	public static extern inline function cos(radians: Float): Float
		return Math.cos(radians);

	/**
		@return Trigonometric sine of `radians`.
	**/
	public static extern inline function sin(radians: Float): Float
		return Math.sin(radians);

	/**
		@return Square root of the sum of squares of `x` and `y`.
	**/
	public static extern inline function hypot(x: Float, y: Float): Float
		return Math.sqrt((x * x) + (y * y));

	/**
		@return Trigonometric arc tangent in radians.
	**/
	public static extern inline function atan2(y: Float, x: Float): Float
		return Math.atan2(y, x);

	/**
		@return The floating-point remainder of `v / modulus`.
	**/
	public static extern inline function fmod(v: Float, modulus: Float): Float
		return v % modulus;

	/**
		@return Angle between `-PI` and `PI`.
	**/
	public static extern inline function normalizeAngle(angle: Float): Float
		return angle - TWO_PI * Math.floor((angle + PI) * ONE_OVER_TWO_PI);

	/**
		@return `true` if the absolute value of the difference of `a` and `b` is less than `EPSILON`.
	**/
	public static extern inline function nearlyEqual(a: Float, b: Float): Bool
		return Math.abs(a - b) < EPSILON;
}
