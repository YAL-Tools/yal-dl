import sys.FileSystem;
import haxe.io.Path;
using StringTools;

class Config {
	public static var verbose = false;
	public static var cache = false;
	public static var cacheDir:String;
	public static var tempDir:String;
	public static var outDir = ".";
	public static var prefix = "";
	//
	public static var markdown = false;
	public static var mdImageLinks = false;
	public static var mdImageDims = false;
	//
	public static var imageExt:String = null;
	public static var lossless = false;
	public static var useWEBP = false;
	public static var quality = 80;
	//
	public static var userAgent:String = null;
	public static var thumbSize:String = null;
	//
	public static var maxWidth = 0;
	public static var maxHeight = 0;
	public static var maxSize = 0;
	//
	public static var delay = 0;
	public static var sep = "=";
	//
	public static function ready() {
		var programDir = Path.directory(Sys.programPath());
		
		tempDir = Path.join([programDir, "tmp"]);
		if (!FileSystem.exists(tempDir)) FileSystem.createDirectory(tempDir);
		
		cacheDir = Path.join([programDir, "cache"]);
		if (cache && !FileSystem.exists(cacheDir)) FileSystem.createDirectory(cacheDir);
		
		if (prefix.endsWith("/") || prefix.endsWith("\\")) {
			var prefixDir = outDir + "/" + prefix.substring(0, prefix.length - 1);
			if (!FileSystem.exists(prefixDir)) FileSystem.createDirectory(prefixDir);
		}
	}
}