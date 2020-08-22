package firedancer.assembly;

class Optimizer {
	public static function optimize(code: AssemblyCode): AssemblyCode {
		#if !firedancer_no_optimization
		var cnt = 0;

		while (true) {
			final optimized = tryOptimize(code);
			if (optimized.isSome()) code = optimized.unwrap();
			else break;

			if (1024 < ++cnt) throw "Detected infinite loop in the optimization process.";
		}
		#end

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
				inline function findNextReader(
					startIndex: UInt,
					includeWriter: Bool
				): MaybeUInt {
					// TODO: refactor
					final nextWriter = code.indexOfFirstIn(
						inst -> inst.writesReg(loaded.getType()),
						startIndex,
						code.length
					);
					final nextReader = code.indexOfFirstIn(
						inst -> inst.readsReg(loaded.getType()),
						startIndex,
						code.length
					);

					return if (nextReader.isNone()) {
						MaybeUInt.none;
					} else if (nextWriter.isNone()) {
						nextReader;
					} else {
						if (includeWriter) {
							if (nextReader.unwrap() <= nextWriter.unwrap()) nextReader else MaybeUInt.none;
						} else {
							if (nextReader.unwrap() < nextWriter.unwrap()) nextReader else MaybeUInt.none;
						}
					}
				}
				var nextRegReaderIndex = findNextReader(i + 1, true);
				if (nextRegReaderIndex.isNone()) {
					// Sys.println("Found no succeeding reg reader.");
					// Sys.println("  Delete: " + code[i].toString());
					code.removeAt(i);
					optimized = true;
					continue;
				}

				// Sys.println("Found next reg reader.");
				nextRegReaderIndex = findNextReader(i + 1, false);
				while (nextRegReaderIndex.isSome()) {
					final index = nextRegReaderIndex.unwrap();
					final optimizedInst = code[index].tryFoldConstant(loaded);
					if (optimizedInst.isSome()) {
						// Sys.println("  Replace: " + code[index]);
						// Sys.println("  by: " + optimizedInst.unwrap());
						code[index] = optimizedInst.unwrap();
						optimized = true;
					}
					nextRegReaderIndex = findNextReader(index + 1, false);
				}

			default:
			}

			++i;
		}

		return optimized ? Maybe.from(code) : Maybe.none();
	}
}
