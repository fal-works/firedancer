package firedancer.bytecode;

import banker.binary.value_types.WordSize;

/**
	Common constants.
**/
class Constants {
	/**
		Size (in bytes) of an integer value embedded in any `Program`.
	**/
	public static extern inline final IntSize = WordSize.Bit32.bytes();

	/**
		Size (in bytes) of a float value embedded in any `Program`.
	**/
	public static extern inline final FloatSize = WordSize.Bit64.bytes();

	/**
		Size (in bytes) of a vector value embedded in any `Program`.
	**/
	public static extern inline final VecSize = FloatSize + FloatSize;
}
