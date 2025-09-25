@:forwardStatics
abstract Console(js.html.Console) {
	public static inline function verbose(text) {
		if (Config.verbose) Console.info(text);
	}
}