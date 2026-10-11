package better.playable.lawn._default;

import flixel.FlxSprite;
import better.playable.lawn.Lawn;

typedef Params = {
    var grass:Bool;
    var cowlsLevel:Int;
}

@:keep
class Grass extends Lawn {

    public var bg:FlxSprite;
    public var _params:Params;

    public function setParams(params:Params) {
        _params = params;
    }

    public function new() {
        super("grass");
        this.rows = 5;
        this.cols = 9;
    }

    public override function buildLawn() {
        bg = new FlxSprite();
        bg.loadGraphic("assets/images/background1.png");
        bg.scale.set(1.2, 1.2);
        bg.screenCenter();
        bg.x -= 60;
        add(bg);
        trace("Created");
        return this;
    }
}