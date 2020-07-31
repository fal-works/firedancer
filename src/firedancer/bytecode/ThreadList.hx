package firedancer.bytecode;

import banker.vector.Vector;
import firedancer.types.NInt;

/**
	Vector of `Thread` instances.
	The first element is for the main thread, and the subsequent are for sub-threads.
**/
@:notNull @:forward
abstract ThreadList(Vector<Thread>) {
	static function fullError()
		return "Found no available thread.";

	/**
		The main thread.
	**/
	public var main(get, never): Thread;

	/**
		@param poolCapacity The number of `Thread` instances including the main thread.
		@param stackCapacity The stack capacity in bytes for each thread.
	**/
	public extern inline function new(poolCapacity: NInt, stackCapacity: UInt)
		this = Vector.createPopulated(
			poolCapacity,
			() -> new Thread(stackCapacity)
		);

	@:op([]) public extern inline function get(index: UInt): Thread
		return this[index];

	/**
		Sets bytecode for the main thread and resets all sub-threads.
	**/
	public extern inline function set(code: Bytecode): Void {
		main.set(code, 0.0, 0.0, 0.0, 0.0);
		resetSubThreads();
	}

	/**
		Finds the first available sub-thread and activates it with given bytecode.

		Throws error if no available sub-thread is found.
		@param currentThread The `Thread` from which the shot position/velocity should be copied.
		@return The ID of the `Thread` that has been activated.
	**/
	public function useSubThread(code: Bytecode, currentThread: Thread): UInt {
		var index = MaybeUInt.none;
		var i = UInt.one;
		final len = this.length;
		do {
			final thread = this[i];
			if (!thread.active) {
				thread.set(
					code,
					currentThread.shotX,
					currentThread.shotY,
					currentThread.shotVx,
					currentThread.shotVy
				);
				index = i;
				break;
			}
			++i;
		} while (i < len);

		#if debug
		if (index.isNone()) throw fullError();
		#end

		return index.unwrap();
	}

	/**
		Resets all threads.
	**/
	public extern inline function reset(): Void {
		final len = this.length;
		var i = UInt.zero;
		while (i < len) {
			this[i].reset();
			++i;
		}
	}

	/**
		Resets all sub-threads.
	**/
	public extern inline function resetSubThreads(): Void {
		final len = this.length;
		var i = UInt.one;
		while (i < len) {
			this[i].reset();
			++i;
		}
	}

	extern inline function get_main()
		return this[UInt.zero];
}
