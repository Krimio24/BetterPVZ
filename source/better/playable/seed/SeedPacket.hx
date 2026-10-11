package better.playable.seed;

import better.graphics.shaders.AdjustColorShader;
import flixel.text.FlxText;
import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import better.animate.arrow.ArrowAnimation;
import flixel.FlxG;
import flixel.FlxSprite;

class SeedPacket extends FlxTypedSpriteGroup<FlxSprite> {
	public var suncost:Int;
	public var seed:ArrowAnimation;
	public var suntext:FlxText;
	public var pkShader:AdjustColorShader;
	public var selected:FlxSprite;

	public function new(seedId:Int, ?image:String = "packet_plants") {
		super();
		pkShader = new AdjustColorShader();
		seed = new ArrowAnimation('assets/images/$image.png', 50, 70, seedId);
		selected = new FlxSprite();

		seed.shader = pkShader;

		suntext = new FlxText(0, 0, 50, Std.string(suncost), 15);
		suntext.setFormat("briane", 15, 0xFF000000, LEFT, NONE);
		suntext.x = seed.x + 12;
		suntext.y = seed.y + 52;

		selected.loadGraphic("assets/particles/SeedPacketFlash.png");
		selected.x = seed.x;
		selected.y = seed.y;
		selected.visible = false;

		this.add(seed);
		this.add(suntext);
		this.add(selected);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		_update();
	}

	public function selectedMode(m:Bool) {
		selected.visible = m;
		pkShader.saturation = -50;
		pkShader.brightness = -100;
	}

	public function _update() {
		if (FlxG.mouse.overlaps(seed)) {
			if (FlxG.mouse.pressed) {
				pkShader.saturation = -50;
				pkShader.brightness = -100;
				selectedMode(false);
			} else {
				pkShader.saturation = -15;
				pkShader.brightness = -30;
				selectedMode(false);
			}
		} else {
			pkShader.saturation = 0;
			pkShader.brightness = 0;
		}

		seed.shader = pkShader;
	}
}
