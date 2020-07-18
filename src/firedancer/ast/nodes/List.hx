package firedancer.ast.nodes;

/**
	List of `AstNode` to be run sequentially.
**/
class List implements ripper.Data implements AstNode {
	public final nodes: Array<AstNode>;

	public function toAssembly(): AssemblyCode
		return nodes.map(node -> node.toAssembly()).flatten();
}
