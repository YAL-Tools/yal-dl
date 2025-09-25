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
		
		var foundPerType = new DynamicAccess<Int>();
		for (item in media) {
			var url = item.url;
			var qAt = url.indexOf("?");
			if (qAt >= 0) url = url.substring(0, qAt);
			
			var itemExt = Path.extension(url).toLowerCase();
			if (itemExt == "") {
				itemExt = switch (item.type) {
					case GIF, Video: "mp4";
					default: "jpg";
				}
			}
			
			var indPerType = foundPerType[itemExt] ?? 0;
			var itemName = name.appendIndex(indPerType);
			var itemRel = Config.prefix + itemName + '.$itemExt';
			var itemFull = Config.outDir + "/" + itemRel;
			//
			if (!CURL.download(url, itemFull)) continue;
			foundPerType[itemExt] = indPerType + 1;
			//
			switch (item.type) {
				case GIF, Video: {
					var thumbURL = item.thumbnail_url;
					var thumbExt = Path.extension(thumbURL);
					if (thumbExt == "") thumbExt = "jpg";
					var thumbRel = Config.prefix + itemName + Config.sep + 'th.$thumbExt';
					var thumbFull = Config.outDir + "/" + thumbRel;
					if (!CURL.download(thumbURL, thumbFull)) thumbRel = null;
					ctx.addVideo(url, item.altText ?? "", thumbRel);
				};
				default: {
					ctx.addImage(url, item.altText ?? "");
				}
			}
		}
	}
}
