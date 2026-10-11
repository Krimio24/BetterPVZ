package better.playable.seed;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import openfl.Assets;
import haxe.Json;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;

class SeedBank extends FlxTypedSpriteGroup<FlxSprite> {
    public var plants:Array<String> = ["peashooter"];
    public var sprite:FlxSprite;
    public var buyed:Bool;
    public var slots:Int;
    public var suntext:FlxText;

    public var seedGroup:FlxTypedSpriteGroup<FlxSprite>;
    public var seedPackets:Array<SeedPacket> = [];
    
    public var showelChart:FlxSprite;
    public var showel:FlxSprite;

    public var gloveChart:FlxSprite;
    public var glove:FlxSprite;

    public var selectedShowel:Bool = false;
    public var selectedGlove:Bool = false;

    public var selectedIndex:Int = 0; 

    var count:Int = 0;
    public var seedSpacing:Float = 55.0;

    public var onSelect:String->Void;

    public function new(p:Array<String>) {
        super();

        if (p != null) {
            plants = p;
        }

        sprite = new FlxSprite(0, 0);
        sprite.loadGraphic("assets/images/SeedBank.png");
        add(sprite);

        showelChart = new FlxSprite(sprite.width, 0);
        showelChart.loadGraphic("assets/images/ShovelBank.png");
        showelChart.scale.set(1.2, 1.2);
        showelChart.updateHitbox();
        add(showelChart);

        showel = new FlxSprite(sprite.width - 15, -26.2);
        showel.loadGraphic("assets/images/Shovel_hi_res.png");
        showel.scale.set(0.6, 0.6);
        add(showel);

        gloveChart = new FlxSprite(sprite.width + showelChart.width + 5, 0);
        gloveChart.loadGraphic("assets/images/ShovelBank.png");
        gloveChart.scale.set(1.2, 1.2);
        gloveChart.updateHitbox();
        add(gloveChart);

        glove = new FlxSprite(gloveChart.x + 5, gloveChart.y + 5);
        glove.loadGraphic("assets/images/Zen_GardenGlove.png");
        glove.scale.set(0.6, 0.6);
        glove.updateHitbox();
        add(glove);

        suntext = new FlxText(6, 62, 70, Std.string(Constants.sun));
        suntext.setFormat("briane", 20, FlxColor.BLACK, CENTER, FlxTextBorderStyle.NONE, FlxColor.TRANSPARENT, true);
        add(suntext);

        this.antialiasing = true;
    }

    public function _update(elapsed:Float):Void {
        super.update(elapsed);

        if (suntext != null) {
            suntext.text = Std.string(Constants.sun);
        }

        var targetCamera:FlxCamera = (this.cameras != null && this.cameras.length > 0) ? this.cameras[0] : FlxG.camera;

        var shovelTriggered:Bool = false;
        var gloveTriggered:Bool = false;
        var pressed:Bool = false;

        #if FLX_TOUCH
        for (touch in FlxG.touches.list) {
            if (touch.justPressed) {
                pressed = true;
                break;
            }
        }
        #end

        if (!pressed && FlxG.mouse.justPressed) {
            pressed = true;
        }

        if (pressed) {
            if (FlxG.mouse.overlaps(showelChart, targetCamera) || FlxG.mouse.overlaps(showel, targetCamera)) {
                shovelTriggered = true;
            } else if (FlxG.mouse.overlaps(gloveChart, targetCamera) || FlxG.mouse.overlaps(glove, targetCamera)) {
                gloveTriggered = true;
            } else {
                var clickedOnSeed:Bool = false;
                for (idx in 0...seedPackets.length) {
                    var packet = seedPackets[idx];
                    if (FlxG.mouse.overlaps(packet, targetCamera)) {
                        clickedOnSeed = true;
                        selectSeed(idx);
                        break;
                    }
                }
                if (!clickedOnSeed && (selectedShowel || selectedGlove)) {
                    deselectAll();
                }
            }
        }

        if (FlxG.keys.justPressed.S) {
            shovelTriggered = true;
        }
        if (FlxG.keys.justPressed.G) {
            gloveTriggered = true;
        }

        var gamepad = FlxG.gamepads.lastActive;
        if (gamepad != null) {
            if (gamepad.justPressed.LEFT_TRIGGER) { 
                shovelTriggered = true;
            }
            if (gamepad.justPressed.RIGHT_TRIGGER) { 
                gloveTriggered = true;
            }

            var numSeeds:Int = seedPackets.length;

            if (numSeeds > 0) {
                if (gamepad.justPressed.LEFT_SHOULDER) {
                    selectedIndex--;
                    if (selectedIndex < 0) {
                        selectedIndex = numSeeds - 1;
                    }
                    updateGamepadSelection();
                }

                if (gamepad.justPressed.RIGHT_SHOULDER) {
                    selectedIndex++;
                    if (selectedIndex >= numSeeds) {
                        selectedIndex = 0;
                    }
                    updateGamepadSelection();
                }

                if (gamepad.justPressed.A) {
                    selectSeed(selectedIndex);
                }
            }
        }

        if (shovelTriggered) {
            toggleShovel();
            trace("Showel Mode");
        } else if (gloveTriggered) {
            trace("Glove Mode");
            toggleGlove();
        }
    }

    public function selectSeed(index:Int):Void {
        if (index < 0 || index >= seedPackets.length) return;

        selectedIndex = index;
        selectedShowel = false;
        selectedGlove = false;
        FlxG.mouse.unload();
        showel.visible = true;
        glove.visible = true;

        for (i in 0...seedPackets.length) {
            if (i == index) {
                seedPackets[i].selectedMode(true);
            } else {
                seedPackets[i].selectedMode(false);
            }
        }

        if (onSelect != null && index < plants.length) {
            onSelect(plants[index]);
        }
    }

    function updateGamepadSelection():Void {
        deselectAll();

        for (i in 0...seedPackets.length) {
            if (i == selectedIndex) {
                seedPackets[i].selectedMode(true);
            } else {
                seedPackets[i].selectedMode(false);
            }
        }
    }

    function toggleShovel():Void {
        selectedShowel = !selectedShowel;
        selectedGlove = false;

        deselectSeeds();

        if (selectedShowel) {
            FlxG.mouse.load("assets/images/Shovel.png");
            showel.visible = false;
            glove.visible = true;
        } else {
            FlxG.mouse.unload();
            showel.visible = true;
        }
    }

    function toggleGlove():Void {
        selectedGlove = !selectedGlove;
        selectedShowel = false;

        deselectSeeds();

        if (selectedGlove) {
            FlxG.mouse.load("assets/images/Zen_GardenGlove.png");
            glove.visible = false;
            showel.visible = true;
        } else {
            FlxG.mouse.unload();
            glove.visible = true;
        }
    }

    function deselectSeeds():Void {
        for (packet in seedPackets) {
            packet.selectedMode(false);
        }
    }

    function deselectAll():Void {
        selectedShowel = false;
        selectedGlove = false;
        FlxG.mouse.unload();
        showel.visible = true;
        glove.visible = true;
        deselectSeeds();
    }

    public function createSeeds() {
        count = 0;
        seedPackets = [];

        var startX:Float = 80;
        var startY:Float = 8;

        for (a in plants) {
            var jsonText:String = Assets.getText('assets/data/save/seeds/$a.json');
            var i:Dynamic = Json.parse(jsonText);

            var seed:SeedPacket = new SeedPacket(i.seedID);
            seed.suntext.text = Std.string(i.sunCost);

            seed.x = startX + (count * seedSpacing);
            seed.y = startY;

            this.add(seed);
            seedPackets.push(seed);
            count++;
        }
    }
}