import haxe.io.Path;
using StringTools;

class Tools {
	public static function sanitizeName(url:String) {
		static var rxProtocol = ~/http[s]?:\/\/(.+)/;
		if (rxProtocol.match(url)) url = rxProtocol.matched(1);
		
		var qAt = url.indexOf("?");
		if (qAt >= 0) url = url.substring(0, qAt);
		
		var hAt = url.indexOf("#");
		if (hAt >= 0) url = url.substring(0, hAt);
		
		url = url.replace("/", Config.sep);
		url = ~/[\\\/:*?"<>|]/g.replace(url, "");
		return url;
	}
	
	public static function each(r:EReg, s:String, f:EReg->Void) {
		var i:Int = 0;
		while (r.matchSub(s, i)) {
			var p = r.matchedPos();
			f(r);
			i = p.pos + p.len;
		}
	}
	
	public static function removeFromStart(str:String, sub:String) {
		return str.startsWith(sub) ? str.substring(sub.length) : str;
	}
	
	public static function appendIndex(str:String, ind:Int) {
		return ind > 0 ? str + Config.sep + ind : str;
	}
	
	public static function appendExtensionOf(str:String, path:String, ?def:String) {
		var ext = urlExtension(path);
		if (ext != "") {
			return str + "." + ext;
		} else if (def != null) {
			return str + "." + def;
		} else return str;
	}
	
	public static function urlExtension(url:String) {
		var qAt = url.indexOf("?");
		if (qAt >= 0) url = url.substring(0, qAt);
		
		return Path.extension(url).toLowerCase();
	}
	
	public static function getMatches(rx:EReg, n:Int) {
		return [for (i in 1 ... n + 1) rx.matched(i)];
	}
	
	public static function getMeta(html:String, property:String) {
		static var rxMeta = ~/<meta([\s\S]+?)\/?>/g;
		static var rxProp = ~/\bproperty\s*=\s*"(.+?)"/;
		static var rxName = ~/\bname\s*=\s*"(.+?)"/;
		static var rxContent = ~/\bcontent\s*=\s*"([\s\S]+?)"/;
		
		var result = [];
		each(rxMeta, html, (rx) -> {
			var inner = rx.matched(1);
			
			if (rxProp.match(inner)) {
				if (rxProp.matched(1) != property) return;
			} else if (rxName.match(inner)) {
				if (rxName.matched(1) != property) return;
			} else return;
			
			if (!rxContent.match(inner)) return;
			var escText = rxContent.matched(1);
			var text = escText.htmlUnescape(); // .urlDecode() ?
			result.push(text);
		});
		return result;
	}
	
	public static function printSize(i:Int):String {
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
}