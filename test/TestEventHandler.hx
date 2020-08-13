import firedancer.types.EventHandler;

class TestEventHandler extends EventHandler {
	public function new() {}

	override public function onGlobalEvent(eventCode: Int): Void {
		Sys.println('Invoked global event. (code: $eventCode)');
	}
}
