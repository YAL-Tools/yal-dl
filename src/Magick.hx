import haxe.io.Path;
import js.node.ChildProcess;
import Config.sep;
using Tools;
using FileTools;

class Magick {
	public static function run(args:Array<String>) {
		var proc = ChildProcess.spawnSync("magick", args);
		if (proc.error != null) {
			Console.verbose("Failed to run Magick: " + proc.error);
		}
		return proc;
	}
	public static function createThumb(imageRel:String, imageFull:String) {
		var thumbSize = Config.thumbSize;
		if (thumbSize == null) return null;
		Console.verbose('Generating a thumbnail for "$imageRel"');
		
		var ext = Config.useWEBP ? "webp" : "jpg";
		var suffix = sep + 'th.$ext';
		var thumbFull = Path.withoutExtension(imageFull) + suffix;
		var thumbRel = Path.withoutExtension(imageRel) + suffix;
		var proc = run([
			imageFull,
			"-resize", thumbSize + ">",
			"-quality", Std.string(Config.quality),
			thumbFull
		]);
		if (proc.error != null) return null;
		return thumbRel;
	}
	public static function getDims(imageFull:String):MagickDims {
		var proc = run([
			imageFull,
			"-format", "dims:%w:%h",
			"info:",
		]);
		if (proc.error != null) return null;
		
		var text = proc.stdout.printSpawnBuffer();
		static var rxDims = ~/\bdims:(\d+):(\d+)/;
		if (rxDims.match(text)) {
			return {
				width: Std.parseInt(rxDims.matched(1)),
				height: Std.parseInt(rxDims.matched(2)),
			};
		} else {
			Console.verbose('Couldn\'t match magick output: "$text"');
			return null;
		}
	}
}
typedef MagickDims = {width:Int, height:Int};