import haxe.io.Path;
import js.node.ChildProcess;
import Config.sep;

class Magick {
	static function run(args:Array<String>) {
		return ChildProcess.spawnSync("magick", args);
	}
	public static function createThumb(imageRel:String, imageFull:String) {
		var thumbSize = Config.thumbSize;
		if (thumbSize == null) return null;
		var ext = Config.useWEBP ? "webp" : "jpg";
		var suffix = sep + 'th.$ext';
		var thumbFull = Path.withoutExtension(imageFull) + suffix;
		var thumbRel = Path.withoutExtension(imageRel) + suffix;
		var proc = run([
			imageFull,
			"-resize", thumbSize + ">",
			thumbFull
		]);
		if (proc.error != null) {
			Console.verbose("Failed to run Magick: " + proc.error);
			return null;
		}
		return thumbRel;
	}
}