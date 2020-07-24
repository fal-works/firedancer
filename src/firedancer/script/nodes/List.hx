package firedancer.script.nodes;

/**
	List of `AstNode` to be run sequentially.
**/
@:ripper_verified
class List implements ripper.Data implements AstNode {
	public final nodes: Array<AstNode>;

	public inline function containsWait(): Bool {
		final nodes = this.nodes;
		var found = false;
		for (i in 0...nodes.length) if (nodes[i].containsWait()) {
			found = true;
			break;
		}
		return found;
	}

	public function toAssembly(): AssemblyCode
		return nodes.map(node -> node.toAssembly()).flatten();
}
