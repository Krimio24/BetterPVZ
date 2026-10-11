package better.playable;

import flixel.util.FlxTimer;
import flixel.FlxG;
import openfl.Assets;
import haxe.Json;

typedef Line = {
	var event_name:String;
	var value:Dynamic;
}

class Level {
	var data:Dynamic;

	public static var onEvent:(Dynamic->Void);

	public function new() {
		FlxG.signals.postUpdate.add(function() {
			update();
		});
	}

	public function load(id:String) {
		var _:Dynamic = Json.parse(Assets.getText('assets/data/save/level/$id.json'));
		data = _;
	}

	public function init(event:(Dynamic->Void)) {}

	public function startEventLine() {
		var lineCount:Int = 0;
		var timer:FlxTimer = new FlxTimer();
		function again() {
			timer.start(0.2, function(_:FlxTimer) {
				var event:Array<Line> = data.lines[lineCount];
				lineCount += 1;
				again();

				onEvent(event[lineCount].value);
			}, 0);
		}
		if (lineCount == 0) {
			again();
		}
	}

	function update() {}
}
