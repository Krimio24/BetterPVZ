package better.ui;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import better.utils.HapticUtil;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
#if desktop
import steam.UserStats;
#end
import flixel.FlxG;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.Assets;
import haxe.Json;

class PopUp extends Sprite {
    public static var instance:Null<PopUp>;

    public var bg:Bitmap;
    public var title:TextField;
    public var tform:TextFormat;
    public var desc:TextField;
    public var dform:TextFormat;
    public var icon:Bitmap;

    private var tween:FlxTween;
    private var isShowing:Bool = false;

    public function new() {
        super();
        instance = this;

        var bitmapData:BitmapData = Assets.getBitmapData("assets/images/popup.png");
        bg = new Bitmap(bitmapData);
        addChild(bg);

        var brianeFontName:String = Assets.getFont("briane").fontName;

        tform = new TextFormat(brianeFontName, 26, 0xFFB15D36);
        dform = new TextFormat(brianeFontName, 15, 0xFFAF6D4E);

        title = new TextField();
        title.embedFonts = true;
        title.selectable = false;
        title.defaultTextFormat = tform;
        title.autoSize = LEFT;
        title.x = 115;
        title.y = 12;
        addChild(title);

        desc = new TextField();
        desc.embedFonts = true;
        desc.selectable = false;
        desc.autoSize = NONE;
        desc.multiline = true;
        desc.wordWrap = true;
        desc.width = 280;
        desc.height = 65;
        desc.defaultTextFormat = dform;
        desc.x = 115;
        desc.y = 42;
        addChild(desc);

        icon = new Bitmap();
        icon.x = 20;
        icon.y = 15;
        addChild(icon);

        updatePosition();
        this.y = getHiddenY();

        FlxG.signals.gameResized.add(function(w:Int, h:Int) {
            updatePosition();
            if (isShowing) {
                show();
            } else {
                this.y = getHiddenY();
            }
        });
    }

    private function updatePosition():Void {
        this.scaleX = getScaleX();
        this.scaleY = getScaleY();
        this.x = FlxG.scaleMode.offset.x + (FlxG.width - bg.width) * this.scaleX / 2;
    }

    private function getScaleX():Float {
        return FlxG.scaleMode.scale.x > 0 ? FlxG.scaleMode.scale.x : 1;
    }

    private function getScaleY():Float {
        return FlxG.scaleMode.scale.y > 0 ? FlxG.scaleMode.scale.y : 1;
    }

    private function getHiddenY():Float {
        return FlxG.scaleMode.offset.y - (bg.height + 50) * getScaleY();
    }

    

    public function arch(id:String) {
        var json:Dynamic = Json.parse(Assets.getText('assets/data/save/archs/$id.json'));
        #if desktop
        UserStats.setAchievement(id, true);
        #end
        HapticUtil.vibrateFor(0, 0.8, 0.8, 150);
		FlxG.sound.play("assets/sounds/chime.ogg", 1, false);
        setInfo(json.name, json.desc, json.icon_path);
        show();
    }

    public function setInfo(t:String, d:String, i:String) {
        title.text = t;
        title.setTextFormat(tform);

        desc.text = d;
        desc.setTextFormat(dform);

        if (i != null && i != "") {
            var bdata:BitmapData = Assets.getBitmapData(i);
            icon.bitmapData = bdata;
            
            var targetSize:Float = 80.0;
            icon.scaleX = targetSize / bdata.width;
            icon.scaleY = targetSize / bdata.height;
            icon.smoothing = true;
        }
    }

    public function show() {
        if (tween != null) tween.cancel();

        isShowing = true;

        var hideY:Float = getHiddenY();
        var targetY:Float = FlxG.scaleMode.offset.y + FlxG.height * (26.0 / 720.0) * getScaleY();
        this.y = hideY;

        tween = FlxTween.tween(this, {y: targetY}, 0.45, {
            ease: FlxEase.expoOut,
            onComplete: function(t:FlxTween) {
                tween = FlxTween.tween(this, {y: hideY}, 0.75, {
                    ease: FlxEase.expoInOut,
                    startDelay: 5.0,
                    onComplete: function(t:FlxTween) {
                        isShowing = false;
                    }
                });
            }
        });
    }
}