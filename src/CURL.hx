import haxe.io.Path;
import sys.FileSystem;
import js.node.ChildProcess;
import sys.io.File;
using Tools;

class CURL {
	static function spawnCURL(args:Array<String>) {
		static var first = true;
		if (first) {
			first = false;
		} else if (Config.delay > 0) {
			Sys.sleep(Config.delay / 1000);
		}
		if (Config.userAgent != null) {
			args = args.concat(["--user-agent", Config.userAgent]);
		}
		return ChildProcess.spawnSync("curl", args);
	}
	
	public static function getText(url:String, type:String):String {
		var tmp = "tmp/out.html";
		Console.verbose('Fetching "$url"...');
		
		var cachePath = (Config.cache
			? Path.join([Config.cacheDir, Tools.sanitizeName(url) + "." + type])
			: null
		);
		if (cachePath != null) {
			if (FileSystem.exists(cachePath)) {
				Console.verbose("Cached!");
				return File.getContent(cachePath);
			}
		}
		
		var outPath = cachePath ?? tmp;
		var curl = spawnCURL([
			"--location", url,
			"--output", outPath,
		]);
		if (curl.error != null) {
			Console.verbose('Error! ' + curl.error);
			return null;
		}
		if (!FileSystem.exists(outPath)) {
			Console.verbose("No file!");
			return null;
		}
		var size = FileTools.getSize(outPath);
		Console.verbose('OK! (${FileTools.printSize(size)})');
		return File.getContent(outPath);
	}
	
	public static function download(url:String, out:String) {
		Console.verbose('Downloading "$url"');
		var cachePath = (Config.cache
			? Path.join([Config.cacheDir, Tools.sanitizeName(url)])
			: null
		);
		if (cachePath != null) {
			if (FileSystem.exists(cachePath)) {
				Console.verbose("Cached!");
				File.copy(cachePath, out);
				return true;
			}
		}
		
		Console.verbose('-> "$out"... ');
		var curl = spawnCURL([
			"--location", url,
			"--output", out,
		]);
		if (curl.error != null) {
			Console.verbose('Error! ' + curl.error);
			return false;
		}
		if (!FileSystem.exists(out)) {
			Console.verbose('No file!');
			return false;
		}
		//
		if (cachePath != null) File.copy(out, cachePath);
		//
		var size = FileTools.getSize(out);
		Console.verbose('OK! (${FileTools.printSize(size)})');
		return true;
	}
	
	public static inline function downloadImage(url:String, out:String) {
		return download(url, out);
	}
}