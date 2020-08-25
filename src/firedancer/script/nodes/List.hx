package firedancer.script.nodes;

/**
	List of `AstNode` to be run sequentially.
**/
@:ripper_verified
class List extends AstNode implements ripper.Data {
	public final nodes: Array<AstNode>;

	override public function containsWait(): Bool {
		final nodes = this.nodes;
		var found = false;
		for (i in 0...nodes.length) if (nodes[i].containsWait()) {
			found = true;
			break;
		}
		return found;
	}

	override public function toAssembly(context: CompileContext): AssemblyCode {
		final codeList: Array<AssemblyCode> = [];
		final nodes = this.nodes;
		var everyFrameNodeCount = UInt.zero;

		context.localVariables.startScope();

		for (i in 0...nodes.length) {
			final node = nodes[i];

			switch node.nodeType {
			case EachFrame(astToBeInjected):
				context.pushInjectionCode(astToBeInjected.toAssembly(context));
				++everyFrameNodeCount;
			default:
			}

			codeList.push(node.toAssembly(context));
		}

		context.localVariables.endScope();

		for (_ in 0...everyFrameNodeCount) context.popInjectionCode();

		return codeList.flatten();
	}
}
