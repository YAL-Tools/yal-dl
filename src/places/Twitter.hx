package places;

import haxe.io.Path;
import haxe.DynamicAccess;
import haxe.Json;
using Tools;

class Twitter {
	public static function get(ctx:FetchCtx) {
		var vxURL = "https://api.vxtwitter.com" + ctx.pathname;
		
		var text = CURL.getText(vxURL, "json");
		if (text == null) {
			Sys.println("No response!");
			return;
		}
		
		var tweet:VxTwitterTweet = try {
			Json.parse(text);
		} catch (x:Dynamic) {
			Sys.println("JSON parse error! " + x);
			return;
		}
		
		ctx.postText = tweet.text;
		
		var name = ["twitter", tweet.user_screen_name, tweet.tweetID].join(Config.sep);
		
		// support "/photo/#" since you can copy a link to n-th attachment
		static var rxMediaID = ~/\/status\/\d+\/photo\/(\d+)/;
		var media = tweet.media_extended;
		if (rxMediaID.match(ctx.pathname)) {
			var ind = Std.parseInt(rxMediaID.matched(1));
			if (ind < 1 || ind > media.length) {
				Sys.println('Specified /photo/ is $ind but tweet only has ${media.length} attachments.');
				return;
			}
			media = [media[ind - 1]];
		}
		
		for (itemInd => item in media) {
			var url = item.url;
			var qAt = url.indexOf("?");
			if (qAt >= 0) url = url.substring(0, qAt);
			
			var itemExt:String;
			switch (item.type) {
				case GIF, Video:
					itemExt = url.urlExtension() ?? "mp4";
				default:
					itemExt = Config.imageExt ?? url.urlExtension() ?? "jpg";
			}
			
			var itemName = name.appendIndex(itemInd);
			var itemRel = Config.prefix + itemName.appendExtension(itemExt);
			var itemFull = Config.outDir + "/" + itemRel;
			
			//
			var isVideo = item.type == GIF || item.type == Video;
			if (isVideo) {
				if (!CURL.download(url, itemFull)) continue;
			} else {
				if (!CURL.downloadImage(url, itemFull)) continue;
			}
			
			//
			if (isVideo) {
				var thumbURL = item.thumbnail_url;
				var thumbExt = Path.extension(thumbURL);
				if (thumbExt == "") thumbExt = "jpg";
				var thumbRel = Config.prefix + itemName + Config.sep + 'th.$thumbExt';
				var thumbFull = Config.outDir + "/" + thumbRel;
				if (!CURL.downloadImage(thumbURL, thumbFull)) thumbRel = null;
				ctx.addVideo(itemRel, item.altText ?? "", thumbRel);
			} else {
				var thumbRel = Magick.createThumb(itemRel, itemFull);
				ctx.addImage(itemRel, itemFull, thumbRel, item.altText ?? "");
			}
		}
	}
}
