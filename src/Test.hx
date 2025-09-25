class Test {
	public static function run() {
		Config.cache = true;
		Config.verbose = true;
		Config.prefix = "tmp/";
		Config.ready();
		
		var problems = [];
		inline function assert<T>(have:T, want:T, note:String) {
			if (have != want) problems.push("Assertion failed for " + note + ": have " + have + ", want: " + want);
		}
		
		var ctx:FetchCtx;
		
		#if 1 // masto
		ctx = Main.procURL("https://mastodon.social/@yellowafterlife/115033558720661387");
		assert(ctx.imageLines.length, 2, "Mastodon images");
		
		ctx = Main.procURL("https://mastodon.social/@yellowafterlife/114128808002109755");
		assert(ctx.imageLines.length, 1, "Mastodon video");
		#end
		
		#if 1 // bsky
		ctx = Main.procURL("https://bsky.app/profile/yellowafterlife.bsky.social/post/3lwh6s7axvc2o");
		assert(ctx.imageLines.length, 2, "BSky images");
		
		ctx = Main.procURL("https://bsky.app/profile/yellowafterlife.bsky.social/post/3ljvf56g3rk2g");
		assert(ctx.videoLines.length, 1, "BSky video");
		
		ctx = Main.procURL("https://bsky.app/profile/yellowafterlife.bsky.social/post/3lvtjudru2k2u");
		assert(ctx.imageLines.length, 1, "BSky quote");
		#end
		
		#if 1 // twitter
		ctx = Main.procURL("https://x.com/YellowAfterlife/status/1956382267808608509");
		assert(ctx.imageLines.length, 2, "Twitter images");
		
		ctx = Main.procURL("https://x.com/YellowAfterlife/status/1967645815188729940");
		assert(ctx.videoLines.length, 1, "Twitter GIF");
		
		ctx = Main.procURL("https://x.com/YellowAfterlife/status/1870232809631023361");
		assert(ctx.videoLines.length, 1, "Twitter video");
		#end
		
		if (problems.length == 0) {
			Sys.println("All is well!");
		} else {
			for (line in problems) Sys.println(line);
		}
	}
}