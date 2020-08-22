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

		code = code.copy();
		var optimized = false;

		var curIntImmInReg: Maybe<Operand> = Maybe.none();
		var curFloatImmInReg: Maybe<Operand> = Maybe.none();
		var curVecImmInReg: Maybe<Operand> = Maybe.none();

		var i = UInt.zero;
		while (i < code.length) {
			final curInst = code[i];

			final writeRegType = curInst.tryGetWriteRegType();
			if (writeRegType.isSome()) {
				switch writeRegType.unwrap() {
				case Int: curIntImmInReg = Maybe.none();
				case Float: curFloatImmInReg = Maybe.none();
				case Vec: curVecImmInReg = Maybe.none();
				}
			}

			inline function tryFoldConstant(maybeImm: Maybe<Operand>): Bool {
				return if (maybeImm.isSome()) {
					final optimizedInst = curInst.tryFoldConstant(maybeImm.unwrap());
					if (optimizedInst.isSome()) {
						code[i] = optimizedInst.unwrap();
						++i;
						optimized = true;
					} else false;
				} else false;
			}

			if (tryFoldConstant(curIntImmInReg)) continue;
			if (tryFoldConstant(curFloatImmInReg)) continue;
			if (tryFoldConstant(curVecImmInReg)) continue;

			switch curInst {
			case Load(loaded):
				final immType = loaded.tryGetImmType();
				if (immType.isSome()) {
					switch immType.unwrap() {
					case Int: curIntImmInReg = Maybe.from(loaded);
					case Float: curFloatImmInReg = Maybe.from(loaded);
					case Vec: curVecImmInReg = Maybe.from(loaded);
					}
				}

				inline function findNextReader(startIndex: UInt): MaybeUInt {
					final nextWriter = code.indexOfFirstIn(
						inst -> inst.tryGetWriteRegType() == loaded.getType(),
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
					} else if (nextWriter.isNone() || nextReader.unwrap() <= nextWriter.unwrap()) {
						nextReader;
					} else {
						MaybeUInt.none;
					}
				}
				var nextRegReaderIndex = findNextReader(i + 1);
				if (nextRegReaderIndex.isNone()) {
					code.removeAt(i);
					optimized = true;
					continue;
				}

			default:
			}

			++i;
		}

		return optimized ? Maybe.from(code) : Maybe.none();
	}
}
