package better.playable.lawn;

import Type;

class LawnRegistry {
    private static var registry:Map<String, Class<Lawn>> = new Map();

    public static function register(id:String, lawnClass:Class<Lawn>):Class<Lawn> {
        registry.set(id.toLowerCase(), lawnClass);
        return lawnClass;
    }

    public static function create(id:String, ?args:Array<Dynamic>):Lawn {
        id = id.toLowerCase();
        if (!registry.exists(id)) {
            trace("LawnRegistry: No existe ningún Lawn con el ID '" + id + "'");
            return null;
        }

        var lawnClass:Class<Lawn> = registry.get(id);
        if (args == null) args = [];

        return Type.createInstance(lawnClass, args);
    }

    public static function exists(id:String):Bool {
        return registry.exists(id.toLowerCase());
    }
}