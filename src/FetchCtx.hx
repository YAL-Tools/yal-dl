import sys.io.File;
#if js
import js.node.Buffer;
import js.node.ChildProcess;
#else
import sys.io.Process;
#end

class FetchCtx {
	//
	public var url:String;
	public var hostname:String;
	public var pathname:String;
	//
	public var isPixels = false;
	public var lines:Array<String> = [];
	//
	public var ready(get, never):Bool;
	inline function get_ready() {
		return lines.length != 0;
	}
	// errors
	public var badURL = false;
	public var noPage = false;
	public function getError() {
		if (badURL) {
			return '"$url" doesn\'t seem to be a valid URL.';
		} else if (noPage) {
			return 'Failed to fetch "$url".';
		} else {
			return 'Failed to find media in "$url".';
		}
	}
	//
	public function new(?url:String) {
		this.url = url;
	}
	//
	public var imageLines:Array<String> = [];
	public function addImage(url:String, alt:String = "") {
		var text = Config.markdown ? '[![$alt]($url)]($url)' : url;
		lines.push(text);
		imageLines.push(text);
	}
	//
	public var videoLines:Array<String> = [];
	public function addVideo(url:String, alt:String = "", ?thumb:String) {
		var text:String;
		if (Config.markdown) {
			if (thumb != null) {
				text = '[![$alt]($thumb)]($url)';
			} else text = '[video]($url)';
		} else text = url;
		lines.push(text);
		videoLines.push(text);
	}
	//
}