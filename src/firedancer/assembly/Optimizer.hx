package firedancer.assembly;

class Optimizer {
	public static function optimize(code: AssemblyCode): AssemblyCode {
		var cnt = 0;

		while (true) {
			final optimized = tryOptimize(code);
			if (optimized.isSome()) code = optimized.unwrap();
			else break;

			if (1024 < ++cnt) throw "Detected infinite loop in the optimization process.";
		}

		return code;
	}

	public static function tryOptimize(code: AssemblyCode): Maybe<AssemblyCode> {
		if (code.length <= UInt.one) return Maybe.none();

		// Sys.println("Try optimization.");
		// Sys.println(code.toString());
		code = code.copy();

		var optimized = false;

		var i = UInt.zero;
		while (i < code.length) {
			final curInst = code[i];

			switch curInst {
			case Load(loaded):
				// Sys.println('[$i] ${curInst.toString()}');
				inline function findNextReader(startIndex: UInt): MaybeUInt {
					final nextWriter = code.indexOfFirstIn(
						inst -> inst.writesReg(loaded.getType()),
						startIndex,
						code.length
					);
					final nextReader = code.indexOfFirstIn(
						inst -> inst.readsReg(loaded.getType()),
						startIndex,
						if (nextWriter.isSome()) nextWriter.unwrap() + 1 else code.length
					);
					return nextReader;
				}
				var nextRegReaderIndex = findNextReader(i + 1);
				if (nextRegReaderIndex.isNone()) {
					// Sys.println("Found no succeeding reg reader.");
					// Sys.println("  Delete: " + code[i].toString());
					code.removeAt(i);
					optimized = true;
					continue;
				} else {
					// Sys.println("Found next reg reader.");
					do {
						final index = nextRegReaderIndex.unwrap();
						final optimizedInst = code[index].tryFoldConstant(loaded);
						if (optimizedInst.isSome()) {
							// Sys.println("  Replace: " + code[index]);
							// Sys.println("  by: " + optimizedInst.unwrap());
							code[index] = optimizedInst.unwrap();
							optimized = true;
						}
						nextRegReaderIndex = findNextReader(index + 1);
					} while (nextRegReaderIndex.isSome());
				}

			default:
			}

			++i;
		}

		return optimized ? Maybe.from(code) : Maybe.none();
	}
}
