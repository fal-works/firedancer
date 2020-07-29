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
		var eachFrameNodeCount = UInt.zero;

		for (i in 0...nodes.length) {
			final node = nodes[i];

			switch node.type {
				case EachFrame(astToBeInjected):
					context.pushInjectionCode(astToBeInjected.toAssembly(context));
					++eachFrameNodeCount;
				default:
			}

			codeList.push(node.toAssembly(context));
		}

		for (_ in 0...eachFrameNodeCount) context.popInjectionCode();

		return codeList.flatten();
	}
}
