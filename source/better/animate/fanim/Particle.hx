package better.animate.fanim;

import flixel.FlxSprite;

class Particle extends FlxSprite
{
    public var framesInOrder:Array<String>;
    public var fps:Float;
    public var loop:Bool;
    public var isPlaying(get, never):Bool;

    private var timer:Float = 0;
    private var frameIndex:Int = 0;
    private var playing:Bool = false;

    function get_isPlaying():Bool
    {
        return playing;
    }

    public function new(
        framesInOrder:Array<String>,
        fps:Float,
        ?loop:Bool = false
    )
    {
        super();

        this.framesInOrder = framesInOrder;
        this.fps = fps;
        this.loop = loop;

        if (framesInOrder.length > 0)
            loadGraphic(framesInOrder[0]);
    }

    public function play():Void
    {
        if (framesInOrder.length == 0 || fps <= 0)
            return;

        playing = true;
        timer = 0;
        frameIndex = 0;

        loadGraphic(framesInOrder[0]);
    }

    public function stop():Void
    {
        playing = false;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!playing)
            return;

        timer += elapsed;

        var frameTime:Float = 1 / fps;

        while (timer >= frameTime && playing)
        {
            timer -= frameTime;
            frameIndex++;

            if (frameIndex >= framesInOrder.length)
            {
                if (loop)
                {
                    frameIndex = 0;
                }
                else
                {
                    frameIndex = framesInOrder.length - 1;
                    playing = false;
                }
            }

            loadGraphic(framesInOrder[frameIndex]);
        }
    }
}