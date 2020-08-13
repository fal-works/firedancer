package firedancer.script.nodes;

import firedancer.script.expression.IntExpression;
import firedancer.assembly.AssemblyStatement;

/**
	Invokes any global/local event.
**/
@:ripper_verified
class Event extends AstNode implements ripper.Data {
	final category: EventCategory;
	final eventCode: IntExpression;

	override public inline function containsWait(): Bool
		return false;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final eventOpcode = Opcode.general(switch category {
			case Global: GlobalEvent;
			case Local: LocalEvent;
		});

		final code = eventCode.loadToVolatile(context);
		code.pushStatement(eventOpcode);
		return code;
	}
}

enum abstract EventCategory(Int) {
	final Global;
	final Local;
}
