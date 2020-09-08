package firedancer.script.nodes;

import firedancer.assembly.Instruction;
import firedancer.script.expression.AngleExpression;
import firedancer.script.expression.FloatExpression;
import firedancer.script.expression.IntExpression;
import firedancer.script.expression.GenericExpression;

/**
	Declares a local variable.
**/
class DeclareLocalVariable extends AstNode {
	public static function fromInt(
		name: String,
		?initialValue: IntExpression
	): DeclareLocalVariable {
		if (initialValue == null) {
			initialValue = 0;
		}
		return new DeclareLocalVariable(name, initialValue);
	}

	public static function fromFloat(
		name: String,
		?initialValue: FloatExpression
	): DeclareLocalVariable {
		if (initialValue == null) {
			initialValue = 0.0;
		}
		return new DeclareLocalVariable(name, initialValue);
	}

	public static function fromAngle(
		name: String,
		?initialValue: AngleExpression
	): DeclareLocalVariable {
		if (initialValue == null) {
			initialValue = 0.0;
		}
		return new DeclareLocalVariable(name, initialValue);
	}

	final name: String;
	final initialValue: GenericExpression;

	public function new(name: String, initialValue: GenericExpression) {
		this.name = name;
		this.initialValue = initialValue;
	}

	override inline function containsWait(): Bool
		return false;

	override function toAssembly(context: CompileContext): AssemblyCode {
		final name = this.name;

		var storeRL: Instruction;
		var letVar: Instruction;

		switch initialValue.toEnum() {
		case IntExpr(_):
			letVar = Let(name, Int);
			storeRL = Store(Int(Reg), name);
			context.localVariables.push(name, Int);
		case FloatExpr(_) | AngleExpr(_):
			letVar = Let(name, Float);
			storeRL = Store(Float(Reg), name);
			context.localVariables.push(name, Float);
		case VecExpr(_):
			throw "Local variable of vector type is not supported.";
		}

		return {
			[
				[letVar],
				initialValue.load(context),
				[storeRL]
			].flatten();
		}
	}
}
