package better.playable.music;

import lime.utils.Assets;
import haxe.Exception;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.sound.FlxSound;

#if (cpp && (windows || android))
@:cppFileCode('

#if defined(_WIN32)

#include <windows.h>

#include <string>

#define BETTER_BASS_CALL WINAPI

typedef HMODULE BetterBassModule;

#else

#include <dlfcn.h>

#include <stdint.h>

#define BETTER_BASS_CALL

typedef void* BetterBassModule;

typedef uint32_t DWORD;

typedef int BOOL;

typedef void* HWND;

#define ERROR_MOD_NOT_FOUND 126

#define ERROR_PROC_NOT_FOUND 127

#endif

typedef DWORD (BETTER_BASS_CALL *BetterBassInitFn)(int, DWORD, DWORD, HWND, const void*);

typedef DWORD (BETTER_BASS_CALL *BetterBassMusicLoadFn)(DWORD, void*, unsigned long long, DWORD, DWORD, DWORD);

typedef DWORD (BETTER_BASS_CALL *BetterBassChannelPlayFn)(DWORD, BOOL);

typedef DWORD (BETTER_BASS_CALL *BetterBassChannelStopFn)(DWORD);

typedef DWORD (BETTER_BASS_CALL *BetterBassMusicFreeFn)(DWORD);

typedef DWORD (BETTER_BASS_CALL *BetterBassChannelSetAttributeFn)(DWORD, DWORD, float);

typedef DWORD (BETTER_BASS_CALL *BetterBassChannelGetAttributeFn)(DWORD, DWORD, float*);

typedef DWORD (BETTER_BASS_CALL *BetterBassChannelSetPositionFn)(DWORD, unsigned long long, DWORD);

typedef unsigned long long (BETTER_BASS_CALL *BetterBassChannelGetPositionFn)(DWORD, DWORD);

typedef unsigned long long (BETTER_BASS_CALL *BetterBassChannelGetLengthFn)(DWORD, DWORD);

typedef DWORD (BETTER_BASS_CALL *BetterBassErrorGetCodeFn)();

static const DWORD BETTER_BASS_ATTRIB_BUFFER = 13;

static const DWORD BETTER_BASS_ATTRIB_MUSIC_PSCALER = 0x102;

static const DWORD BETTER_BASS_ATTRIB_MUSIC_BPM = 0x103;

static const DWORD BETTER_BASS_ATTRIB_MUSIC_SPEED = 0x104;

static const DWORD BETTER_BASS_ATTRIB_MUSIC_VOL_CHAN = 0x200;

static const DWORD BETTER_BASS_POS_MUSIC_ORDER = 1;

static const int BETTER_BASS_MUSIC_POSITION_SCALER = 256;

static BetterBassModule betterBassModule = NULL;

static bool betterBassInitialized = false;

static DWORD betterBassLoadError = ERROR_MOD_NOT_FOUND;

static BetterBassInitFn betterBassInitFn = NULL;

static BetterBassMusicLoadFn betterBassMusicLoadFn = NULL;

static BetterBassChannelPlayFn betterBassChannelPlayFn = NULL;

static BetterBassChannelStopFn betterBassChannelStopFn = NULL;

static BetterBassMusicFreeFn betterBassMusicFreeFn = NULL;

static BetterBassChannelSetAttributeFn betterBassChannelSetAttributeFn = NULL;

static BetterBassChannelGetAttributeFn betterBassChannelGetAttributeFn = NULL;

static BetterBassChannelSetPositionFn betterBassChannelSetPositionFn = NULL;

static BetterBassChannelGetPositionFn betterBassChannelGetPositionFn = NULL;

static BetterBassChannelGetLengthFn betterBassChannelGetLengthFn = NULL;

static BetterBassErrorGetCodeFn betterBassErrorGetCodeFn = NULL;

static void* betterBassGetProc(const char* name) {

#if defined(_WIN32)

    return (void*)GetProcAddress(betterBassModule, name);

#else

    return dlsym(betterBassModule, name);

#endif

}

static bool betterBassEnsureLoaded() {

    if (betterBassModule == NULL) {

#if defined(_WIN32)

        betterBassModule = LoadLibraryA("bass.dll");

        if (betterBassModule == NULL) {

            betterBassLoadError = GetLastError();

            return false;

        }

#else

        betterBassModule = dlopen("libbass.so", RTLD_NOW | RTLD_LOCAL);

        if (betterBassModule == NULL) {

            betterBassLoadError = ERROR_MOD_NOT_FOUND;

            return false;

        }

#endif

    }

    betterBassInitFn = (BetterBassInitFn)betterBassGetProc("BASS_Init");

    betterBassMusicLoadFn = (BetterBassMusicLoadFn)betterBassGetProc("BASS_MusicLoad");

    betterBassChannelPlayFn = (BetterBassChannelPlayFn)betterBassGetProc("BASS_ChannelPlay");

    betterBassChannelStopFn = (BetterBassChannelStopFn)betterBassGetProc("BASS_ChannelStop");

    betterBassMusicFreeFn = (BetterBassMusicFreeFn)betterBassGetProc("BASS_MusicFree");

    betterBassChannelSetAttributeFn = (BetterBassChannelSetAttributeFn)betterBassGetProc("BASS_ChannelSetAttribute");

    betterBassChannelGetAttributeFn = (BetterBassChannelGetAttributeFn)betterBassGetProc("BASS_ChannelGetAttribute");

    betterBassChannelSetPositionFn = (BetterBassChannelSetPositionFn)betterBassGetProc("BASS_ChannelSetPosition");

    betterBassChannelGetPositionFn = (BetterBassChannelGetPositionFn)betterBassGetProc("BASS_ChannelGetPosition");

    betterBassChannelGetLengthFn = (BetterBassChannelGetLengthFn)betterBassGetProc("BASS_ChannelGetLength");

    betterBassErrorGetCodeFn = (BetterBassErrorGetCodeFn)betterBassGetProc("BASS_ErrorGetCode");

    bool available = betterBassInitFn != NULL && betterBassMusicLoadFn != NULL

        && betterBassChannelPlayFn != NULL && betterBassChannelStopFn != NULL

        && betterBassMusicFreeFn != NULL && betterBassChannelSetAttributeFn != NULL

        && betterBassChannelGetAttributeFn != NULL && betterBassChannelSetPositionFn != NULL

        && betterBassChannelGetPositionFn != NULL && betterBassChannelGetLengthFn != NULL

        && betterBassErrorGetCodeFn != NULL;

    if (!available) betterBassLoadError = ERROR_PROC_NOT_FOUND;

    return available;

}

static bool betterBassInit() {

    if (!betterBassEnsureLoaded()) return false;

    if (betterBassInitialized) return true;

    betterBassInitialized = betterBassInitFn(-1, 44100, 0, NULL, NULL) != 0;

    return betterBassInitialized;

}

static DWORD betterBassLoadMo3(const char* path, bool loop) {

#if defined(_WIN32)

    if (!betterBassInitialized || path == NULL) return 0;

    int wideLength = MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, path, -1, NULL, 0);

    if (wideLength <= 0) return 0;

    std::wstring widePath(wideLength, L\'\\0\');

    if (MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, path, -1, &widePath[0], wideLength) <= 0) return 0;

    DWORD flags = 0x80000000 | 0x20000 | (loop ? 4 : 0);

    return betterBassMusicLoadFn(0, (void*)widePath.c_str(), 0, 0, flags, 0);

#else

    return 0;

#endif

}

