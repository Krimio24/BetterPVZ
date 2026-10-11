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

				// Copiar valores del frame anterior si existen
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
				}

				// Sobrescribir si el nodo <t> actual los define
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

				// Si el nodo actual define una imagen <i>, la resolvemos directamente
				if (tNode.hasNode.i) {
					var imgId:String = tNode.node.i.innerData;
					trans.mGraphic = resolveGraphicFromMap(imgId, imageMap);
				}

				parsedFrames.push(trans);
			}

			var track = new ReanimatorTrack();
			track.mName = trackNode.hasNode.name ? trackNode.node.name.innerData : "";
			track.mTransforms = parsedFrames;

			parsedTracks.push(track);
		}

		var fpsVal:Int = xml.hasNode.fps ? Std.parseInt(xml.node.fps.innerData) : 12;

		var def = new ReanimatorDefinition();
		def.mFPS = fpsVal;
		def.mTracks = parsedTracks;

		return def;
	}

	public static function resolveGraphicFromMap(imageId:String, map:Array<ReanimImageMap>):FlxGraphic {
		if (imageId == "" || map == null)
			return null;

		for (entry in map) {
			if (entry.id == imageId) {
				var fullPath:String = "assets/images/reanim/" + entry.path;
				if (openfl.utils.Assets.exists(fullPath)) {
					return FlxG.bitmap.add(fullPath);
				}
				break;
			}
		}
		return null;
	}
}
