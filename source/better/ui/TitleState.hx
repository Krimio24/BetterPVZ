package better.ui;

import better.shop.ShopItem;
import openfl.Assets;
import better.shop.ShopState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import better.playable.PlayState;

class TitleState extends FlxState {
	var bg:FlxSprite;
	var logo:FlxSprite;
	var barDirt:FlxSprite;
	var startText:FlxText;
	var versionText:FlxText;

	var accepted:Bool = false;

	override public function create():Void {
		super.create();

		bg = new FlxSprite().loadGraphic("assets/images/titlescreen.jpg");
		bg.antialiasing = true;
		add(bg);

		logo = new FlxSprite().loadGraphic("assets/images/PvZ_Logo.jpg");
		var alphaBmp = Assets.getBitmapData("assets/images/PvZ_Logo_.png");
		logo.pixels.copyChannel(alphaBmp, new openfl.geom.Rectangle(0, 0, logo.pixels.width, logo.pixels.height), new openfl.geom.Point(0, 0),
			openfl.display.BitmapDataChannel.RED, openfl.display.BitmapDataChannel.ALPHA);
		logo.antialiasing = true;
		add(logo);

		barDirt = new FlxSprite().loadGraphic("assets/images/LoadBar_dirt.png");
		barDirt.antialiasing = true;
		add(barDirt);

		startText = new FlxText(0, 0, barDirt.width, "Press A, Enter or Touch to Start", 18);
		startText.font = "assets/fonts/briane.ttf";
		startText.alignment = CENTER;
		startText.color = FlxColor.WHITE;
		startText.antialiasing = true;
		add(startText);

		versionText = new FlxText(0, 0, 400, "v1.0.0", 14);
		versionText.font = "assets/fonts/briane.ttf";
		versionText.alignment = CENTER;
		versionText.color = 0xFFD0D0D0;
		add(versionText);

		rescaleAndPosition();
		FlxG.signals.gameResized.add(onGameResized);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (!accepted) {
			var pressedKey:Bool = FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE;
			var pressedTouch:Bool = FlxG.mouse.justPressed && FlxG.mouse.overlaps(barDirt);

			var pressedPad:Bool = false;
			if (FlxG.gamepads.lastActive != null) {
				var pad = FlxG.gamepads.lastActive;
				pressedPad = pad.justPressed.START || pad.justPressed.A || pad.justPressed.B || pad.justPressed.X;
			}

			if (pressedKey || pressedTouch || pressedPad) {
				accepted = true;
				onStartPressed();
			}
		}
	}

	function onGameResized(s:Float, h:Float):Void {
		rescaleAndPosition();
	}

	function rescaleAndPosition():Void {
		var screenW:Float = FlxG.width;
		var screenH:Float = FlxG.height;

		var scale:Float = Math.max(screenW / bg.graphic.width, screenH / bg.graphic.height);
		bg.scale.set(scale, scale);
		bg.updateHitbox();
		bg.screenCenter();

		logo.screenCenter(X);
		logo.y = 40;

		barDirt.screenCenter(X);
		barDirt.y = screenH - barDirt.height - 80;

		startText.x = barDirt.x;
		startText.y = barDirt.y + (barDirt.height - startText.height) / 2;

		versionText.screenCenter(X);
		versionText.y = barDirt.y + barDirt.height + 12;
	}

	function onStartPressed():Void {
		if (FlxG.sound.music != null) {
			FlxG.sound.music.stop();
			FlxG.sound.music = null;
		}

		FlxG.switchState(() -> new //ShopState()); 
		 PlayState({
			lawnID: "roof",
			level: "first",
			seeds: ["peashooter", "sunflower", "peashooter", "sunflower", "peashooter", "sunflower"],
			generation: ["zombie", "zombie_conehead"],
			generationIntensity: [3.0, 1.5]
		}));
		
	}

	override public function destroy():Void {
		FlxG.signals.gameResized.remove(onGameResized);
		super.destroy();
	}
}
