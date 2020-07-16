package firedancer.ast;

/**
	Sequential list of `Ast` instances.
**/
@:notNull @:forward
abstract AstList(Array<Ast>) from Array<Ast> from std.Array<Ast> {
	@:from public static extern inline function fromAst(instruction: Ast): AstList {
		return switch instruction {
			case List(instructions): instructions.copy();
			case instruction: [instruction];
		}
	}

	@:to public extern inline function toAst(): Ast
		return List(this);
}
