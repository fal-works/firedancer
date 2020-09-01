package firedancer.script.nodes;

/**
	Ends running the bullet pattern with a specific end code
	so that the end code is returned from the VM.
**/
@:ripper_verified
class End extends AstNode implements ripper.Data {
	final endCode: Int;

	override inline function containsWait(): Bool
		return false;

	override function toAssembly(context: CompileContext): AssemblyCode
		return [End(endCode)];
}
