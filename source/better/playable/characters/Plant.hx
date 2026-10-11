package better.playable.characters;

import better.playable.characters.Zombie.ZombieC;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

typedef PlantC = {
	var maxhealth:Float;
	var name:String;
}

class Plant extends FlxTypedSpriteGroup<FlxSprite> {
	var _health:Float;
	var params:PlantC;

	public function new(id:String, ?params:PlantC) {
		super();
		if (params != null)
			this.params = params;
	}

	public function onZombieLawn(zombie:Zombie, frontboxes:Float) {}

	public function onPlant(row:Int, colums:Int) {}

	public function onDie(zombie:Zombie) {}
}
