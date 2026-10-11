package better.ui;

import openfl.events.Event;
import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BitmapDataChannel;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
import openfl.text.Font;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import openfl.Lib;
import flixel.system.FlxBasePreloader;

@:bitmap('assets/images/titlescreen.jpg')
class BGImage extends BitmapData {}

@:bitmap('assets/images/PvZ_Logo.jpg')
class LogoImage extends BitmapData {}

@:bitmap('assets/images/PvZ_Logo_.png')
class LogoMaskImage extends BitmapData {}

@:bitmap('assets/images/LoadBar_dirt.png')
class LoadBarDirt extends BitmapData {}

@:font('assets/fonts/briane.ttf')
class BrianeFont extends Font {}

class MainMenuLoader extends FlxBasePreloader {
    var gr:Sprite;
    var bg:BGImage;
    var bgBitmap:Bitmap;

    var logoContainer:Sprite;
    var logo:Bitmap;

    var barContainer:Sprite;
    var barDirt:Bitmap;

    var startText:TextField;
    var versionText:TextField;

    public function new() {
        super(0.1);
    }

    public override function create() {
        super.create();

        Font.registerFont(BrianeFont);

        gr = new Sprite();
        bg = new BGImage(0, 0);
        bgBitmap = new Bitmap(bg);
        gr.addChild(bgBitmap);
        addChild(gr);

        logoContainer = new Sprite();
        var logoData = new LogoImage(0, 0);
        var logoMask = new LogoMaskImage(0, 0);

        logoData.copyChannel(
            logoMask,
            new Rectangle(0, 0, logoData.width, logoData.height),
            new Point(0, 0),
            BitmapDataChannel.RED,
            BitmapDataChannel.ALPHA
        );

        logo = new Bitmap(logoData);
        logoContainer.addChild(logo);
        addChild(logoContainer);

        barContainer = new Sprite();

        var dirtData = new LoadBarDirt(0, 0);
        barDirt = new Bitmap(dirtData);
        barContainer.addChild(barDirt);

        var startFormat:TextFormat = new TextFormat("briane", 18, 0xFFFFFF);
        startFormat.align = TextFormatAlign.CENTER;

        startText = new TextField();
        startText.defaultTextFormat = startFormat;
        startText.embedFonts = true;
        startText.selectable = false;
        startText.text = "Press A, Enter or Touch to Start";
        startText.width = barDirt.width;
        startText.height = 30;
        barContainer.addChild(startText);

        var versionFormat:TextFormat = new TextFormat("briane", 14, 0xD0D0D0);
        versionFormat.align = TextFormatAlign.CENTER;

        versionText = new TextField();
        versionText.defaultTextFormat = versionFormat;
        versionText.embedFonts = true;
        versionText.selectable = false;
        versionText.text = "v1.0.0";
        versionText.width = 400;
        versionText.height = 22;
        barContainer.addChild(versionText);

        addChild(barContainer);

        Lib.current.stage.addEventListener(Event.RESIZE, onResize);
        updatePosition();
    }

    override function update(Percent:Float):Void {
        super.update(Percent);
    }

    function onResize(e:Event):Void {
        updatePosition();
    }

    function updatePosition():Void {
        var stageW:Float = Lib.current.stage.stageWidth;
        var stageH:Float = Lib.current.stage.stageHeight;

        var scale:Float = Math.max(stageW / bg.width, stageH / bg.height);

        bgBitmap.width = bg.width * scale;
        bgBitmap.height = bg.height * scale;

        gr.x = (stageW - bgBitmap.width) / 2;
        gr.y = (stageH - bgBitmap.height) / 2;

        logoContainer.x = (stageW - logo.width) / 2;
        logoContainer.y = 40;

        barContainer.x = (stageW - barDirt.width) / 2;
        barContainer.y = stageH - barDirt.height - 80;

        startText.x = 0;
        startText.y = (barDirt.height - startText.height) / 2;

        versionText.x = (barDirt.width - versionText.width) / 2;
        versionText.y = barDirt.height + 12;
    }

    public override function destroy():Void {
        if (Lib.current.stage.hasEventListener(Event.RESIZE)) {
            Lib.current.stage.removeEventListener(Event.RESIZE, onResize);
        }
        super.destroy();
    }
}