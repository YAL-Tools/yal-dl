import haxe.io.Path;
import sys.FileSystem;
import js.node.ChildProcess;
import sys.io.File;
using Tools;

class CURL {
	static function spawnCURL(args:Array<String>) {
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
		var stat = try {
			FileSystem.stat(outPath);
		} catch (x:Dynamic) {
			null;
		}
		if (stat != null) {
			Console.verbose('OK! (${stat.size.printSize()})');
		} else {
			Console.verbose("OK! (???)");
		}
		return File.getContent(outPath);
	}
	public static function download(url:String, out:String) {
		Console.verbose('Downloading "$url"');
		if (FileSystem.exists(out)) {
			Console.verbose('"$out" already exists!');
			return true;
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
		var stat = try {
			FileSystem.stat(out);
		} catch (x:Dynamic) {
			null;
		}
		if (stat != null) {
			Console.verbose('OK! (${stat.size.printSize()})');
		} else {
			Console.verbose("OK! (???)");
		}
		return true;
	}
}