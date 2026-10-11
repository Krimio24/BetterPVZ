package better.playable.pause;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;

class Slider extends FlxTypedSpriteGroup<FlxSprite> {

    public var bg:FlxSprite;
    public var buttonCenter:FlxSprite;
    public var value(default, set):Float = 0.0;
    public var isDragging:Bool = false;
    public var onChange:Float->Void;

    public function new(X:Float = 0, Y:Float = 0, defaultValue:Float = 0.5) {
        super(X, Y);

        bg = new FlxSprite(0, 0);
        bg.loadGraphic("assets/images/options_sliderslot.png");
        add(bg);

        buttonCenter = new FlxSprite(0, 0);
        buttonCenter.loadGraphic("assets/images/options_sliderknob2.png");
        buttonCenter.y = bg.y + (bg.height / 2) - (buttonCenter.height / 2);
        add(buttonCenter);

        this.value = FlxMath.bound(defaultValue, 0.0, 1.0);
        updateKnobPosition();
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);

        if (FlxG.mouse.justPressed) {
            if (FlxG.mouse.overlaps(bg) || FlxG.mouse.overlaps(buttonCenter)) {
                isDragging = true;
            }
        }

        if (FlxG.mouse.justReleased) {
            isDragging = false;
        }

        if (isDragging) {
            var minX:Float = x;
            var maxX:Float = x + bg.width - buttonCenter.width;
            var mouseX:Float = FlxG.mouse.x - (buttonCenter.width / 2);

            var clampedX:Float = FlxMath.bound(mouseX, minX, maxX);
            var newValue:Float = (clampedX - minX) / (maxX - minX);
            
            if (newValue != value) {
                value = newValue;
            }
        }
    }

    private function set_value(newValue:Float):Float {
        value = FlxMath.bound(newValue, 0.0, 1.0);
        updateKnobPosition();

        if (onChange != null) {
            onChange(value);
        }

        return value;
    }

    private function updateKnobPosition():Void {
        if (bg != null && buttonCenter != null) {
            var minX:Float = x;
            var maxX:Float = x + bg.width - buttonCenter.width;
            buttonCenter.x = FlxMath.lerp(minX, maxX, value);
        }
    }
}