static DWORD betterBassLoadMo3Memory(void* data, DWORD length, bool loop) {

    if (!betterBassInitialized || data == NULL || length == 0) return 0;

    DWORD flags = 0x20000 | (loop ? 4 : 0);

    return betterBassMusicLoadFn(1, data, 0, length, flags, 0);

}

static void betterBassConfigureMusic(DWORD handle) {

    if (betterBassChannelSetAttributeFn == NULL) return;

    betterBassChannelSetAttributeFn(handle, BETTER_BASS_ATTRIB_BUFFER, 0.1f);

    betterBassChannelSetAttributeFn(handle, BETTER_BASS_ATTRIB_MUSIC_PSCALER, (float)BETTER_BASS_MUSIC_POSITION_SCALER);

}

static bool betterBassPlay(DWORD handle, bool restart) {

    return betterBassChannelPlayFn != NULL && betterBassChannelPlayFn(handle, restart ? 1 : 0) != 0;

}

static bool betterBassStop(DWORD handle) {

    return betterBassChannelStopFn != NULL && betterBassChannelStopFn(handle) != 0;

}

static bool betterBassFree(DWORD handle) {

    return betterBassMusicFreeFn != NULL && betterBassMusicFreeFn(handle) != 0;

}

static bool betterBassSetChannelVolume(DWORD handle, int channel, float volume) {

    return channel >= 0 && betterBassChannelSetAttributeFn != NULL

        && betterBassChannelSetAttributeFn(handle, BETTER_BASS_ATTRIB_MUSIC_VOL_CHAN + channel, volume) != 0;

}

