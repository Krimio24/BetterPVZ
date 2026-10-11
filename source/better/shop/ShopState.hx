package better.shop;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

enum BGType {
	NIGHT;
	DAY;
}

class ShopState extends FlxState {
	public var bg:FlxSprite;
	public var bgtype:BGType = DAY;
	public var car:FlxSprite;
	public var carDoor:FlxSprite;
	public var carNightDoor:FlxSprite;
	public var doorOpen:FlxSprite;
	public var sign:FlxSprite;
	public var speechBubble:FlxSprite;
	public var speechText:FlxText;
	public var opened:Bool = false;

	public var page:Int = 1;
	public var maxPages:Int = 4;

	public var itemsGroup:FlxTypedGroup<ShopItem>;

	private final FONT_BRIANNE:String = "briane";

	public var purchasedItems:Array<String> = [];

	// Medidas de recorte predeterminadas
	public var packetWidth:Int = 50;
	public var packetHeight:Int = 70;

	public var page1Items:Array<Dynamic> = [
		{ id: "slot_9", icon: "assets/images/Store_PacketUpgrade.png", price: 80000, isSeed: false, desc: "Aumenta el espacio de semillas a 9", name: "Ranura Extra" },
		{ id: "gatling_pea", isSeed: true, seedId: 40, width: 50, height: 70, price: 5000, desc: "Dispara cuatro guisantes a la vez", name: "Guisantralladora" },
		{ id: "twin_sunflower", isSeed: true, seedId: 41, width: 50, height: 70, price: 5000, desc: "Produce el doble de sol", name: "Girasol Doble" },
		{ id: "gloom_shroom", isSeed: true, seedId: 42, width: 50, height: 70, price: 7500, desc: "Ataca en un área pequeña alrededor", name: "Gasoseta" },
		{ id: "cattail", isSeed: true, seedId: 43, width: 50, height: 70, price: 10000, desc: "Dispara esporas teledirigidas", name: "Rabo de Gato" }
	];

	public var page2Items:Array<Dynamic> = [
		{ id: "spikerock", isSeed: true, seedId: 44, width: 50, height: 70, price: 7500, desc: "Pinchoroca ultra resistente", name: "Pinchoroca" },
		{ id: "cob_cannon", isSeed: true, seedId: 45, width: 50, height: 70, price: 3000, desc: "Lanza mazorcas explosivas", name: "Mazorcañón" },
		{ id: "gold_magnet", isSeed: true, seedId: 46, width: 50, height: 70, price: 10000, desc: "Atrae monedas cercanas", name: "Imán Dorado" },
		{ id: "winter_melon", isSeed: true, seedId: 47, width: 50, height: 70, price: 20000, desc: "Lanza melones que ralentizan", name: "Melonpulta Congelada" }
	];

	public var page3Items:Array<Dynamic> = [
		{ id: "gold_can", icon: "assets/reanim/ZenGarden_wateringcan4_gold.png", price: 10000, isSeed: false, desc: "Riega varias plantas a la vez", name: "Regadera Dorada" },
		{ id: "bug_spray", icon: "assets/reanim/ZenGarden_bugspray_bottle.png", price: 1000, isSeed: false, desc: "Fumiga tus plantas en el Jardín Zen", name: "Insecticida" }
	];

	public var page4Items:Array<Dynamic> = [
		{ id: "mushroom_garden", icon: "assets/images/Store_MushroomGardenIcon.png", price: 30000, isSeed: false, desc: "Jardín para setas nocturnas", name: "Jardín de Setas" },
		{ id: "aquarium_garden", icon: "assets/images/Store_AquariumGardenIcon.png", price: 30000, isSeed: false, desc: "Jardín acuático para plantas marinas", name: "Acuario" },
		{ id: "tree_wisdom", icon: "assets/images/Store_TreeOfWisdomIcon.png", price: 10000, isSeed: false, desc: "Da consejos útiles sobre el juego", name: "Árbol de la Sabiduría" },
		{ id: "tree_food", icon: "assets/reanim/TreeFood.png", price: 2500, isSeed: false, desc: "Alimento para hacer crecer el Árbol", name: "Comida para Árbol" }
	];

	public function new() {
		super();
	}

