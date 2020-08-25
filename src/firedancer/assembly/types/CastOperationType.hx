package firedancer.assembly.types;

enum abstract CastOperationType(Int) {
	final IntToFloat;
	final CartesianToVec;
	final PolarToVec;
	public function getOutputType(): ValueType {
		return switch (cast this : CastOperationType) {
		case IntToFloat: Float;
		case CartesianToVec: Vec;
		case PolarToVec: Vec;
		}
	}
}