static bool betterBassGetChannelVolume(DWORD handle, int channel, float* volume) {

    return channel >= 0 && volume != NULL && betterBassChannelGetAttributeFn != NULL

        && betterBassChannelGetAttributeFn(handle, BETTER_BASS_ATTRIB_MUSIC_VOL_CHAN + channel, volume) != 0;

}

static float betterBassGetChannelVolumeValue(DWORD handle, int channel) {

    float volume = -1;

    return betterBassGetChannelVolume(handle, channel, &volume) ? volume : -1;

}

static int betterBassGetChannelCount(DWORD handle) {

    if (betterBassChannelGetAttributeFn == NULL) return 0;

    int count = 0;

    float volume = 0;

    while (count < 256 && betterBassChannelGetAttributeFn(handle, BETTER_BASS_ATTRIB_MUSIC_VOL_CHAN + count, &volume) != 0) count++;

    return count;

}

static bool betterBassGetMusicAttribute(DWORD handle, DWORD attribute, float* value) {

    return value != NULL && betterBassChannelGetAttributeFn != NULL

        && betterBassChannelGetAttributeFn(handle, attribute, value) != 0;

}

static float betterBassGetMusicAttributeValue(DWORD handle, DWORD attribute) {

    float value = -1;

    return betterBassGetMusicAttribute(handle, attribute, &value) ? value : -1;

}

static bool betterBassSetMusicAttribute(DWORD handle, DWORD attribute, float value) {

    return betterBassChannelSetAttributeFn != NULL

        && betterBassChannelSetAttributeFn(handle, attribute, value) != 0;

}

static unsigned long long betterBassGetMo3Position(DWORD handle) {

    return betterBassChannelGetPositionFn == NULL

        ? ~0ULL

        : betterBassChannelGetPositionFn(handle, BETTER_BASS_POS_MUSIC_ORDER);

}

static bool betterBassSetMo3Order(DWORD handle, int order) {

    return order >= 0 && betterBassChannelSetPositionFn != NULL

        && betterBassChannelSetPositionFn(handle, (unsigned long long)order, BETTER_BASS_POS_MUSIC_ORDER) != 0;

}

static int betterBassGetMo3Order(DWORD handle) {

    unsigned long long position = betterBassGetMo3Position(handle);

    return position == ~0ULL ? -1 : (int)(position & 0xffff);

}

static int betterBassGetMo3Row(DWORD handle) {

    unsigned long long position = betterBassGetMo3Position(handle);

    return position == ~0ULL ? -1

        : (int)((position >> 16) & 0xffff) / BETTER_BASS_MUSIC_POSITION_SCALER;

}

static int betterBassGetMo3Tick(DWORD handle) {

    unsigned long long position = betterBassGetMo3Position(handle);

    if (position == ~0ULL) return -1;

    float speed = 0;

    if (!betterBassGetMusicAttribute(handle, BETTER_BASS_ATTRIB_MUSIC_SPEED, &speed) || speed < 1) return -1;

    int scaledRow = (int)((position >> 16) & 0xffff);

    int tick = (scaledRow % BETTER_BASS_MUSIC_POSITION_SCALER) * (int)speed / BETTER_BASS_MUSIC_POSITION_SCALER;

    int ticksPerRow = (int)speed;

    return tick >= ticksPerRow ? ticksPerRow - 1 : tick;

}

