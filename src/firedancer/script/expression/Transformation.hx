package firedancer.script.expression;

/**
	2D coordinates transformation matrix.

	```
	a c e
	b d f
	0 0 1
	```
**/
@:structInit
class Transformation {
	/**
		Multiplies two transformation matrices.
	**/
	public static function multiply(
		mat1: Transformation,
		mat2: Transformation
	): Transformation {
		return {
			a: mat1.a * mat2.a + mat1.c * mat2.b,
			b: mat1.b * mat2.a + mat1.d * mat2.b,
			c: mat1.a * mat2.c + mat1.c * mat2.d,
			d: mat1.b * mat2.c + mat1.d * mat2.d,
			e: mat1.a * mat2.e + mat1.c * mat2.f + mat1.e,
			f: mat1.b * mat2.e + mat1.d * mat2.f + mat1.f
		}
	}

	/**
		Applies a transformation matrix to a 2D vector.
	**/
	public static function apply(
		mat: Transformation,
		vec: { x: FloatExpression, y: FloatExpression }
	) {
		final x = vec.x;
		final y = vec.y;
		final newX = mat.a * x + mat.c * y + mat.e;
		final newY = mat.b * x + mat.d * y + mat.f;
		return { x: newX, y: newY };
	}

	/**
		Creates a translation matrix.
	**/
	public static function createTranslate(
		x: FloatExpression,
		y: FloatExpression
	): Transformation {
		return {
			a: 1.0,
			b: 0.0,
			c: 0.0,
			d: 1.0,
			e: x,
			f: y
		}
	}

	/**
		Creates a rotation matrix.
	**/
	public static function createRotate(angle: AngleExpression): Transformation {
		return {
			a: angle.cos(),
			b: angle.sin(),
			c: angle.sin().unaryMinus(),
			d: angle.cos(),
			e: 0.0,
			f: 0.0
		}
	}

	/**
		Creates a scaling matrix.
		@param y If not provided, this will be the same as `x`.
	**/
	public static function createScale(
		x: FloatExpression,
		?y: FloatExpression
	): Transformation {
		if (y == null) y = x;

		return {
			a: x,
			b: 0.0,
			c: 0.0,
			d: y,
			e: 0.0,
			f: 0.0
		}
	}

	public final a: FloatExpression;
	public final b: FloatExpression;
	public final c: FloatExpression;
	public final d: FloatExpression;
	public final e: FloatExpression;
	public final f: FloatExpression;

	/**
		Adds a translation after `this` transformation and returns a composite matrix.
	**/
	public function translate(x: FloatExpression, y: FloatExpression): Transformation
		return multiply(this, createTranslate(x, y));

	/**
		Adds a rotation after `this` transformation and returns a composite matrix.
	**/
	public function rotate(angle: AngleExpression): Transformation
		return multiply(this, createRotate(angle));

	/**
		Adds a scaling after `this` transformation and returns a composite matrix.
	**/
	public function scale(x: FloatExpression, ?y: FloatExpression): Transformation
		return multiply(this, createScale(x, y));
}
