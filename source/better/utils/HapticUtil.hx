package better.utils;

#if (android || ios)
import extension.haptics.Haptic;
#end
import haxe.Timer;

#if (cpp && windows)
@:cppFileCode('
#include <windows.h>
#include <xinput.h>
#pragma comment(lib, "xinput.lib")
')
#end

class HapticUtil {
    private static var _initialized:Bool = false;
    private static var activeTimers:Map<Int, Timer> = new Map<Int, Timer>();

    public static function init():Void {
        if (_initialized) return;
        _initialized = true;

        #if (android || ios)
        try {
            Haptic.initialize();
        } catch (e:Dynamic) {}
        #end
    }

    private static inline function floatToWord(val:Float):Int {
        if (val <= 0.0) return 0;
        if (val >= 1.0) return 65535;
        return Std.int(val * 65535.0);
    }

    public static function vibrate(userIndex:Int = 0, leftMotor:Float = 0.0, rightMotor:Float = 0.0):Void {
        init();
        stopTimedVibration(userIndex);

        #if (android || ios)
        var intensity:Float = (leftMotor + rightMotor) / 2.0;
        Haptic.vibrateOneShot(0.01, intensity, 0.5);
        #elseif (cpp && windows)
        setRawVibration(userIndex, floatToWord(leftMotor), floatToWord(rightMotor));
        #end
    }

    public static function vibrateFor(userIndex:Int = 0, leftMotor:Float = 0.0, rightMotor:Float = 0.0, durationMs:Int = 200):Void {
        init();
        stopTimedVibration(userIndex);

        #if (android || ios)
        var durationSec:Float = durationMs / 1000.0;
        var intensity:Float = (leftMotor + rightMotor) / 2.0;
        Haptic.vibrateOneShot(durationSec, intensity, 0.5);
        #elseif (cpp && windows)
        setRawVibration(userIndex, floatToWord(leftMotor), floatToWord(rightMotor));

        var timer = new Timer(durationMs);
        timer.run = function() {
            setRawVibration(userIndex, 0, 0);
            timer.stop();
            activeTimers.remove(userIndex);
        };
        activeTimers.set(userIndex, timer);
        #end
    }

    public static function vibratePattern(durations:Array<Float>, amplitudes:Array<Float>):Void {
        init();

        #if (android || ios)
        var sharpnesses = amplitudes.map(function(_) return 0.5);
        Haptic.vibratePattern(durations, amplitudes, sharpnesses);
        #elseif (cpp && windows)
        var totalDelay:Float = 0;
        for (i in 0...durations.length) {
            var durMs = Std.int(durations[i] * 1000.0);
            var amp = (i < amplitudes.length) ? amplitudes[i] : 1.0;
            
            Timer.delay(function() {
                vibrateFor(0, amp, amp, durMs);
            }, Std.int(totalDelay));

            totalDelay += durMs;
        }
        #end
    }

    public static function stopVibration(userIndex:Int = 0):Void {
        stopTimedVibration(userIndex);

        #if (android || ios)
        Haptic.dispose();
        _initialized = false;
        #elseif (cpp && windows)
        setRawVibration(userIndex, 0, 0);
        #end
    }

    public static function stopAll():Void {
        #if (android || ios)
        Haptic.dispose();
        _initialized = false;
        #elseif (cpp && windows)
        for (i in 0...4) {
            stopVibration(i);
        }
        #end
    }

    private static function stopTimedVibration(userIndex:Int):Void {
        if (activeTimers.exists(userIndex)) {
            var timer = activeTimers.get(userIndex);
            if (timer != null) timer.stop();
            activeTimers.remove(userIndex);
        }
    }

    private static function setRawVibration(userIndex:Int, leftRaw:Int, rightRaw:Int):Void {
        #if (cpp && windows)
        untyped __cpp__('
            XINPUT_VIBRATION vibration;
            ZeroMemory(&vibration, sizeof(XINPUT_VIBRATION));
            vibration.wLeftMotorSpeed = (WORD){0};
            vibration.wRightMotorSpeed = (WORD){1};
            XInputSetState((DWORD){2}, &vibration);
        ', leftRaw, rightRaw, userIndex);
        #end
    }
}