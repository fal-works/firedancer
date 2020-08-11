package firedancer.script.nodes;

import firedancer.script.expression.GenericExpression;

@:structInit
class OperateLocalVariable extends AstNode {
	final name: String;
	final value: GenericExpression;
	final operation: LocalVariableOperation;

	override public function containsWait(): Bool
		return false;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final variable = context.localVariables.get(this.name);

		return switch this.operation {
			case Set: variable.setValue(this.value);
			case Add: variable.addValue(this.value);
		}
	}
}

private enum abstract LocalVariableOperation(Int) {
	final Set;
	final Add;
}
