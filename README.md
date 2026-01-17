# YAL's social media downloader

**Quick links:** [documentation](https://yal-tools.github.io/yal-dl/)

## Preparations

You'll need to have a vague understanding of what a "command prompt" or a "terminal" is.

1.	Install [node.js](https://nodejs.org/).\
	Just about any semi-recent version should work.
2.	Install [CURL](https://curl.se/) if you don't have it yet.\
	CURL is included with most operating systems these days,
	see if running `curl --version` in a command prompt/terminal finds the app.
3.	Some image-related features (like resizing or thumbnail generation) use [ImageMagick](https://imagemagick.org/).\
	You might install it if you intend to use those or just in case.
4.	Download this repository.  
	That's ❮❯ Code ➜ Download ZIP, or "clone" it if you know Git
5.	If you have downloaded a ZIP, extract it somewhere.

## How to use

At its simplest, the tool is used like so (from a Command Prompt/terminal in `bin` directory):
```
node yal-dl.js https://bsky.app/profile/yellowafterlife.bsky.social/post/3lwh6s7axvc2o
```
and the tool will output something like
```
bsky=yellowafterlife.bsky.social=3lwh6s7axvc2o.jpg
bsky=yellowafterlife.bsky.social=3lwh6s7axvc2o=1.jpg
```
which are names of the images it just downloaded.

If you want to download images from several posts at once, you can supply additional argument(s):
```
node yal-dl.js https://bsky.app/profile/yellowafterlife.bsky.social/post/3lwh6s7axvc2o https://bsky.app/profile/yellowafterlife.bsky.social/post/3lwk6evrnec2o
```
and the output will look like so:
```
bsky=yellowafterlife.bsky.social=3lwh6s7axvc2o.jpg
bsky=yellowafterlife.bsky.social=3lwh6s7axvc2o=1.jpg

bsky=yellowafterlife.bsky.social=3lwk6evrnec2o.jpg
```
(an empty line separates media from different posts)

The tool is single-file so you can copy `yal-dl.js` wherever you need it,
or even make it globally accessible.

Check out the [docs](https://yal-tools.github.io/yal-dl/) for more parameters -
you can have the tool take input from files, or output to a file,
or even generate Markdown for a little gallery like this!

<img src="./gallery.webp" width="820" height="480" alt="Downloaded images (in this case, mostly photos and paintings of architecture) showing in a columnar/masonry layout inside VS Code">

<details><summary>Gallery breakdown</summary><blockquote>

`links.txt`:
```
Staircase & greenery
https://x.com/jhsuart/status/1428439445246672898

Lighthouse
https://x.com/LukeTscharke/status/1456391300907896832

Water ceiling
https://x.com/pasta_loving/status/1923581169339335071

...
```
Command:
```
node yal-dl.js --prefix img/ --in links.txt --out out.md --thumb 240x400
```
Markdown structure:
```md
<style>
.columns {
	column-count: auto;
	column-width: 160px;
}
.columns > *:not(h2) {
	break-before: avoid;
	break-inside: avoid;
}

</style>
<div class="columns">

## [Staircase & greenery](https://x.com/jhsuart/status/1428439445246672898)
[![](img/twitter=jhsuart=1428439445246672898=th.jpg)](img/twitter=jhsuart=1428439445246672898.jpg)

...

</div>
```

</blockquote></details>

## Support

| Website | S.? | Notes |
| ------: | :----: | :---- |
| Bluesky | ✔ | Uses [VixBluesky](https://github.com/Lexedia/VixBluesky) to fetch URLs for videos and/or logged-in-only accounts.
| Twitter | ✔ | Uses [vxTwitter](https://github.com/dylanpdx/BetterTwitFix) to fetch all metadata.
| Tumblr | ⚠ | OG only contains the first image, consider using [fxTumblr](https://github.com/knuxify/fxtumblr) for multi-media posts.
| Mastodon | ✔ | State-of-art OpenGraph support.
| WAFRN | ⚠ | Off-network (e.g. bsky) posts may contain malformed image URLs[¹](https://codeberg.org/wafrn/wafrn/issues/239).
| YouTube | ❌ | OG only contains video thumbnails, consider using [yt-dlp](https://github.com/yt-dlp/yt-dlp)/etc.

Other websites are supported if they:
1.	Include their media content in OpenGraph tags
2.	Have posts distinguished by the URL (e.g. `/user/cool-post`)
	rather than HTTP GET parameters (e.g. `/posts?id=101`).

The bare minimum OpenGraph implementation has long been "first image/thumbnail and a little text"
so you can typically count on that much.

## Findings

This sounds like a one-evening project and it really should be,
but turns out that everyone likes when *other people* implement OpenGraph,
but do not like doing so themselves:

-	Twitter no longer serves *any* OpenGraph content,
	so third-party services are the primary way to acquire media file URLs.
-	Have you seen those mostly-functional Bluesky embeds in Discord? Those aren't OG.\
	They also ignore the logged-in-only rules, as if that has ever stopped anyone.
-	Bluesky can also serve you WEBPs or *slightly lossy* PNGs if you ask nicely.\
	(change `@jpeg` at the end of a URL to `@webp` or `@png`)
-	Isn't it kind of quirky that social media put usernames in `og:title`?\
	Like if you supply a news article, image most likely relates to `og:title`,
	but for social media you need to read `og:description` instead. And how do you know which one it is?
-	You can hand-write rules for other websites, but it is work (on average).

## Considerations

Subject of expansion;

-	Pinterest is okay if that works for you, though it has its limitations.
-	Storing your mood boards in Discord/Telegram is one of the worse ideas,
	it's someone's else computers and they can kick you out whenever they feel like it
	(e.g. false-positives for spam).
-	Pasting images into a folder works, but you might have a hard time figuring out where'd
	something come from if reverse image search comes up empty.
-	Naming and organizing images/notes about them takes time and effort.

This tool makes it easier to download and organize images without opening each page yourself.

## Building
You'll need [Haxe](https://haxe.org/) installed.
```
haxe build.hxml
```
If all is well, `bin/yal-dl.js` will be updated.

## TODOs

- Documentation
- Alt text
- An option to include post text in Markdown output mode?
- Add permalink to EXIF metadata (needs IM)
- An option to use `<img>` with width/height to avoid layouts reflows
- [fxReddit](https://github.com/MinnDevelopment/fxreddit), [vxinstagram](https://www.vxinstagram.com)?
