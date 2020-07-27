package firedancer.common;

/**
	Static constants and functions for numeric operation.
**/
class MathStatics {
	// TODO: optimize???

	public static extern inline final PI = 3.1415926535897932384626433832795028841971693993751058209749445923078164062862089986280348;
	public static extern inline final TWO_PI = 2.0 * PI;
	public static extern inline final ONE_OVER_TWO_PI = 1.0 / TWO_PI;
	public static extern inline final DEG_TO_RAD = MathStatics.TWO_PI / 360.0;
	public static extern inline final RAD_TO_DEG = 360.0 / MathStatics.TWO_PI;

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
}
