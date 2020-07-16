class Run {
	static function main() {
		#if sys
		final libraryName: String = "firedancer";
		final version = haxe.macro.Compiler.getDefine("firedancer");

		final url = 'https://lib.haxe.org/p/${libraryName}/';

		Sys.println('\n${libraryName} ${version}\n${url}\n');
		#end
	}
}
