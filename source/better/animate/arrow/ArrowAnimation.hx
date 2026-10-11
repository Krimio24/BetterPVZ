package better.animate.arrow;

import flixel.FlxSprite;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Point;

class ArrowAnimation extends FlxSprite
{
    public var pileID(default, set):Int = 0;

    var pileWidth:Int;
    var pileHeight:Int;

    public function new(
        image:String,
        pileWidth:Int,
        pileHeight:Int,
        pileID:Int = 0
    )
    {
        super();

        this.pileWidth = pileWidth;
        this.pileHeight = pileHeight;
        this.pileID = pileID;

        loadPile(image);
    }

    function loadPile(image:String):Void
    {
        var source = BitmapData.fromFile(image);

        var columns = Std.int(source.width / pileWidth);

        var x = (pileID % columns) * pileWidth;
        var y = Std.int(pileID / columns) * pileHeight;

        var pile = new BitmapData(
            pileWidth,
            pileHeight,
            true,
            0x00000000
        );

        pile.copyPixels(
            source,
            new Rectangle(x, y, pileWidth, pileHeight),
            new Point(0, 0)
        );

        loadGraphic(pile);
    }

    function set_pileID(value:Int):Int
    {
        pileID = value;
        return value;
    }
}