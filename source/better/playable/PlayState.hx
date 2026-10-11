package better.playable;

import better.animate.reanim.ReanimXmlParser;
import better.animate.reanim.Reanim.ReanimatorDefinition;
import better.animate.reanim.Reanim.Reanimation;
import better.playable.pause.Pause;
import better.playable.music.MusicMechanic;
import better.playable.lawn.Lawn;
import better.playable.seed.SeedBank;
import better.playable.lawn._default.Roof;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxCamera;

typedef PlayStateParams = {
	var lawnID:String;
	var level:String;
	var seeds:Array<String>;
	var generation:Array<String>;
	var generationIntensity:Array<Float>;
}

@:build(better.playable.lawn.LawnMacro.rewriteFactory())
class PlayState extends FlxState {
	public var blover:Reanimation;

	public var flagscom:Int = 0;
	public var flags:Int = 1;

	public static var changed:Bool = false;
	public static var lawn:Lawn;

	public static var camHUD:FlxCamera;
	public static var camGame:FlxCamera;

	public var params:PlayStateParams;

	var seedsBank:SeedBank;

	public static var mm:MusicMechanic;

	public static var isHorde:Bool = false;

	public function new(params:PlayStateParams) {
		super();
		this.params = params;
	}

	override public function create():Void {
		super.create();

		// Cámaras.
		camGame = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);

		camHUD = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);

		FlxG.cameras.add(camGame, true);
		FlxG.cameras.add(camHUD, true);

		// Evitar que otra música de Flixel interfiera.
		if (FlxG.sound.music != null) {
			FlxG.sound.music.stop();
			FlxG.sound.music = null;
		}

		// Crear el escenario.
		lawn = new Lawn(params.lawnID);

		if (lawn != null) {
			if (params.lawnID == "roof")
				lawn.buildLawn();

			lawn.screenCenter();
			lawn.y += 180;
			lawn.x += 20;

			add(lawn);
		}

		// Banco de semillas.
		seedsBank = new SeedBank(params.seeds != null ? params.seeds : ["peashooter", "sunflower"]);

		seedsBank.createSeeds();
		seedsBank.screenCenter();
		seedsBank.y -= 285;
		seedsBank.x -= 220;
		seedsBank.camera = camHUD;

		// Animación Reanim de Blover.
		blover = new Reanimation(0, 0);
		blover.camera = camGame;

		var animDef:ReanimatorDefinition = ReanimXmlParser.parse("assets/compiled/xml/Blover.xml", [
			{
				id: "IMAGE_REANIM_BLOVER_DIRT_BACK",
				path: "Blover_dirt_back.png"
			},
			{
				id: "IMAGE_REANIM_BLOVER_STEM1",
				path: "Blover_stem1.png"
			},
			{
				id: "IMAGE_REANIM_BLOVER_STEM2",
				path: "Blover_stem2.png"
			},
			{
				id: "IMAGE_REANIM_BLOVER_DIRT_FRONT",
				path: "Blover_dirt_front.png"
			},
			{
				id: "IMAGE_REANIM_BLOVER_HEAD",
				path: "Blover_head.png"
			},
			{
				id: "IMAGE_REANIM_BLOVER_HEAD2",
				path: "Blover_head2.png"
			},
			{
				id: "IMAGE_REANIM_BLOVER_PETAL",
				path: "Blover_petal.png"
			},
			{
				id: "IMAGE_REANIM_BLOVER_PETAL_BLUR",
				path: "Blover_petal_blur.png"
			},
			{
				id: "IMAGE_REANIM_BLOVER_BLURRED_PETAL",
				path: "blover_blurred_petal.png"
			}
		]);

		blover.reanimationInitialize(0, 0, animDef);

		blover.x = (FlxG.width - blover.width) / 2;
		blover.y = (FlxG.height - blover.height) / 2;

		blover.playReanim("anim_idle", REANIM_LOOP, 0, 12.0);
		blover.visible = true;
		blover.alpha = 1.0;

		mm = new MusicMechanic("assets/music/mainmusic.mo3", 184, [19, 20, 21, 22]);
		
		add(blover);
		add(seedsBank);

		// Configurar la música al entrar al nivel.
		initSound();
	}

	override public function update(delta:Float):Void {
		// Activar Horde.
		if (FlxG.keys.justPressed.A)
			setHorde(true);

		// Desactivar Horde.
		if (FlxG.keys.justPressed.K)
			setHorde(false);

		// Abrir pausa.
		if (FlxG.keys.justPressed.P)
			openSubState(new Pause());

		if (seedsBank != null)
			seedsBank._update(delta);

		// Actualizar el reproductor de música.
		if (mm != null)
			mm.update();

		// Cambiar la velocidad de reproducción.
		if (FlxG.keys.justPressed.B && mm != null)
			mm.bassManager.setMo3TicksPerRow(4);

		if (FlxG.keys.justPressed.Y && mm != null)
			mm.bassManager.setMo3TicksPerRow(2);

		super.update(delta);
	}

	public function initSound():Void {
		var order:Int = 0;
		var muteChannels:Array<Int> = [];
		if (mm == null || mm.bassManager == null)
			return;

		if (params.lawnID == "roof") {
			if (Roof.nightMode) {
				order = 154;
			} else {
				order = 154;
				muteChannels = [19, 20, 21, 22];
			}
		}
	}

	public function setHorde(s:Bool):Void {
		if (mm == null || mm.bassManager == null)
			return;

		isHorde = s;

		switch (params.lawnID) {
			case "grass", "roof":
				if (!Roof.nightMode) {
					if (s) {
						for (channel in [19, 20, 21, 22]) {
							FlxTween.num(0, 1, 0.45, {ease: FlxEase.cubeOut}, function(v:Float) {
								mm.bassManager.setMo3ChannelVolume(channel, v);
							});
						}

						if (lawn != null)
							lawn.startHorde();
					} else {
						if (lawn != null)
							lawn.endHorde();

						for (channel in [19, 20, 21, 22]) {
							FlxTween.num(1, 0, 0.45, {ease: FlxEase.cubeOut}, function(v:Float) {
								mm.bassManager.setMo3ChannelVolume(channel, v);
							});
						}
					}
				} else {
					// Orden de música Horde en el modo nocturno.
					mm.bassManager.setMo3Order(158);
				}

			default:
		}
	}

	override public function destroy():Void {
		if (seedsBank != null)
			seedsBank.active = true;

		super.destroy();
	}
}
