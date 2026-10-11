package better.graphics.shaders;

import openfl.utils.Assets;
import flixel.addons.system.macros.FlxRuntimeShaderMacro;
import flixel.util.FlxColor;

class RuntimeRainShader extends RuntimePostEffectShader
{
  public var time(default, set):Float = 1;

  function set_time(value:Float):Float
  {
    this.setFloat('uTime', value);
    return time = value;
  }

  public var spriteMode(default, set):Bool = false;

  function set_spriteMode(value:Bool):Bool
  {
    this.setBool('uSpriteMode', value);
    return spriteMode = value;
  }

  // The scale of the rain depends on the world coordinate system, so higher resolution makes
  // the raindrops smaller. This parameter can be used to adjust the total scale of the scene.
  // The size of the raindrops is proportional to the value of this parameter.
  public var scale(default, set):Float = 1;

  function set_scale(value:Float):Float
  {
    this.setFloat('uScale', value);
    return scale = value;
  }

  // The intensity of the rain. Zero means no rain and one means the maximum amount of rain.
  public var intensity(default, set):Float = 0.5;

  function set_intensity(value:Float):Float
  {
    this.setFloat('uIntensity', value);
    return intensity = value;
  }

  // the y coord of the puddle, used to mirror things
  public var puddleY(default, set):Float = 0;

  function set_puddleY(value:Float):Float
  {
    this.setFloat('uPuddleY', value);
    return puddleY = value;
  }

  // the y scale of the puddle, the less this value the more the puddle effects squished
  public var puddleScaleY(default, set):Float = 0;

  function set_puddleScaleY(value:Float):Float
  {
    this.setFloat('uPuddleScaleY', value);
    return puddleScaleY = value;
  }

  public var rainColor(default, set):FlxColor;

  function set_rainColor(color:FlxColor):FlxColor
  {
    this.setFloatArray('uRainColor', [color.red / 255, color.green / 255, color.blue / 255]);
    return rainColor = color;
  }

  public var numLightsSwag(default, set):Int = 0;

  function set_numLightsSwag(value:Int):Int
  {
    this.setInt('numLights', value);
    return numLightsSwag = value;
  }

  public function new()
  {
    var fragmentSource = Assets.getText('assets/shaders/rain.frag');
    fragmentSource = StringTools.replace(fragmentSource, "#pragma header",
      FlxRuntimeShaderMacro.retrieveMetadata("glFragmentHeader", true));
    super(fragmentSource);
  }

  public function update(elapsed:Float):Void
  {
    time += elapsed;
  }

}