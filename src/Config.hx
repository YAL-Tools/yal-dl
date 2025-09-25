import sys.FileSystem;
import haxe.io.Path;

class Config {
	public static var verbose = false;
	public static var cache = false;
	public static var cacheDir:String;
	public static var tempDir:String;
	public static var outDir = ".";
	public static var prefix = "";
	public static var markdown = false;
	public static var magick = false;
	public static var lossless = false;
	public static var useWEBP = false;
	public static var userAgent:String = null;
	public static var thumbSize:String = null;
	public static var sep = "=";
	//
	public static function ready() {
		var programDir = Path.directory(Sys.programPath());
		
		tempDir = Path.join([programDir, "tmp"]);
		if (!FileSystem.exists(tempDir)) FileSystem.createDirectory(tempDir);
		
		cacheDir = Path.join([programDir, "cache"]);
		if (cache && !FileSystem.exists(cacheDir)) FileSystem.createDirectory(cacheDir);
	}
}