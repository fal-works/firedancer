package firedancer.script.nodes;

import firedancer.script.expression.GenericExpression;

@:structInit
class OperateLocalVariable extends AstNode {
	final name: String;
	final operation: LocalVariableOperation;
	final value: Maybe<GenericExpression>;

	public function new(
		name: String,
		operation: LocalVariableOperation,
		?value: GenericExpression
	) {
		switch operation {
		case Set | Add: if (value == null) throw "Missing value to set/add.";
		default:
		}

		this.name = name;
		this.operation = operation;
		this.value = Maybe.from(value);
	}

	override public function containsWait(): Bool
		return false;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final variable = context.localVariables.get(this.name);

		return switch this.operation {
		case Set: variable.setValue(this.value.unwrap());
		case Add: variable.addValue(this.value.unwrap());
		case Increment: variable.increment();
		case Decrement: variable.decrement();
		}
	}
}

private enum abstract LocalVariableOperation(Int) {
	final Set;
	final Add;
	final Increment;
	final Decrement;
}
