package places;
import haxe.io.Path;
using Tools;
using StringTools;

class Generic {
	public static function get(ctx:FetchCtx) {
		var html = CURL.getText(ctx.url, "html");
		if (html == null) {
			ctx.noPage = true;
			return;
		}
		
		var name:String;
		switch (ctx.hostname) {
			case "www.youtube.com", "youtube.com": {
				static var rxYT = ~/\bv=([\w-]+)/;
				if (rxYT.match(ctx.pathname)) {
					name = "youtube-" + rxYT.matched(1);
				} else name = "youtube-" + ctx.pathname.sanitizeName();
			}
			default: name = ctx.url.sanitizeName();
		}
		
		var imageAltTexts = html.getMeta("og:image:alt");
		var imageCount = 0;
		for (i => imageURL in html.getMeta("og:image")) {
			var imageRel = Config.prefix + name.appendIndex(imageCount).appendExtensionOf(imageURL, "jpg");
			var imageFull = Config.outDir + "/" + imageRel;
			//
			if (CURL.download(imageURL, imageFull)) {
				ctx.addImage(imageRel, imageAltTexts[i]);
				imageCount += 1;
			}
		}
		
		var videoCount = 0;
		for (videoURL in html.getMeta("og:video")) {
			var videoRel = Config.prefix + name.appendIndex(videoCount).appendExtensionOf(videoURL, "mp4");
			var videoFull = Config.outDir + "/" + videoRel;
			//
			if (CURL.download(videoURL, videoFull)) {
				ctx.addVideo(videoURL);
				videoCount += 1;
			}
		}
	}
}