package better.playable.music;

class MusicMechanic {
    public var bassManager(default, null):Bass;
    public var onOrderChanged:Int->Int->Void;
    public var mutedChannels:Array<Int>;
    var lastOrder:Int = -1;

    public function new(?path:String = "assets/music/mainmusic.mo3", ?order:Int = 184, ?mutedChannels:Array<Int>) {
        bassManager = new Bass();
        if (bassManager.loadMo3(path, false, true)) {
            if (mutedChannels != null) {
                this.mutedChannels = mutedChannels;
                for (channel in mutedChannels)
                    bassManager.setMo3ChannelVolume(channel, 0);
            }
            if (!bassManager.playMo3Order(order))
                trace('Could not start MO3 order $order in "$path".');
        }
        lastOrder = bassManager.getCurrentMo3Order();
    }

    public function update():Void {
        var currentOrder = bassManager.getCurrentMo3Order();
        if (currentOrder < 0 || currentOrder == lastOrder) return;

        var previousOrder = lastOrder;
        lastOrder = currentOrder;
        if (onOrderChanged != null) onOrderChanged(previousOrder, currentOrder);
    }

    public function changePattern(order:Int):Bool {
        return bassManager.playMo3Order(order);
    }

    public function nextPattern():Bool {
        var orderCount = bassManager.getMo3OrderCount();
        if (orderCount <= 0) return false;

        var next = (bassManager.getCurrentMo3Order() + 1) % orderCount;
        return changePattern(next);
    }

    public function previousPattern():Bool {
        var orderCount = bassManager.getMo3OrderCount();
        if (orderCount <= 0) return false;

        var current = bassManager.getCurrentMo3Order();
        var previous = current <= 0 ? orderCount - 1 : current - 1;
        return changePattern(previous);
    }

    public function loadMo3File(path:String, ?order:Int = 0):Bool {
        return bassManager.loadMo3(path, false, true) && bassManager.playMo3Order(order);
    }

    public function dispose():Void {
        bassManager.disposeMo3();
    }
}
