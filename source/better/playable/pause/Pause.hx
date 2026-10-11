package better.playable.pause;

import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxSubState;
import openfl.display.BitmapData;
import openfl.display.BitmapDataChannel;
import openfl.geom.Point;
import openfl.utils.Assets;

class Pause extends FlxSubState {

	var menuBack:FlxSprite;
	var resumeButton:FlxSprite;
	var mm = PlayState.mm;
	var musicSlider:Slider;

    var sfxSlider:Slider;
	
	public function new() {
		super(0x00000000);
	}

	public override function create() {
		super.create();

		var imageBD:BitmapData = Assets.getBitmapData("assets/images/options_menuback.jpg");
		var maskBD:BitmapData = Assets.getBitmapData("assets/images/options_menuback_.png");

		var resultBD:BitmapData = new BitmapData(imageBD.width, imageBD.height, true, 0x00000000);

		resultBD.copyPixels(imageBD, imageBD.rect, new Point(0, 0));

		resultBD.copyChannel(maskBD, maskBD.rect, new Point(0, 0), BitmapDataChannel.RED, BitmapDataChannel.ALPHA);

		menuBack = new FlxSprite();
		menuBack.pixels = resultBD;
		menuBack.scale.set(1.1, 1.1);
		menuBack.screenCenter();

		FlxG.sound.play("assets/sounds/pause.ogg", 1.0, false);

		mm.bassManager.setMo3TicksPerRow(4);

		resumeButton = new FlxSprite();
		resumeButton.loadGraphic("assets/images/options_backtogamebutton0.png");
		resumeButton.screenCenter();
		resumeButton.y += 175;
		resumeButton.scale.set(1.5, 1.5);

		musicSlider = new Slider();
		musicSlider.onChange = function(value:Float) {
			for (channel in 0...40)
				mm.bassManager.setMo3ChannelVolume(channel, value);
		}
		musicSlider.screenCenter();
		musicSlider.scale.set(1.3, 1.3);

		sfxSlider = new Slider(0, 0, FlxG.sound.volume);
		sfxSlider.onChange = function(value:Float) {
			for (channel in 0...40)
				FlxG.sound.volume = value;
		}
        sfxSlider.y -= 100;

		sfxSlider.screenCenter();
		sfxSlider.scale.set(1.3, 1.3);

		add(menuBack);
		add(musicSlider);
        add(sfxSlider);
		add(resumeButton);
	}

	public override function update(delta:Float) {
		super.update(delta);
		if (FlxG.mouse.overlaps(resumeButton)) {
			resumeButton.loadGraphic("assets/images/options_backtogamebutton2.png");
			if (FlxG.mouse.justPressed) {
				closeAction();
			}
		}
		if (!FlxG.mouse.overlaps(resumeButton)) {
			resumeButton.loadGraphic("assets/images/options_backtogamebutton0.png");
		}
	}

	function closeAction() {
		for (channel in 0...40) {
			FlxTween.num(0.7, 1, 0.6, {ease: FlxEase.expoOut}, function(value:Float) {
				if (!mm.mutedChannels.contains(channel))
					mm.bassManager.setMo3ChannelVolume(channel, value);
			});
		}
		FlxTween.num(4, 2, 0.6, {ease: FlxEase.expoOut}, function(value:Float) {
			mm.bassManager.setMo3TicksPerRow(Std.int(value));
		});

		this.close();
		resumeButton.visible = false;
		menuBack.visible = false;
	}
}
