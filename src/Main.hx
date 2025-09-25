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
			case "x.com", "vxtwitter.com", "fxtwitter.com", "fixupx.com":
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
			var del = switch (args[argi]) {
				case "--in": inPath = args[argi + 1]; 2;
				case "--out": outPath = args[argi + 1]; 2;
				case "--prefix": Config.prefix = args[argi + 1]; 2;
				case "--dir": Config.outDir = args[argi + 1]; 2;
				case "--md", "--markdown": Config.markdown = true; 1;
				case "--plain": Config.markdown = false; 1;
				case "--cache": Config.cache = true; 1;
				case "--png", "--lossless": Config.lossless = true; 1;
				case "--webp": Config.useWEBP = true; 1;
				case "--verbose": Config.verbose = true; 1;
				case "--thumb": Config.thumbSize = args[argi + 1]; 2;
				default: 0;
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
					if (header != null) {
						if (Config.markdown) {
							addLine('## [$header]($url)');
						} else {
							addLine(header);
							addLine(url);
						}
						header = null;
					} else addNote(url);
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
		//
		var outText = outLines.join("\r\n");
		if (outPath != null) {
			File.saveContent(outPath, outText);
			Sys.println("OK!");
		} else {
			Sys.println(outText);
		}
	}
}
