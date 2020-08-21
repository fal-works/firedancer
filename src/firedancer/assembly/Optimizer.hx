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
		if (code.length <= UInt.one) return code;

		final newCode: AssemblyCode = [];
		var optimized = false;

		final lastIndex = code.length - 1;
		var i = UInt.zero;
		while (i <= lastIndex) {
			final cur = code[i];

			if (i == lastIndex) {
				newCode.push(cur);
				break;
			}

			final next = code[i + 1];

			switch cur {
			case Load(loaded):
				switch next {
					case Add(nextOperands):
						final newNextOperands = nextOperands.tryReplaceRegWithImm(loaded);
						if (newNextOperands.isSome()) {
							newCode.push(Add(newNextOperands.unwrap()));
							optimized = true;
							i += 2;
							continue;
						}
					case Sub(nextOperands):
						final newNextOperands = nextOperands.tryReplaceRegWithImm(loaded);
						if (newNextOperands.isSome()) {
							newCode.push(Add(newNextOperands.unwrap()));
							optimized = true;
							i += 2;
							continue;
						}
					default:
				}
			default:
			}

			newCode.push(cur);
			++i;
		}

		return optimized ? Maybe.from(newCode) : Maybe.none();
	}
}