	override public function create():Void {
		super.create();

		bg = new FlxSprite(0, 0);
		car = new FlxSprite(0, 0);
		carDoor = new FlxSprite(0, 0);
		carNightDoor = new FlxSprite(0, 0);
		doorOpen = new FlxSprite(0, 0);
		sign = new FlxSprite(0, 0);
		speechBubble = new FlxSprite(0, 0);

		itemsGroup = new FlxTypedGroup<ShopItem>();

		loadGraphicSafe(sign, "assets/images/Store_Sign.png");
		loadGraphicSafe(carDoor, "assets/images/Store_CarClosed.png");
		loadGraphicSafe(doorOpen, "assets/images/Store_HatchbackOpen.png");
		loadGraphicSafe(speechBubble, "assets/images/Store_SpeechBubble.png");

		doorOpen.visible = false;

		setupBackground();

		bg.scale.set(1.2, 1.2);
		bg.screenCenter();

		car.scale.set(1.2, 1.2);
		car.screenCenter();
		car.x = bg.x + 350;
		car.y = bg.y + 160;

		carDoor.scale.set(1.2, 1.2);
		carDoor.setPosition(car.x, car.y);

		carNightDoor.scale.set(1.2, 1.2);
		carNightDoor.setPosition(car.x, car.y);

		doorOpen.setPosition(car.x + 90, car.y - 200);
		sign.setPosition(doorOpen.x, doorOpen.y - 400);

		speechBubble.setPosition(car.x - 280, car.y - 80);
		speechText = new FlxText(speechBubble.x + 25, speechBubble.y + 20, 200, "¡Bienvenido a la tienda de Dave!");
		speechText.setFormat(FONT_BRIANNE, 16, 0xFF000000, CENTER, NONE);

		add(bg);
		add(car);
		add(carDoor);
		add(carNightDoor);
		add(doorOpen);
		add(sign);
		add(speechBubble);
		add(speechText);

		add(itemsGroup);

		FlxTween.tween(sign, {y: sign.y + 400}, 0.4, {ease: FlxEase.quadOut});
	}

	private function setupBackground():Void {
		switch (bgtype) {
			case DAY:
				loadGraphicSafe(bg, "assets/images/Store_Background.png");
				loadGraphicSafe(car, "assets/images/Store_Car.png");
				carNightDoor.visible = false;
			case NIGHT:
				loadGraphicSafe(bg, "assets/images/Store_BackgroundNight.png");
				loadGraphicSafe(car, "assets/images/Store_Car_night.png");
				loadGraphicSafe(carNightDoor, "assets/images/Store_CarClosed_night.png");
				carNightDoor.visible = true;
		}
	}

	private function loadGraphicSafe(sprite:FlxSprite, path:String):Void {
		try {
			sprite.loadGraphic(path);
		} catch (e:Dynamic) {
			sprite.makeGraphic(64, 64, 0xFFFF00FF);
		}
	}

	public function setFirstOpen():Void {
		opened = true;
		carDoor.alpha = 0;
		doorOpen.visible = true;
		carNightDoor.alpha = 0;
		updatePage();
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if ((FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) && !opened) {
			setFirstOpen();
		}

		if (opened) {
			if (FlxG.keys.justPressed.RIGHT) {
				changePage(1);
			} else if (FlxG.keys.justPressed.LEFT) {
				changePage(-1);
			}
		}
	}

	public function changePage(dir:Int = 1):Void {
		page += dir;
		if (page > maxPages) page = 1;
		if (page < 1) page = maxPages;
		updatePage();
	}

	public function buyItem(item:ShopItem):Void {
		if (item.isSoldOut) return;

		purchasedItems.push(item.id);
		item.markAsPurchased();
	}

	public function updatePage():Void {
		itemsGroup.clear();

		if (!opened) return;

		var rawItems:Array<Dynamic> = switch (page) {
			case 1: page1Items;
			case 2: page2Items;
			case 3: page3Items;
			case 4: page4Items;
			default: [];
		};

		var startX = doorOpen.x + 130;
		var startY = doorOpen.y + 175;
		var spaceX = 95;
		var spaceY = 90;

		for (i in 0...rawItems.length) {
			var col = i % 4;
			var row = Math.floor(i / 4);

			var itemX = startX + (col * spaceX);
			var itemY = startY + (row * spaceY);

			var data = rawItems[i];
			var isBought = purchasedItems.contains(data.id);

			var item = new ShopItem(itemX, itemY, data, isBought);
			itemsGroup.add(item);
		}
	}
}