static int betterBassGetMo3OrderCount(DWORD handle) {

    if (betterBassChannelGetLengthFn == NULL) return 0;

    unsigned long long length = betterBassChannelGetLengthFn(handle, 1);

    return length == ~0ULL ? 0 : (int)length;

}

static int betterBassGetErrorCode() {

    if (betterBassErrorGetCodeFn != NULL) return (int)betterBassErrorGetCodeFn();

    return (int)betterBassLoadError;

}

')
#end
class Bass {
	#if (cpp && (windows || android))
	private var mo3Handle:Int = 0;
	#end

	private var reportedChannelErrors:Map<Int, Bool> = new Map();

	public function new() {}

	public function loadMo3(path:String, ?autoplay:Bool = true, ?loop:Bool = true):Bool {
		#if (cpp && (windows || android))
		if (!initializeBass()) {
			trace('BASS initialization failed (error ${getBassErrorCode()}).');

			return false;
		}

		#if windows
		var newHandle:Int = untyped __cpp__("betterBassLoadMo3({0}.utf8_str(), {1})", path, loop);
		#else
		var mo3Bytes = Assets.getBytes(path);

		var mo3Data = cpp.Pointer.ofArray(mo3Bytes.getData()).raw;

		var newHandle:Int = untyped __cpp__("betterBassLoadMo3Memory({0}, {1}, {2})", mo3Data, mo3Bytes.length, loop);
		#end

		if (newHandle == 0) {
			trace('BASS could not load MO3 "$path" (error ${getBassErrorCode()}).');

			return false;
		}

		if (mo3Handle != 0) {
			untyped __cpp__("betterBassStop({0})", mo3Handle);

			untyped __cpp__("betterBassFree({0})", mo3Handle);
		}

		mo3Handle = newHandle;

		untyped __cpp__("betterBassConfigureMusic({0})", mo3Handle);

		if (autoplay && !playMo3()) {
			trace('BASS could not start MO3 "$path" (error ${getBassErrorCode()}).');

			disposeMo3();

			return false;
		}

		return true;
		#else
		trace("MO3 playback through BASS is supported only on Windows and Android C++ targets.");

		return false;
		#end
	}

	public function playMo3(?restart:Bool = true):Bool {
		#if (cpp && (windows || android))
		return mo3Handle != 0 && untyped __cpp__("betterBassPlay({0}, {1})", mo3Handle, restart);
		#else
		return false;
		#end
	}

	public function stopMo3():Bool {
		#if (cpp && (windows || android))
		return mo3Handle != 0 && untyped __cpp__("betterBassStop({0})", mo3Handle);
		#else
		return false;
		#end
	}

	/** Sets a zero-based internal tracker channel's volume, from 0 (silent) to 1 (full). */
	public function setMo3ChannelVolume(channel:Int, volume:Float):Bool {
		#if (cpp && (windows || android))
		if (mo3Handle == 0 || channel < 0)
			return false;

		var clampedVolume = Math.max(0, Math.min(1, volume));

		var succeeded:Bool = untyped __cpp__("betterBassSetChannelVolume({0}, {1}, {2})", mo3Handle, channel, clampedVolume);

		if (!succeeded && !reportedChannelErrors.exists(channel)) {
			reportedChannelErrors.set(channel, true);

			trace('BASS could not set MO3 channel $channel volume (channel count: ${getMo3ChannelCount()}, error ${getBassErrorCode()}). Channel indices are zero-based.');
		}

		return succeeded;
		#else
		return false;
		#end
	}

	public function getMo3ChannelVolume(channel:Int):Float {
		#if (cpp && (windows || android))
		if (mo3Handle == 0 || channel < 0)
			return -1;

		return untyped __cpp__("betterBassGetChannelVolumeValue({0}, {1})", mo3Handle, channel);
		#else
		return -1;
		#end
	}

	public function muteMo3Channel(channel:Int, muted:Bool = true):Bool {
		return setMo3ChannelVolume(channel, muted ? 0 : 1);
	}

	public function getMo3ChannelCount():Int {
		#if (cpp && (windows || android))
		return mo3Handle == 0 ? 0 : untyped __cpp__("betterBassGetChannelCount({0})", mo3Handle);
		#else
		return 0;
		#end
	}

