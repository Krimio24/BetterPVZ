package better.playable.lawn._default;

import haxe.Timer;
import better.playable.PlayState;
import better.playable.lawn.Lawn;
import better.utils.HapticUtil;
import better.graphics.shaders.AdjustColorShader;
import better.graphics.shaders.RuntimeRainShader;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxRandom;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import openfl.filters.ShaderFilter;

@:keep
class Roof extends Lawn {
	public var bg:FlxSprite;
	public var rainShader:RuntimeRainShader;
	public var colorFilter:ShaderFilter;
	public var colorShader:AdjustColorShader;
	public var thunder:Bool;

	public static var nightMode:Bool = false;

	var mist1:FlxBackdrop;
	var ended:Bool;
	var thunderTimer:FlxTimer;
	var thunderCooldown:Float = 0;

	public function new() {
		super("roof");

		rows = 5;
		cols = 9;
	}

	public override function buildLawn() {
		bg = new FlxSprite();

		colorShader = new AdjustColorShader();
		rainShader = new RuntimeRainShader();

		rainShader.rainColor = 0xFF6680cc;
		rainShader.time = 0;
		rainShader.scale = 1.5;
		rainShader.intensity = 0;
		rainShader.spriteMode = true;
		rainShader.puddleScaleY = 1.5;

		bg.shader = rainShader;

		colorFilter = new ShaderFilter(colorShader);
		PlayState.camHUD.filters = [colorFilter];

		if (!nightMode) {
			bg.loadGraphic("assets/images/background5.png");
		} else {
			mist1 = new FlxBackdrop("assets/images/mist_boss.png");

			mist1.setPosition(-650, -100);
			mist1.scrollFactor.set(1.1, 1.1);
			mist1.color = 0xffdcdae7;
			mist1.alpha = 0.4;

			var m:Float = PlayState.mm.bassManager.getMo3Bpm() / 60;
			mist1.velocity.x = m * 40;

			mist1.scale.set(2, 2);
			mist1.screenCenter();
			mist1.y -= 400;

			bg.loadGraphic("assets/images/background6boss.png");

			rainShader.intensity = 0.04;

			colorShader.brightness = -30;
			colorShader.saturation = -30;
		}

		bg.scale.set(1.2, 1.2);
		bg.screenCenter();

		bg.camera = PlayState.camGame;

		add(bg);

		if (mist1 != null)
			add(mist1);

		return this;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (thunderCooldown > 0)
			thunderCooldown -= elapsed;

		if (nightMode && thunderCooldown <= 0) {
			if (thunderTimer == null) {
				thunderTimer = new FlxTimer();

				thunderTimer.start(1.5, function(_:FlxTimer) {
					thunderTimer = null;

					if (nightMode && FlxG.random.bool(5)) {
						callThunder();
						thunderCooldown = 2.0;
					}
				});
			}
		}

		if (rainShader != null && bg != null) {
			rainShader.update(elapsed);

			rainShader.updateViewInfo(FlxG.width, FlxG.height, PlayState.camGame);

			rainShader.updateFrameInfo(bg.frame);
		}
	}

	public function callThunder():Void {
		if (colorShader == null)
			return;

		FlxTween.num(colorShader.brightness, 300, 0.01, {
			ease: FlxEase.expoOut,

			onComplete: function(tween:FlxTween) {
				FlxTween.num(colorShader.brightness, -30, 4.75, {
					ease: FlxEase.cubeOut
				}, function(v:Float) {
					colorShader.brightness = v;
				});
			}
		}, function(v:Float) {
			colorShader.brightness = v;
		});

		HapticUtil.vibrateFor(0, 0.25, 0.25, 150);

		Timer.delay(function() {
			HapticUtil.vibrateFor(0, 0.2, 0.2, 200);
		}, 150);

		FlxG.sound.play('assets/sounds/thunder${FlxG.random.int(1, 4)}.ogg', 1, false);
	}

