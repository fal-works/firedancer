import sneaker.print.Printer;

class EventHandler extends firedancer.vm.EventHandler {
	public function new() {}

	override public function onGlobalEvent(eventCode: Int): Void {
		Printer.println('Invoked global event. (code: $eventCode)');
	}
}
