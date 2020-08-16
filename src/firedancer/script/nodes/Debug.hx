package firedancer.script.nodes;

import firedancer.assembly.Instruction;
import firedancer.types.DebugCode;

/**
	Runs debug process specified by `debugCode`.
**/
@:ripper_verified
class Debug extends AstNode implements ripper.Data {
	final debugCode: DebugCode;

	override public inline function containsWait(): Bool
		return false;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		return new Instruction(Opcode.general(Debug), [Int(debugCode)]);
	}
}