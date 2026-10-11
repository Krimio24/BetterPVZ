package better.shop;

import better.animate.arrow.ArrowAnimation;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;

class ShopItem extends FlxSpriteGroup {
	public var itemIcon:FlxSprite;
	public var seedPacket:ArrowAnimation;
	public var priceTag:FlxSprite;
	public var priceText:FlxText;
	public var soldOutText:FlxText;

	public var id:String;
	public var itemName:String;
	public var price:Int;
	public var isSoldOut:Bool = false;
	public var description:String;
	public var isSeed:Bool;

	private final FONT_BRIANNE:String = "briane";
	public static var PACKET_SPRITESHEET:String = "assets/images/packet_plants.png";

	public function new(x:Float, y:Float, data:Dynamic, isPurchased:Bool = false) {
		super(x, y);

		this.id = data.id != null ? data.id : "";
		this.price = data.price != null ? data.price : 0;
		this.description = data.desc != null ? data.desc : "";
		this.itemName = data.name != null ? data.name : "";
		this.isSeed = data.isSeed != null ? data.isSeed : false;
		this.isSoldOut = isPurchased;

		var itemWidth:Float = 50;
		var itemHeight:Float = 50;

		// 1. Renderizado y Centrado del Objeto
		if (isSeed) {
			var seedId:Int = data.seedId != null ? data.seedId : 0;
			itemWidth = data.width != null ? data.width : 50;
			itemHeight = data.height != null ? data.height : 70;
			var sheetPath:String = data.spriteSheet != null ? data.spriteSheet : PACKET_SPRITESHEET;

			seedPacket = new ArrowAnimation(sheetPath, Std.int(itemWidth), Std.int(itemHeight), seedId);
			seedPacket.setPosition(0, 0);
			add(seedPacket);
		} else {
			itemIcon = new FlxSprite(0, 0);
			try {
				itemIcon.loadGraphic(data.icon);
			} catch (e:Dynamic) {
				itemIcon.makeGraphic(50, 50, 0xFFFF00FF);
			}
			itemIcon.setGraphicSize(50, 50);
			itemIcon.updateHitbox();
			// Centramos el icono normal horizontalmente con respecto a las cartas
			itemIcon.x = (50 - itemIcon.width) / 2;
			add(itemIcon);
		}

		// 2. Etiqueta de Precio Centrada
		var tagY:Float = itemHeight + 2; // Posicionar justo debajo del sprite
		
		priceTag = new FlxSprite(0, tagY);
		try {
			priceTag.loadGraphic("assets/images/Store_PriceTag.png");
		} catch (e:Dynamic) {
			priceTag.makeGraphic(55, 18, 0xFFFFFF99);
		}
		
		// Centrar la etiqueta con respecto al ítem
		priceTag.x = (itemWidth - priceTag.width) / 2;
		add(priceTag);

		// 3. Texto del Precio
		priceText = new FlxText(priceTag.x, tagY + 1, priceTag.width, "$" + price);
		priceText.setFormat(FONT_BRIANNE, 14, 0xFF000000, CENTER, NONE);
		add(priceText);

		// 4. Texto AGOTADO
		soldOutText = new FlxText(0, itemHeight * 0.3, itemWidth, "Agot.");
		soldOutText.setFormat(FONT_BRIANNE, 16, 0xFFFF2222, CENTER, NONE);
		soldOutText.visible = isSoldOut;
		add(soldOutText);
	}

	public function markAsPurchased():Void {
		isSoldOut = true;
		soldOutText.visible = true;
	}
}