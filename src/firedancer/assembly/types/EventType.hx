package firedancer.assembly.types;

enum abstract EventType(Int) {
	final Global;
	final Local;
	public function toString(): String {
		return switch (cast this : EventType) {
		case Global: "global";
		case Local: "local";
		}
	}
}
