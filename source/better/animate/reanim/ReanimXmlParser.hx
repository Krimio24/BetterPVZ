package better.animate.reanim;

import haxe.xml.Access;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import better.animate.reanim.Reanim.ReanimatorTransform;
import better.animate.reanim.Reanim.ReanimImageMap;
import better.animate.reanim.Reanim.ReanimatorTrack;
import better.animate.reanim.Reanim.ReanimatorDefinition;

class ReanimXmlParser {
	public static function parse(xmlPath:String, imageMap:Array<ReanimImageMap>):ReanimatorDefinition {
		var rawXml = openfl.utils.Assets.getText(xmlPath);
		var xml = new Access(Xml.parse(rawXml).firstElement());

		var parsedTracks:Array<ReanimatorTrack> = [];

		for (trackNode in xml.nodes.track) {
			var parsedFrames:Array<ReanimatorTransform> = [];

			for (tNode in trackNode.nodes.t) {
				var prev:ReanimatorTransform = parsedFrames.length > 0 ? parsedFrames[parsedFrames.length - 1] : null;
				var trans = new ReanimatorTransform();

				if (prev != null) {
					trans.mTransX = prev.mTransX;
					trans.mTransY = prev.mTransY;
					trans.mSkewX = prev.mSkewX;
					trans.mSkewY = prev.mSkewY;
					trans.mScaleX = prev.mScaleX;
					trans.mScaleY = prev.mScaleY;
					trans.mAlpha = prev.mAlpha;
					trans.mFrame = prev.mFrame;
					trans.mGraphic = prev.mGraphic;
				} else {
					trans.mTransX = 0.0;
					trans.mTransY = 0.0;
					trans.mSkewX = 0.0;
					trans.mSkewY = 0.0;
					trans.mScaleX = 1.0;
					trans.mScaleY = 1.0;
					trans.mAlpha = 1.0;
					trans.mFrame = 0.0;
					trans.mGraphic = null;
				}

				if (tNode.hasNode.x)
					trans.mTransX = Std.parseFloat(tNode.node.x.innerData);
				if (tNode.hasNode.y)
					trans.mTransY = Std.parseFloat(tNode.node.y.innerData);
				if (tNode.hasNode.kx)
					trans.mSkewX = Std.parseFloat(tNode.node.kx.innerData);
				if (tNode.hasNode.ky)
					trans.mSkewY = Std.parseFloat(tNode.node.ky.innerData);
				if (tNode.hasNode.sx)
					trans.mScaleX = Std.parseFloat(tNode.node.sx.innerData);
				if (tNode.hasNode.sy)
					trans.mScaleY = Std.parseFloat(tNode.node.sy.innerData);
				if (tNode.hasNode.a)
					trans.mAlpha = Std.parseFloat(tNode.node.a.innerData);
				if (tNode.hasNode.f)
					trans.mFrame = Std.parseFloat(tNode.node.f.innerData);

				if (tNode.hasNode.i) {
					var imgId:String = tNode.node.i.innerData;
					trans.mGraphic = resolveGraphicFromMap(imgId, imageMap);
				}

				parsedFrames.push(trans);
			}

			var track = new ReanimatorTrack();
			track.mName = trackNode.hasNode.name ? trackNode.node.name.innerData : "";
			track.mTransforms = parsedFrames;
			track.mTransformCount = parsedFrames.length;

			parsedTracks.push(track);
		}

		var fpsVal:Float = xml.hasNode.fps ? Std.parseFloat(xml.node.fps.innerData) : 12.0;

		var def = new ReanimatorDefinition();
		def.mFPS = fpsVal;
		def.mTracks = parsedTracks;
		def.mTrackCount = parsedTracks.length;

		return def;
	}

	public static function resolveGraphicFromMap(imageId:String, map:Array<ReanimImageMap>):FlxGraphic {
		if (imageId == "" || map == null)
			return null;

		for (entry in map) {
			if (entry.id == imageId) {
				var candidatePaths:Array<String> = [
					entry.path,
					"assets/images/reanim/" + entry.path,
					"assets/reanim/" + entry.path,
					"assets/images/" + entry.path,
					"assets/" + entry.path
				];
				for (path in candidatePaths) {
					if (openfl.utils.Assets.exists(path)) {
						return FlxG.bitmap.add(path);
					}
				}
				try {
					return FlxG.bitmap.add("assets/images/reanim/" + entry.path);
				} catch (e:Dynamic) {}
				break;
			}
		}
		return null;
	}
}
