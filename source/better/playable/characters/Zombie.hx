package better.playable.characters;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

typedef Shield = {
	var resistense:Float;
}
typedef ZombieC = {
	var maxhealth:Float;
	var shields:Shield;
	var name:String;
}

class Zombie extends FlxTypedSpriteGroup<FlxSprite> {
	var _health:Float;
	var params:ZombieC;

	public function new(id:String, ?params:ZombieC) {
		super();
		if (params != null)
			this.params = params;
	}

	public function onPlant() {}

	public function onDie(by:String) {}
}
