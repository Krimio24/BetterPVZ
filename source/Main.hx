import better.playable.music.MusicMechanic;
import flixel.addons.sound.FlxRhythmConductor;
import better.ui.TitleState;
import lime.app.Application;
import flixel.util.FlxSave;
#if desktop
import steam.Steam;
import steam.UserStats;
#end
import flixel.FlxGame;
import flixel.FlxG;
import openfl.Lib;
import openfl.display.FPS;
import better.playable.PlayState;
import better.ui.PopUp;
import haxe.io.Path;

class Main {
	

	
	var conductor:FlxRhythmConductor;

	public function new() {
		var save:FlxSave = new FlxSave();
		save.bind("BetterPVZ");

		conductor = new FlxRhythmConductor();

		
		#if desktop
		if (save.data.lockedarch == null || !save.data.lockedarch) {
			UserStats.resetAllStats(true);

			save.data.lockedarch = true;
			save.flush();
		}
		#end

		save.close();

		

		FlxG.signals.postUpdate.add(function() {
			conductor.update();
		});
	}

	public static function main() {
		var stage = Lib.current.stage;
		var framerate:Int = 144;

		#if sys
		var numReg = ~/\d+/;
		for (i in Sys.args()) {
			if (numReg.match(i)) {
				var _framerate = Std.parseInt(numReg.matched(0));
				if (!Math.isNaN(_framerate))
					framerate = _framerate;
			}
		}
		#elseif html5
		framerate = 60;
		#end

		#if desktop
		if (Steam.init(3590)) {
			FlxG.signals.postUpdate.add(function() {
				Steam.update();
			});

			new Main();
		} else {
			Application.current.window.alert("The game could not initialize: Steam must be running.", "Steam Error");
			Sys.exit(0);
			return;	
		}
		#else
		new Main();
		#end

		var popup:PopUp = new PopUp();
		var game = new FlxGame(1280, 720, TitleState, framerate, framerate, true, false);
		stage.addChild(game);
		FlxG.scaleMode = new flixel.system.scaleModes.FillScaleMode();
		
		stage.addChild(popup);
		game.addChild(new FPS(10, 10, 0xff000000));

		
	}
}