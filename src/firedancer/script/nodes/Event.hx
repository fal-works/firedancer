package firedancer.script.nodes;

import firedancer.script.expression.IntExpression;
import firedancer.assembly.Instruction;
import firedancer.assembly.types.EventType;

/**
	Invokes any global/local event.
**/
@:ripper_verified
class Event extends AstNode implements ripper.Data {
	final eventType: EventType;
	final eventCode: IntExpression;

	override inline function containsWait(): Bool
		return false;

	override function toAssembly(context: CompileContext): AssemblyCode {
		final instruction: Instruction = Event(eventType);

		final code = eventCode.loadToVolatile(context);
		code.push(instruction);
		return code;
	}
}
