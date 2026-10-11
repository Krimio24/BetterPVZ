
package better.playable.lawn;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

@:build(better.playable.lawn.LawnMacro.includeSubclasses())
@:autoBuild(better.playable.lawn.LawnMacro.build())
class Lawn extends FlxTypedSpriteGroup<FlxSprite> {

    public var id:String;

    public var rows:Int = 5;
    public var cols:Int = 9;

    public function new(id:String) {
        super();

        this.id = id;
    }

    public function buildLawn():FlxTypedSpriteGroup<FlxSprite> {
        return this;
    }

    public function zombieEnter() {}

    public function startHorde() {}

    public function endHorde() {}

    public function getInstance():Lawn {
        return this;
    }
}

