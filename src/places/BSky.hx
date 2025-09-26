package places;
import sys.io.File;
using StringTools;
using Tools;

class BSky {
	public static function get(ctx:FetchCtx, ?prev:String) {
		var html = CURL.getText(ctx.url, "html");
		if (html == null) {
			ctx.noPage = true;
			return;
		}
		
		var backupHost = "bskx.app";
		if (html.getMeta("twitter:card")[0] == "summary" && ctx.hostname != backupHost) {
			// If [twitter:card] is "summary", this means that either:
			// 1. The post requires authentication to view
			//    (could match [description]..? But what if they localize it later)
			// 2. The post contains a video, bsky doesn't do og:video right now
			// 3. The post legitimately doesn't contain any media
			// What's fun is that for "summary" posts og:image is the user's avatar,
			// which is probably not what you'd want to download.
			// Using bskx might help with two of these.
			
			Console.verbose('twitter:card is "summary", trying $backupHost instead...');
			ctx.hostname = backupHost;
			ctx.url = "https://" + backupHost + ctx.pathname;
			get(ctx, html);
			return;
		}
		
		var name = ctx.pathname;
		static var rxPath = ~/^\/profile\/(.+?)\/post\/(.+?)(\/|$)/;
		if (rxPath.match(name)) {
			var userID = rxPath.matched(1).sanitizeName();
			var postID = rxPath.matched(2).sanitizeName();
			name = ["bsky", userID, postID].join(Config.sep);
		} else {
			name = "bsky" + Tools.sanitizeName(ctx.pathname);
		}
		
		// store images first because 
		var images = [];
		var imageURLs = html.getMeta("og:image");
		for (imageURL in imageURLs) {
			imageURL = ~/\/img\/feed_thumbnail\//.replace(imageURL, "/img/feed_fullsize/");
			
			var imageExt:String;
			if (Config.lossless) {
				imageURL = ~/@jpeg$/.replace(imageURL, "@png");
				imageExt = "png";
			} else if (Config.useWEBP) {
				imageURL = ~/@jpeg$/.replace(imageURL, "@webp");
				imageExt = "webp";
			} else imageExt = "jpg";
			
			var imageRel = Config.prefix + name.appendIndex(images.length) + "." + imageExt;
			var imageFull = Config.outDir + "/" + imageRel;
			if (!CURL.downloadImage(imageURL, imageFull)) continue;
			
			images.push({
				rel: imageRel,
				full: imageFull,
				url: imageURL,
			});
		};
		
		// videos come first because they might remove a thumbnail image
		static var rxVideoID = ~/.+\/(.+)\/?$/;
		var videoCount = 0;
		var videoURLs = html.getMeta("og:video");
		for (videoURL in videoURLs) {
			var videoRel = Config.prefix + name.appendIndex(videoCount) + ".mp4";
			var videoFull = Config.outDir + "/" + videoRel;
			if (!CURL.download(videoURL, videoFull)) continue;
			videoCount += 1;
			
			var thumbRel:String = null;
			if (rxVideoID.match(videoURL)) {
				var videoID = rxVideoID.matched(1);
				var thumb = images.filter(q -> q.url.contains('/$videoID/thumbnail'))[0];
				if (thumb != null) {
					images.remove(thumb);
					thumbRel = thumb.rel;
				}
			}
			ctx.addVideo(videoRel, thumbRel, "");
		}
		
		for (image in images) {
			var thumbRel = Magick.createThumb(image.rel, image.full);
			ctx.addImage(image.rel, image.full, thumbRel, "");
		}
		
		// todo: parse those <p id> on the bottom to extract DID/handle
		
		#if 0
		if (imageURLs.length == 0 && videoURLs.length == 0 && ctx.hostname == backupHost) {
			if (prev != null) {
				Sys.println("Still no embeds!");
			} else {
				Sys.println("No embeds..?");
			}
			File.saveContent('tmp/$name.html', prev);
			File.saveContent('tmp/$name-bskx.html', html);
		}
		#end
	}
}