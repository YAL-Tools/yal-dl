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
		
		ctx.postText = html.getMeta("description")[0];
		
		var imageAltTexts = html.getMeta("og:image:alt");
		var imageCount = 0;
		for (i => imageURL in html.getMeta("og:image")) {
			var imageExt = Config.imageExt ?? imageURL.urlExtension() ?? "jpg";
			var imageRel = Config.prefix + name.appendIndex(imageCount).appendExtension(imageExt);
			var imageFull = Config.outDir + "/" + imageRel;
			//
			if (CURL.downloadImage(imageURL, imageFull)) {
				var thumbRel = Magick.createThumb(imageRel, imageFull);
				ctx.addImage(imageRel, imageFull, thumbRel, imageAltTexts[i]);
				imageCount += 1;
			}
		}
		
		var videoCount = 0;
		for (videoURL in html.getMeta("og:video")) {
			var videoExt = videoURL.urlExtension() ?? "mp4";
			var videoRel = Config.prefix + name.appendIndex(videoCount).appendExtension(videoExt);
			var videoFull = Config.outDir + "/" + videoRel;
			//
			if (CURL.download(videoURL, videoFull)) {
				ctx.addVideo(videoURL, null, "");
				videoCount += 1;
			}
		}
	}
}