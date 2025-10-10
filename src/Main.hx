package;

import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import places.*;
using StringTools;
using Tools;

class Main {
	public static var rxURL = ~/http[s]?:\/\/(.+?)($|(?:\/.*))/;
	public static function procURL(url:String) {
		var ctx = new FetchCtx(url);
		//if (Config.verbose) Console.info('Fetching "$url"...');
		
		if (!rxURL.match(url)) {
			ctx.badURL = true;
			return ctx;
		}
		ctx.hostname = rxURL.matched(1).removeFromStart("www.");
		ctx.pathname = rxURL.matched(2);
		
		switch (ctx.hostname) {
			case "bsky.app", "fxbsky.app", "bskyx.app", "bskx.app":
				BSky.get(ctx);
			case "x.com", "twitter.com", "vxtwitter.com", "fxtwitter.com", "fixupx.com":
				Twitter.get(ctx);
			default:
				Generic.get(ctx);
		}
		return ctx;
	}
	public static function main() {
		//
		var args = Sys.args();
		if (args.contains("--run-tests")) {
			Test.run();
			return;
		}
		if (args.contains("--help") || args.contains("/?")) {
			Sys.println("YAL's social media downloader");
			Sys.println("CLI docs coming soon!");
			return;
		}
		//
		var argi = 0;
		var inPath:String = null;
		var outPath:String = null;
		while (argi < args.length) {
			inline function str(ofs = 0) {
				return args[argi + (1 + ofs)];
			}
			inline function int(def = 0, ofs = 0) {
				return Std.parseInt(args[argi + (1 + ofs)]) ?? def;
			}
			var argName = args[argi];
			var del = switch (argName) {
				// input/output
				case "--in": {
					inPath = str();
					2;
				}
				case "--out": {
					outPath = str();
					if (Path.extension(outPath).toLowerCase() == "md") Config.markdown = true;
					2;
				}
				case "--prefix": Config.prefix = str(); 2;
				case "--dir": Config.outDir = str(); 2;
				// markdown
				case "--md", "--markdown": Config.markdown = true; 1;
				case "--plain": Config.markdown = false; 1;
				case "--md-img-links", "--md-image-links": {
					Config.mdImageLinks = true; 1;
				}
				case "--md-img-dims", "--md-img-dimensions",
					"--md-image-dims", "--md-image-dimensions": {
					Config.mdImageDims = true; 1;
				}
				case "--thumb": Config.thumbSize = str(); 2;
				// network
				case "--user-agent": Config.userAgent = str(); 2;
				case "--delay": Config.delay = int(0); 2;
				// image 
				case "--webp": Config.useWEBP = true; 1;
				case "--png", "--lossless": Config.lossless = true; 1;
				case "--quality": {
					var qs = str();
					if (qs.endsWith("%")) qs = qs.substr(0, qs.length - 1);
					var q = Std.parseInt(qs);
					if (q != null) {
						Config.quality = q;
					} else {
						Sys.println('"${str()}" is not a valid quality');
					}
					2;
				};
				case "--max-size": {
					var snip = str().toLowerCase();
					static var rxSize = ~/^([\d,.]+)\s*([km]?b?)?$/;
					if (rxSize.match(snip)) {
						var numStr = rxSize.matched(1).replace(",", ".");
						var num = Std.parseFloat(numStr);
						if (!Math.isNaN(num)) {
							var unit = rxSize.matched(2);
							var mult = 1024;
							if (unit == "mb" || unit == "m") {
								mult = 1024 * 1024;
							} else if (unit == "b") {
								mult = 1;
							}
							Config.maxSize = Math.round(mult * num);
						} else Sys.println('"$numStr" is not a valid number for --max-size!');
					} else Sys.println("Expected #KB/#MB for --max-size!");
					2;
				};
				case "--max-width": Config.maxWidth = int(); 2;
				case "--max-height": Config.maxWidth = int(); 2;
				case "--max-dims", "--max-dimensions": {
					static var rxDims = ~/^(\d+)x(\d+)$/;
					if (rxDims.match(str())) {
						Config.maxWidth = Std.parseInt(rxDims.matched(1)) ?? 0;
						Config.maxHeight = Std.parseInt(rxDims.matched(2)) ?? 0;
					} else {
						Sys.println("Expected WxH for --max-dims!");
					}
					2;
				};
				case "--image-ext": {
					Config.imageExt = str();
					if (Config.imageExt == ".") Config.imageExt = "";
					2;
				};
				// debug
				case "--cache": Config.cache = true; 1;
				case "--verbose": Config.verbose = true; 1;
				//
				default: {
					if (argName.startsWith("--")) {
						Sys.println('$argName is not a known argument.');
					}
					0;
				};
			}
			if (del > 0) {
				args.splice(argi, del);
			} else argi += 1;
		}
		Config.ready();
		//
		var markdown = Config.markdown;
		var outLines = [];
		inline function addLine(text:String) {
			outLines.push(text);
		}
		inline function addNote(text:String) {
			if (markdown) {
				addLine('<!-- $text -->');
			} else addLine(text);
		}
		//
		if (inPath != null) {
			var text = File.getContent(inPath);
			text = text.replace("\r", "");
			var lines = text.split("\n");
			var header:String = null;
			for (line in lines) {
				line = line.trim();
				if (rxURL.match(line)) {
					var url = line;
					if (header != null && header != "") {
						if (markdown) {
							addLine('## [$header]($url)');
						} else {
							addLine(header);
							//addLine(url);
						}
						header = null;
					} else {
						if (markdown) addNote(url);
					}
					//
					var ctx = procURL(url);
					if (ctx.ready) {
						for (line in ctx.lines) addLine(line);
					} else addNote(ctx.getError());
				} else { // title
					if (header != null) {
						addLine(header);
					}
					header = line;
				}
			}
		}
		for (url in args) {
			var ctx = procURL(url);
			if (ctx.ready) {
				if (outLines.length > 0) addLine("");
				for (line in ctx.lines) addLine(line);
			} else addNote(ctx.getError());
		}
		if (args.length == 0 && inPath == null) {
			Sys.println("No inputs!");
		}
		//
		var outText = outLines.join("\r\n");
		if (outPath != null) {
			File.saveContent(outPath, outText);
			Sys.println("OK!");
		} else if (outLines.length > 0) {
			Sys.println(outText);
		}
	}
}
