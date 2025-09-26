import sys.FileSystem;
using haxe.extern.EitherType;
using js.node.Buffer;

class FileTools {
	@:noUsing public static function printSize(i:Int):String {
		if (i < 0) return "???";
		var n:Float = i;
		inline function print(u:String) {
			return Std.string(Math.round(n * 100) / 100) + " " + u;
		}
		if (n < 10_000) return print("B");
		n /= 1024;
		if (n < 10_000) return print("KB");
		n /= 1024;
		return print("MB");
	}
	
	public static function printSpawnBuffer(buf:EitherType<Buffer, String>):String {
		if (buf == null || buf is String) {
			return buf;
		} else {
			return (buf:Buffer).toString();
		}
	}
	
	@:noUsing public static function getSize(path:String):Int {
		try {
			return FileSystem.stat(path).size;
		} catch (x:Dynamic) {
			Console.verbose('Error getting size for "$path":' + x);
			return -1;
		}
	}
	
	@:noUsing public static function getAltPath(path:String) {
		
	}
}