package firedancer.script.nodes;

import firedancer.script.expression.AngleExpression;
import firedancer.script.expression.FloatExpression;
import firedancer.script.expression.IntExpression;
import firedancer.assembly.AssemblyStatement.create as statement;
import firedancer.assembly.ValueType;
import firedancer.assembly.operation.GeneralOperation;
import firedancer.script.expression.GenericExpression;

/**
	Declares a local variable.
**/
class DeclareLocalVariable extends AstNode {
	public static function fromInt(name: String, ?initialValue: IntExpression): DeclareLocalVariable {
		if (initialValue == null) {
			initialValue = 0;
		}
		return new DeclareLocalVariable(name, initialValue);
	}

	public static function fromFloat(name: String, ?initialValue: FloatExpression): DeclareLocalVariable {
		if (initialValue == null) {
			initialValue = 0.0;
		}
		return new DeclareLocalVariable(name, initialValue);
	}

	public static function fromAngle(name: String, ?initialValue: AngleExpression): DeclareLocalVariable {
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

	override public inline function containsWait(): Bool
		return false;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		var valueType: ValueType;
		var storeCL: GeneralOperation;
		var storeVL: GeneralOperation;

		switch initialValue.toEnum() {
			case IntExpr(_):
				valueType = Int;
				storeCL = StoreIntCL;
				storeVL = StoreIntVL;
			case FloatExpr(_) | AngleExpr(_):
				valueType = Float;
				storeCL = StoreFloatCL;
				storeVL = StoreFloatVL;
			case VecExpr(_):
				throw "Local variable of vector type is not supported.";
		}

		final address: Int = context.localVariables.push(this.name, valueType);
		final constValue = initialValue.tryGetConstantOperand();

		return if (constValue.isSome()) {
			final store = Opcode.general(storeCL);
			statement(store, [Int(address), constValue.unwrap()]);
		} else {
			final store = Opcode.general(storeVL);
			[
				initialValue.loadToVolatile(context),
				[statement(store, [Int(address)])]
			].flatten();
		}
	}
}
