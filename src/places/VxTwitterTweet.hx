package places;

typedef VxTwitterTweet = {
	allSameType:Bool,
	article:Any,
	combinedMediaUrl:String,
	communityNote:Any,
	conversationID:String,
	date:String,
	date_epoch:Int,
	fetched_on:Int,
	hasMedia:Bool,
	hashtags:Array<Any>,
	lang:String,
	likes:Int,
	mediaURLs:Array<String>,
	media_extended:Array<{
		altText:String,
		size:{
			height:Int,
			width:Int
		},
		thumbnail_url:String,
		type:VxTwitterMediaType,
		url:String
	}>,
	pollData:Any,
	possibly_sensitive:Bool,
	qrt:Any,
	qrtURL:Any,
	replies:Int,
	replyingTo:String,
	replyingToID:String,
	retweet:Any,
	retweetURL:Any,
	retweets:Int,
	text:String,
	tweetID:String,
	tweetURL:String,
	user_name:String,
	user_profile_image_url:String,
	user_screen_name:String
};
enum abstract VxTwitterMediaType(String) {
	var Image = "image";
	var GIF = "gif";
	var Video = "video";
}