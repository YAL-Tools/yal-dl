import Magick;
import haxe.io.Path;
import sys.FileSystem;
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
	public function addImage(imageRel:String, imageFull:String, thumbRel:String, alt:String) {
		var maxSize = Config.maxSize;
		var maxWidth = Config.maxWidth, maxHeight = Config.maxHeight;
		if (maxSize > 0 || maxWidth > 0 || maxHeight > 0) do {
			// file size too big?
			var wantResize = false;
			if (Config.maxSize > 0) {
				var size = FileTools.getSize(imageFull);
				trace(imageFull, size/1024, maxSize/1024);
				wantResize = size > maxSize;
			}
			// dimensions too big?
			if (!wantResize && (Config.maxWidth > 0 || Config.maxHeight > 0)) {
				var dims = Magick.getDims(imageFull);
				if (dims == null) {
					// maybe not then!
				} else if (maxWidth > 0 && dims.width > maxWidth) {
					wantResize = true;
				} else if (maxHeight > 0 && dims.height > maxHeight) {
					wantResize = true;
				}
			}
			
			// good enough!
			if (!wantResize) break;
			
			// if there's no size requirement, we just do a one-off conversion, possibly to the same file.
			var currExt = Path.extension(imageFull).toLowerCase();
			var newExt = Config.useWEBP ? "webp" : "jpg";
			var sameExt = currExt == newExt;
			var useTemp = sameExt && maxSize > 0;
			var tempFull = useTemp ? Config.tempDir + '/temp.$newExt' : Path.withExtension(imageFull, newExt);
			var args = [imageFull,
				"-quality", Std.string(Config.quality),
			];
			var note = 'Converting "$imageRel" to ${newExt.toUpperCase()}';
			if (maxWidth > 0 || maxHeight > 0) {
				var size = "x";
				if (maxWidth > 0) size = maxWidth + size;
				if (maxHeight > 0) size = size + maxHeight;
				note += ', $size';
				args = args.concat([
					"-resize", size + ">"
				]);
			}
			Console.verbose(note);
			Magick.run(args.concat([tempFull]));
			
			// if there are size requirements, we might need to try again
			if (maxSize > 0) {
				var scaleStep = 0.75;
				var scale = 100.0;
				for (attempt in 0 ... 7) {
					scale *= scaleStep;
					var size = FileTools.getSize(tempFull);
					if (size <= maxSize) break;
					var sizeStr = Math.round(scale * 100) / 100 + "%";
					Console.verbose('Too big (${FileTools.printSize(size)}), trying $sizeStr scale');
					Magick.run([
						imageFull,
						"-resize", sizeStr,
						"-quality", Std.string(Config.quality),
						tempFull,
					]);
				}
			}
			
			if (!sameExt) {
				FileSystem.deleteFile(imageFull);
				imageRel = Path.withExtension(imageRel, newExt);
				imageFull = Path.withExtension(imageFull, newExt);
			}
			if (useTemp) {
				File.copy(tempFull, imageFull);
			}
		} while (false);
		var text = Config.markdown ? '[![$alt]($thumbRel)]($imageRel)' : imageRel;
		lines.push(text);
		imageLines.push(text);
	}
	//
	public var videoLines:Array<String> = [];
	public function addVideo(videoRel:String, thumbRel:String, alt:String) {
		var text:String;
		if (Config.markdown) {
			if (thumbRel != null) {
				text = '[![$alt]($thumbRel)]($videoRel)';
			} else text = '[video]($videoRel)';
		} else text = videoRel;
		lines.push(text);
		videoLines.push(text);
	}
	//
}