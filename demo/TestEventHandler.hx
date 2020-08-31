import firedancer.vm.EventHandler;
import sneaker.print.Printer;

class TestEventHandler extends EventHandler {
	public function new() {}

	override public function onGlobalEvent(eventCode: Int): Void {
		Printer.println('Invoked global event. (code: $eventCode)');
	}
}