	public override function startHorde():Void {
		var mm = PlayState.mm;

		if (mm == null)
			return;

		if (!nightMode) {
			ended = false;

			FlxTween.num(colorShader.brightness, -30, 0.75, {
				ease: FlxEase.cubeOut
			}, function(v:Float) {
				colorShader.brightness = v;
			});

			FlxTween.num(colorShader.saturation, -45, 0.75, {
				ease: FlxEase.cubeOut,

				onComplete: function(_:FlxTween) {
					FlxTween.num(rainShader.intensity, 0.01, 0.55, {
						ease: FlxEase.cubeOut
					}, function(v:Float) {
						rainShader.intensity = v;
					});
				}
			}, function(v:Float) {
				colorShader.saturation = v;
			});

			mm.onOrderChanged = function(prev:Int, cur:Int) {
				if (ended)
					return;

				if (prev == 210) {
					FlxTween.num(colorShader.brightness, -30, 0.75, {
						ease: FlxEase.cubeOut
					}, function(v:Float) {
						colorShader.brightness = v;
					});

					FlxTween.num(colorShader.saturation, -45, 0.75, {
						ease: FlxEase.cubeOut,

						onComplete: function(_:FlxTween) {
							FlxTween.num(rainShader.intensity, 0.01, 0.55, {
								ease: FlxEase.cubeOut
							}, function(v:Float) {
								rainShader.intensity = v;
							});
						}
					}, function(v:Float) {
						colorShader.saturation = v;
					});
				}

				switch (cur) {
					case 193:
						FlxTween.num(rainShader.intensity, 0.03, 0.35, {
							ease: FlxEase.cubeOut
						}, function(v:Float) {
							rainShader.intensity = v;
						});

					case 197:
						FlxTween.num(rainShader.intensity, 0.01, 0.018, {
							ease: FlxEase.cubeOut
						}, function(v:Float) {
							rainShader.intensity = v;
						});

					case 200:
						FlxTween.num(colorShader.brightness, -10, 0.75, {
							ease: FlxEase.cubeOut
						}, function(v:Float) {
							colorShader.brightness = v;
						});

						FlxTween.num(colorShader.saturation, -10, 0.75, {
							ease: FlxEase.cubeOut
						}, function(v:Float) {
							colorShader.saturation = v;
						});

					case 201:
						FlxTween.num(colorShader.brightness, -30, 0.75, {
							ease: FlxEase.cubeOut
						}, function(v:Float) {
							colorShader.brightness = v;
						});

						FlxTween.num(colorShader.saturation, -45, 0.75, {
							ease: FlxEase.cubeOut
						}, function(v:Float) {
							colorShader.saturation = v;
						});

					case 202:
						FlxTween.num(colorShader.brightness, -10, 0.75, {
							ease: FlxEase.cubeOut
						}, function(v:Float) {
							colorShader.brightness = v;
						});

						FlxTween.num(colorShader.saturation, -15, 0.75, {
							ease: FlxEase.cubeOut
						}, function(v:Float) {
							colorShader.saturation = v;
						});

						FlxTween.num(rainShader.intensity, 0.001, 0.018, {
							ease: FlxEase.cubeOut
						}, function(v:Float) {
							rainShader.intensity = v;
						});

					case 203:
						FlxTween.num(colorShader.brightness, -30, 0.75, {
							ease: FlxEase.cubeOut
						}, function(v:Float) {
							colorShader.brightness = v;
						});

						FlxTween.num(colorShader.saturation, -45, 0.75, {
							ease: FlxEase.cubeOut
						}, function(v:Float) {
							colorShader.saturation = v;
						});

						FlxTween.num(rainShader.intensity, 0.01, 0.018, {
							ease: FlxEase.cubeOut
						}, function(v:Float) {
							rainShader.intensity = v;
						});

					case 210:
						FlxTween.num(colorShader.brightness, -10, 0.75, {
							ease: FlxEase.cubeOut
						}, function(v:Float) {
							colorShader.brightness = v;
						});

						FlxTween.num(colorShader.saturation, -15, 0.75, {
							ease: FlxEase.cubeOut
						}, function(v:Float) {
							colorShader.saturation = v;
						});

						FlxTween.num(rainShader.intensity, 0.001, 0.018, {
							ease: FlxEase.cubeOut
						}, function(v:Float) {
							rainShader.intensity = v;
						});
				}
			};
		} else {
			mm.onOrderChanged = function(prev:Int, cur:Int) {
				switch (cur) {
					case 162:
						FlxTween.num(rainShader.intensity, 0.0001, 0.35, {
							ease: FlxEase.cubeOut
						}, function(v:Float) {
							rainShader.intensity = v;
						});

						if (mist1 != null) {
							FlxTween.tween(mist1, {alpha: 0.25}, 0.35, {
								ease: FlxEase.expoOut
							});
						}

					case 164:
						FlxTween.num(rainShader.intensity, 0.04, 0.5, {
							ease: FlxEase.cubeOut
						}, function(v:Float) {
							rainShader.intensity = v;
						});

						if (mist1 != null) {
							FlxTween.tween(mist1, {alpha: 1}, 0.4, {
								ease: FlxEase.expoOut
							});
						}
				}
			};
		}
	}

	public override function endHorde():Void {
		if (thunderTimer != null) {
			thunderTimer.cancel();
			thunderTimer = null;
		}

		thunderCooldown = 0;

		super.endHorde();

		ended = true;

		FlxTween.num(colorShader.brightness, 0, 0.75, {
			ease: FlxEase.cubeOut
		}, function(v:Float) {
			colorShader.brightness = v;
		});

		FlxTween.num(colorShader.saturation, 0, 0.75, {
			ease: FlxEase.cubeOut,

			onComplete: function(_:FlxTween) {
				FlxTween.num(rainShader.intensity, 0, 0.55, {
					ease: FlxEase.cubeOut
				}, function(v:Float) {
					rainShader.intensity = v;
				});
			}
		}, function(v:Float) {
			colorShader.saturation = v;
		});
	}

	override public function destroy():Void {
		if (thunderTimer != null) {
			thunderTimer.cancel();
			thunderTimer = null;
		}

		thunderCooldown = 0;

		if (rainShader != null)
			rainShader.intensity = 0;

		if (PlayState.camHUD != null)
			PlayState.camHUD.filters = [];

		super.destroy();
	}
}