	public function getBassErrorCode():Int {
		#if (cpp && (windows || android))
		return untyped __cpp__("betterBassGetErrorCode()");
		#else
		return -1;
		#end
	}

	public function disposeMo3():Void {
		#if (cpp && (windows || android))
		if (mo3Handle != 0) {
			untyped __cpp__("betterBassStop({0})", mo3Handle);

			untyped __cpp__("betterBassFree({0})", mo3Handle);

			mo3Handle = 0;
		}
		#end
	}

	/** Seeks to a zero-based MO3 order-list position (pattern position), at row 0. */
	public function setMo3Order(order:Int):Bool {
		#if (cpp && (windows || android))
		if (mo3Handle == 0 || order < 0 || order >= getMo3OrderCount())
			return false;

		return untyped __cpp__("betterBassSetMo3Order({0}, {1})", mo3Handle, order);
		#else
		return false;
		#end
	}

	public function playMo3Order(order:Int):Bool {
		#if (cpp && (windows || android))
		return setMo3Order(order) && playMo3(false);
		#else
		return false;
		#end
	}

	public function getCurrentMo3Order():Int {
		#if (cpp && (windows || android))
		return mo3Handle == 0 ? -1 : untyped __cpp__("betterBassGetMo3Order({0})", mo3Handle);
		#else
		return -1;
		#end
	}

	/** Returns the number of order-list positions available in the loaded MO3. */
	public function getMo3OrderCount():Int {
		#if (cpp && (windows || android))
		return mo3Handle == 0 ? 0 : untyped __cpp__("betterBassGetMo3OrderCount({0})", mo3Handle);
		#else
		return 0;
		#end
	}

	public function getMo3Bpm():Float {
		#if (cpp && (windows || android))
		if (mo3Handle == 0)
			return -1;

		return untyped __cpp__("betterBassGetMusicAttributeValue({0}, BETTER_BASS_ATTRIB_MUSIC_BPM)", mo3Handle);
		#else
		return -1;
		#end
	}

	public function setMo3Bpm(bpm:Int):Bool {
		#if (cpp && (windows || android))
		return mo3Handle != 0
			&& bpm >= 1
			&& bpm <= 255

			&& untyped __cpp__("betterBassSetMusicAttribute({0}, BETTER_BASS_ATTRIB_MUSIC_BPM, (float){1})", mo3Handle, bpm);
		#else
		return false;
		#end
	}

	/** Returns the MOD speed, which is the number of ticks per row. */
	public function getMo3TicksPerRow():Int {
		#if (cpp && (windows || android))
		if (mo3Handle == 0)
			return -1;

		var speed:Float = untyped __cpp__("betterBassGetMusicAttributeValue({0}, BETTER_BASS_ATTRIB_MUSIC_SPEED)", mo3Handle);

		return speed < 0 ? -1 : Std.int(speed);
		#else
		return -1;
		#end
	}

	/** Sets the MOD speed (ticks per row). Zero stops playback, so it is rejected. */
	public function setMo3TicksPerRow(ticks:Int):Bool {
		#if (cpp && (windows || android))
		return mo3Handle != 0
			&& ticks >= 1
			&& ticks <= 255

			&& untyped __cpp__("betterBassSetMusicAttribute({0}, BETTER_BASS_ATTRIB_MUSIC_SPEED, (float){1})", mo3Handle, ticks);
		#else
		return false;
		#end
	}

	public function getCurrentMo3Row():Int {
		#if (cpp && (windows || android))
		return mo3Handle == 0 ? -1 : untyped __cpp__("betterBassGetMo3Row({0})", mo3Handle);
		#else
		return -1;
		#end
	}

	/** Returns the approximate current tick within the current row, or -1 if unavailable. */
	public function getCurrentMo3Tick():Int {
		#if (cpp && (windows || android))
		return mo3Handle == 0 ? -1 : untyped __cpp__("betterBassGetMo3Tick({0})", mo3Handle);
		#else
		return -1;
		#end
	}

	#if (cpp && (windows || android))
	private static function initializeBass():Bool {
		return untyped __cpp__("betterBassInit()");
	}
	#end
}
