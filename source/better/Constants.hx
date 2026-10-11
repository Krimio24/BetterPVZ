package better;

class Constants {

    public static var money:Float;

    public static var sun:Int = 50;

    public static function chargeMoney(value:Float) {
        if (money != 0) money - value;
        else trace("The Player dont have money");
    }
    public static function giveMoney(value:Float) {
        money + value;
    }
}