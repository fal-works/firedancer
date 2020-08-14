package firedancer.bytecode;

import banker.vector.Vector;

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
		@param memoryCapacity The memory capacity in bytes for each thread.
	**/
	public extern inline function new(poolCapacity: UInt, memoryCapacity: UInt) {
		if (poolCapacity.isZero()) throw "Thread pool capacity must be 1 or more.";

		this = Vector.createPopulated(
			poolCapacity,
			() -> new Thread(memoryCapacity)
		);
	}

	@:op([]) public extern inline function get(index: UInt): Thread
		return this[index];

	/**
		Sets program for the main thread and resets all sub-threads.
	**/
	public extern inline function set(program: Program): Void {
		main.set(program, 0.0, 0.0, 0.0, 0.0);
		resetSubThreads();
	}

	/**
		Finds the first available sub-thread and activates it with given program.

		Throws error if no available sub-thread is found.
		@param currentThread The `Thread` from which the shot position/velocity should be copied.
		@return The ID of the `Thread` that has been activated.
	**/
	public function useSubThread(program: Program, currentThread: Thread): UInt {
		var index = MaybeUInt.none;
		var i = UInt.one;
		final len = this.length;
		do {
			final thread = this[i];
			if (!thread.active) {
				thread.set(
					program,
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

	/**
		Deactivates all threads.
	**/
	public extern inline function deactivateAll(): Void {
		final len = this.length;
		var i = UInt.zero;
		while (i < len) {
			this[i].deactivate();
			++i;
		}
	}

	/**
		Deactivates all sub-threads.
	**/
	public extern inline function deactivateSubThreads(): Void {
		final len = this.length;
		var i = UInt.one;
		while (i < len) {
			this[i].deactivate();
			++i;
		}
	}

	extern inline function get_main()
		return this[UInt.zero];
}
