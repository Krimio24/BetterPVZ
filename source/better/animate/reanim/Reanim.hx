package better.animate.reanim;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;

typedef ReanimImageMap = {
	var id:String;
	var path:String;
}

enum abstract ReanimFlags(Int) from Int to Int {
	var REANIM_NO_ATLAS = 0;
	var REANIM_FAST_DRAW_IN_SW_MODE = 1;
}

enum abstract ReanimLoopType(Int) from Int to Int {
	var REANIM_LOOP = 0;
	var REANIM_LOOP_FULL_LAST_FRAME = 1;
	var REANIM_PLAY_ONCE = 2;
	var REANIM_PLAY_ONCE_FULL_LAST_FRAME = 3;
	var REANIM_PLAY_ONCE_AND_HOLD = 4;
	var REANIM_PLAY_ONCE_FULL_LAST_FRAME_AND_HOLD = 5;
}

enum abstract FilterEffect(Int) from Int to Int {
	var FILTER_EFFECT_NONE = 0;
	var FILTER_EFFECT_WHITE = 1;
}

class ReanimConstants {
	public static inline final DEFAULT_FIELD_PLACEHOLDER:Float = -10000.0;
	public static inline final SECONDS_PER_UPDATE:Float = 0.01;
	public static inline final MAX_REANIM_IMAGES:Int = 64;
	public static inline final NO_BASE_POSE:Int = -2;
	public static inline final RENDER_GROUP_HIDDEN:Int = -1;
	public static inline final RENDER_GROUP_NORMAL:Int = 0;
}

class ReanimAtlasImage {
	public var mX:Int = 0;
	public var mY:Int = 0;
	public var mWidth:Int = 0;
	public var mHeight:Int = 0;
	public var mOriginalGraphic:FlxGraphic = null;

	public function new() {}
}

class ReanimAtlas {
	public var mImageArray:Array<ReanimAtlasImage>;
	public var mImageCount:Int = 0;
	public var mGraphic:FlxGraphic = null;

	public function new() {
		mImageArray = [for (i in 0...ReanimConstants.MAX_REANIM_IMAGES) new ReanimAtlasImage()];
	}

	public function reanimAtlasDispose():Void {
		mGraphic = null;
		mImageCount = 0;
	}

	public function getEncodedReanimAtlas(theGraphic:FlxGraphic):ReanimAtlasImage {
		return null;
	}

	private static function getClosestPowerOf2Above(num:Int):Int {
		var p2 = 1;
		while (p2 < num)
			p2 <<= 1;
		return p2;
	}

	public function pickAtlasWidth():Int {
		var totalArea = 0;
		var maxWidth = 0;
		for (i in 0...mImageCount) {
			var img = mImageArray[i];
			totalArea += img.mWidth * img.mHeight;
			if (maxWidth <= img.mWidth + 2)
				maxWidth = img.mWidth + 2;
		}

		var aWidth = Math.round(Math.sqrt(totalArea));
		var clamped = Math.floor(Math.min(Math.max(aWidth, maxWidth), 2048));
		return getClosestPowerOf2Above(clamped);
	}

	public function imageFits(theImageCount:Int, rectTest:FlxRect, theMaxWidth:Int):Bool {
		if (rectTest.x + rectTest.width > theMaxWidth)
			return false;

		for (i in 0...theImageCount) {
			var img = mImageArray[i];
			var imgRect = FlxRect.get(img.mX - 1, img.mY - 1, img.mWidth + 2, img.mHeight + 2);
			var intersects = imgRect.overlaps(rectTest);
			imgRect.put();
			if (intersects)
				return false;
		}
		return true;
	}

	public function imageFindPlaceOnSide(theAtlasImageToPlace:ReanimAtlasImage, theImageCount:Int, theMaxWidth:Int, theToRight:Bool):Bool {
		var rectTest = FlxRect.get(0, 0, theAtlasImageToPlace.mWidth + 2, theAtlasImageToPlace.mHeight + 2);

		for (i in 0...theImageCount) {
			var img = mImageArray[i];
			if (theToRight) {
				rectTest.x = img.mX + img.mWidth + 1;
				rectTest.y = img.mY;
			} else {
				rectTest.x = img.mX;
				rectTest.y = img.mY + img.mHeight + 1;
			}

			if (imageFits(theImageCount, rectTest, theMaxWidth)) {
				theAtlasImageToPlace.mX = Math.floor(rectTest.x + (theToRight ? 1 : 0));
				theAtlasImageToPlace.mY = Math.floor(rectTest.y + (theToRight ? 0 : 1));
				rectTest.put();
				return true;
			}
		}
		rectTest.put();
		return false;
	}

	public function imageFindPlace(theAtlasImageToPlace:ReanimAtlasImage, theImageCount:Int, theMaxWidth:Int):Bool {
		return imageFindPlaceOnSide(theAtlasImageToPlace, theImageCount, theMaxWidth, true)
			|| imageFindPlaceOnSide(theAtlasImageToPlace, theImageCount, theMaxWidth, false);
	}

	public function placeAtlasImage(theAtlasImageToPlace:ReanimAtlasImage, theImageCount:Int, theMaxWidth:Int):Bool {
		if (theImageCount == 0) {
			theAtlasImageToPlace.mX = 1;
			theAtlasImageToPlace.mY = 1;
			return true;
		}
		return imageFindPlace(theAtlasImageToPlace, theImageCount, theMaxWidth);
	}

	public function arrangeImages(outDimensions:{width:Int, height:Int}):Void {
		var slice = mImageArray.slice(0, mImageCount);
		slice.sort((a, b) -> {
			if (a.mHeight != b.mHeight)
				return b.mHeight - a.mHeight;
			return b.mWidth - a.mWidth;
		});

		for (i in 0...mImageCount)
			mImageArray[i] = slice[i];

		outDimensions.width = pickAtlasWidth();
		outDimensions.height = 0;

		for (i in 0...mImageCount) {
			var img = mImageArray[i];
			placeAtlasImage(img, i, outDimensions.width);
			var imgHeight = getClosestPowerOf2Above(img.mY + img.mHeight);
			outDimensions.height = Math.floor(Math.max(imgHeight, outDimensions.height));
		}
	}

	public function addImage(theGraphic:FlxGraphic):Void {
		if (mImageCount < ReanimConstants.MAX_REANIM_IMAGES) {
			var img = mImageArray[mImageCount++];
			img.mHeight = theGraphic.height;
			img.mWidth = theGraphic.width;
			img.mOriginalGraphic = theGraphic;
		}
	}

	public function findImage(theGraphic:FlxGraphic):Int {
		for (i in 0...mImageCount) {
			if (mImageArray[i].mOriginalGraphic == theGraphic)
				return i;
		}
		return -1;
	}

	public function reanimAtlasCreate(theReanimDef:ReanimatorDefinition):Void {
		for (aTrack in theReanimDef.mTracks) {
			for (transform in aTrack.mTransforms) {
				var graphic = transform.mGraphic;
				if (graphic != null && graphic.width <= 254 && graphic.height <= 254 && findImage(graphic) < 0) {
					addImage(graphic);
				}
			}
		}

		var dims = {width: 0, height: 0};
		arrangeImages(dims);
	}
}

class ReanimatorTransform {
	public var mTransX:Float = 0.0;
	public var mTransY:Float = 0.0;
	public var mSkewX:Float = 0.0;
	public var mSkewY:Float = 0.0;
	public var mScaleX:Float = 1.0;
	public var mScaleY:Float = 1.0;
	public var mFrame:Float = 0.0;
	public var mAlpha:Float = 1.0;
	public var mGraphic:FlxGraphic = null;
	public var mFontName:String = "";
	public var mText:String = "";

	public function new() {}
}

class ReanimatorTrack {
	public var mName:String = "";
	public var mTransforms:Array<ReanimatorTransform> = [];
	public var mTransformCount:Int = 0;

	public function new() {}
}

class ReanimatorDefinition {
	public var mTracks:Array<ReanimatorTrack> = [];
	public var mTrackCount:Int = 0;
	public var mFPS:Float = 12.0;
	public var mReanimAtlas:ReanimAtlas = null;

	public function new() {}
}

class ReanimationParams {
	public var mReanimationType:Int;
	public var mReanimFileName:String;
	public var mReanimParamFlags:Int;

	public function new(type:Int, file:String, flags:Int) {
		this.mReanimationType = type;
		this.mReanimFileName = file;
		this.mReanimParamFlags = flags;
	}
}

class ReanimatorFrameTime {
	public var mFraction:Float = 0.0;
	public var mAnimFrameBeforeInt:Int = 0;
	public var mAnimFrameAfterInt:Int = 0;

	public function new() {}
}

class ReanimatorTrackInstance {
	public var mBlendCounter:Int = 0;
	public var mBlendTime:Int = 0;
	public var mBlendTransform:ReanimatorTransform = new ReanimatorTransform();
	public var mShakeOverride:Float = 0.0;
	public var mShakeX:Float = 0.0;
	public var mShakeY:Float = 0.0;
	public var mAttachmentID:Int = 0;
	public var mImageOverride:FlxGraphic = null;
	public var mRenderGroup:Int = ReanimConstants.RENDER_GROUP_NORMAL;
	public var mTrackColor:FlxColor = FlxColor.WHITE;
	public var mIgnoreClipRect:Bool = false;
	public var mTruncateDisappearingFrames:Bool = true;
	public var mIgnoreColorOverride:Bool = false;
	public var mIgnoreExtraAdditiveColor:Bool = false;

	public function new() {}
}

class AttacherInfo {
	public var mReanimName:String = "";
	public var mTrackName:String = "";
	public var mAnimRate:Float = 12.0;
	public var mLoopType:ReanimLoopType = REANIM_LOOP;

	public function new() {}
}

class Reanimation extends FlxSprite {
	public var mReanimationType:Int = 0;
	public var mAnimTime:Float = 0.0;
	public var mAnimRate:Float = 12.0;
	public var mDefinition:ReanimatorDefinition = null;
	public var mLoopType:ReanimLoopType = REANIM_PLAY_ONCE;
	public var mDead:Bool = false;
	public var mFrameStart:Int = 0;
	public var mFrameCount:Int = 0;
	public var mFrameBasePose:Int = -1;
	public var mOverlayMatrix:FlxMatrix = new FlxMatrix();
	public var mColorOverride:FlxColor = FlxColor.WHITE;
	public var mTrackInstances:Array<ReanimatorTrackInstance> = [];
	public var mLoopCount:Int = 0;
	public var mReanimationHolder:ReanimationHolder = null;
	public var mIsAttachment:Bool = false;
	public var mRenderOrder:Int = 0;
	public var mExtraAdditiveColor:FlxColor = FlxColor.WHITE;
	public var mEnableExtraAdditiveDraw:Bool = false;
	public var mExtraOverlayColor:FlxColor = FlxColor.WHITE;
	public var mEnableExtraOverlayDraw:Bool = false;
	public var mLastFrameTime:Float = -1.0;
	public var mFilterEffect:FilterEffect = FILTER_EFFECT_NONE;

	public function new(X:Float = 0, Y:Float = 0) {
		super(X, Y);
	}

	public function reanimationInitialize(theX:Float, theY:Float, theDefinition:ReanimatorDefinition):Void {
		mDead = false;
		mDefinition = theDefinition;
		mAnimRate = (theDefinition != null) ? theDefinition.mFPS : 12.0;
		mLastFrameTime = -1.0;

		if (theDefinition != null && theDefinition.mTrackCount != 0) {
			mFrameCount = theDefinition.mTracks[0].mTransformCount;
			mTrackInstances = [for (i in 0...theDefinition.mTrackCount) new ReanimatorTrackInstance()];
		} else {
			mFrameCount = 0;
			mTrackInstances = [];
		}

		var maxW:Float = 0;
		var maxH:Float = 0;
		if (mDefinition != null) {
			for (track in mDefinition.mTracks) {
				for (t in track.mTransforms) {
					if (t.mGraphic != null) {
						if (t.mGraphic.width > maxW) maxW = t.mGraphic.width;
						if (t.mGraphic.height > maxH) maxH = t.mGraphic.height;
					}
				}
			}
		}
		this.width = maxW > 0 ? maxW : 100;
		this.height = maxH > 0 ? maxH : 100;

		setPosition(theX, theY);
	}

	override public function setPosition(theX:Float = 0, theY:Float = 0):Void {
		super.setPosition(theX, theY);
	}

	public function overrideScale(theScaleX:Float, theScaleY:Float):Void {
		mOverlayMatrix.a = theScaleX;
		mOverlayMatrix.d = theScaleY;
	}

	private static inline function floatLerp(a:Float, b:Float, t:Float):Float {
		return a + (b - a) * t;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (mFrameCount == 0 || mDead || mDefinition == null)
			return;

		mLastFrameTime = mAnimTime;
		mAnimTime += elapsed * mAnimRate / mFrameCount;

		if (mAnimRate > 0) {
			switch (mLoopType) {
				case REANIM_LOOP, REANIM_LOOP_FULL_LAST_FRAME:
					while (mAnimTime >= 1.0) {
						mLoopCount++;
						mAnimTime -= 1.0;
					}
				case REANIM_PLAY_ONCE, REANIM_PLAY_ONCE_FULL_LAST_FRAME:
					if (mAnimTime >= 1.0) {
						mLoopCount = 1;
						mAnimTime = 1.0;
						mDead = true;
					}
				case REANIM_PLAY_ONCE_AND_HOLD, REANIM_PLAY_ONCE_FULL_LAST_FRAME_AND_HOLD:
					if (mAnimTime >= 1.0) {
						mLoopCount = 1;
						mAnimTime = 1.0;
					}
			}
		} else {
			switch (mLoopType) {
				case REANIM_LOOP, REANIM_LOOP_FULL_LAST_FRAME:
					while (mAnimTime < 0.0) {
						mLoopCount++;
						mAnimTime += 1.0;
					}
				case REANIM_PLAY_ONCE, REANIM_PLAY_ONCE_FULL_LAST_FRAME:
					if (mAnimTime < 0.0) {
						mLoopCount = 1;
						mAnimTime = 0.0;
						mDead = true;
					}
				case REANIM_PLAY_ONCE_AND_HOLD, REANIM_PLAY_ONCE_FULL_LAST_FRAME_AND_HOLD:
					if (mAnimTime < 0.0) {
						mLoopCount = 1;
						mAnimTime = 0.0;
					}
			}
		}

		for (i in 0...mDefinition.mTrackCount) {
			var trackInst = mTrackInstances[i];
			if (trackInst == null) continue;

			if (trackInst.mBlendCounter > 0)
				trackInst.mBlendCounter--;

			if (trackInst.mShakeOverride != 0.0) {
				trackInst.mShakeX = (FlxG.random.float(-1.0, 1.0)) * trackInst.mShakeOverride;
				trackInst.mShakeY = (FlxG.random.float(-1.0, 1.0)) * trackInst.mShakeOverride;
			}

			if (mDefinition.mTracks[i] != null && StringTools.startsWith(mDefinition.mTracks[i].mName.toLowerCase(), "attacher__")) {
				updateAttacherTrack(i);
			}
		}
	}

	override public function draw():Void {
		if (!visible || alpha <= 0 || mFrameCount == 0 || mDead || mDefinition == null)
			return;

		var frameTime = new ReanimatorFrameTime();
		getFrameTime(frameTime);

		var transform = new ReanimatorTransform();

		for (i in 0...mDefinition.mTrackCount) {
			var trackInst = mTrackInstances[i];
			if (trackInst == null || trackInst.mRenderGroup == ReanimConstants.RENDER_GROUP_HIDDEN)
				continue;

			getTransformAtTime(i, transform, frameTime);

			var graphicToDraw = (trackInst.mImageOverride != null) ? trackInst.mImageOverride : transform.mGraphic;
			if (graphicToDraw == null || transform.mFrame < 0 || transform.mAlpha <= 0)
				continue;

			var skewXRad = transform.mSkewX * (Math.PI / 180.0);
			var skewYRad = transform.mSkewY * (Math.PI / 180.0);

			var a = Math.cos(skewXRad) * transform.mScaleX;
			var b = Math.sin(skewXRad) * transform.mScaleX;
			var c = -Math.sin(skewYRad) * transform.mScaleY;
			var d = Math.cos(skewYRad) * transform.mScaleY;

			var tx = transform.mTransX + trackInst.mShakeX;
			var ty = transform.mTransY + trackInst.mShakeY;

			var mat = new flixel.math.FlxMatrix(a, b, c, d, tx, ty);
			mat.concat(mOverlayMatrix);

			var drawAlpha = alpha * transform.mAlpha;
			if (drawAlpha <= 0)
				continue;

			for (camera in getCameras()) {
				if (!camera.visible || !camera.exists)
					continue;

				var drawMat = mat.clone();
				drawMat.tx += x - camera.scroll.x * scrollFactor.x;
				drawMat.ty += y - camera.scroll.y * scrollFactor.y;

				var frame = graphicToDraw.imageFrame.frame;
				if (frame != null) {
					camera.drawPixels(frame, graphicToDraw.bitmap, drawMat, colorTransform, blend, clipRect, shader);
				}
			}
		}
	}

	public function getFrameTime(theFrameTime:ReanimatorFrameTime):Void {
		var aFrameCount = (mLoopType == REANIM_PLAY_ONCE_FULL_LAST_FRAME
			|| mLoopType == REANIM_LOOP_FULL_LAST_FRAME
			|| mLoopType == REANIM_PLAY_ONCE_FULL_LAST_FRAME_AND_HOLD) ? mFrameCount : mFrameCount - 1;

		if (aFrameCount <= 0) aFrameCount = 1;

		var aAnimPosition = mFrameStart + mAnimTime * aFrameCount;
		var aAnimFrameBefore = Math.floor(aAnimPosition);

		theFrameTime.mFraction = aAnimPosition - aAnimFrameBefore;
		theFrameTime.mAnimFrameBeforeInt = Math.round(aAnimFrameBefore);

		if (theFrameTime.mAnimFrameBeforeInt >= mFrameStart + mFrameCount - 1) {
			theFrameTime.mAnimFrameBeforeInt = mFrameStart + mFrameCount - 1;
			theFrameTime.mAnimFrameAfterInt = theFrameTime.mAnimFrameBeforeInt;
		} else {
			theFrameTime.mAnimFrameAfterInt = theFrameTime.mAnimFrameBeforeInt + 1;
		}
	}

	public function getTransformAtTime(theTrackIndex:Int, theTransform:ReanimatorTransform, theFrameTime:ReanimatorFrameTime):Void {
		if (mDefinition == null || theTrackIndex < 0 || theTrackIndex >= mDefinition.mTracks.length)
			return;

		var aTrack = mDefinition.mTracks[theTrackIndex];
		if (aTrack == null || aTrack.mTransforms.length == 0)
			return;

		var beforeIdx = Std.int(Math.max(0, Math.min(aTrack.mTransforms.length - 1, theFrameTime.mAnimFrameBeforeInt)));
		var afterIdx = Std.int(Math.max(0, Math.min(aTrack.mTransforms.length - 1, theFrameTime.mAnimFrameAfterInt)));

		var aTransBefore = aTrack.mTransforms[beforeIdx];
		var aTransAfter = aTrack.mTransforms[afterIdx];

		theTransform.mTransX = floatLerp(aTransBefore.mTransX, aTransAfter.mTransX, theFrameTime.mFraction);
		theTransform.mTransY = floatLerp(aTransBefore.mTransY, aTransAfter.mTransY, theFrameTime.mFraction);
		theTransform.mSkewX = floatLerp(aTransBefore.mSkewX, aTransAfter.mSkewX, theFrameTime.mFraction);
		theTransform.mSkewY = floatLerp(aTransBefore.mSkewY, aTransAfter.mSkewY, theFrameTime.mFraction);
		theTransform.mScaleX = floatLerp(aTransBefore.mScaleX, aTransAfter.mScaleX, theFrameTime.mFraction);
		theTransform.mScaleY = floatLerp(aTransBefore.mScaleY, aTransAfter.mScaleY, theFrameTime.mFraction);
		theTransform.mAlpha = floatLerp(aTransBefore.mAlpha, aTransAfter.mAlpha, theFrameTime.mFraction);
		theTransform.mGraphic = aTransBefore.mGraphic != null ? aTransBefore.mGraphic : aTransAfter.mGraphic;
		theTransform.mFontName = aTransBefore.mFontName;
		theTransform.mText = aTransBefore.mText;

		if (aTransBefore.mFrame != -1.0
			&& aTransAfter.mFrame == -1.0
			&& theFrameTime.mFraction > 0.0
			&& mTrackInstances[theTrackIndex] != null
			&& mTrackInstances[theTrackIndex].mTruncateDisappearingFrames) {
			theTransform.mFrame = -1.0;
		} else {
			theTransform.mFrame = aTransBefore.mFrame;
		}
	}

	public function getCurrentTransform(theTrackIndex:Int, theTransformCurrent:ReanimatorTransform):Void {
		var ft = new ReanimatorFrameTime();
		getFrameTime(ft);
		getTransformAtTime(theTrackIndex, theTransformCurrent, ft);

		var aTrack = mTrackInstances[theTrackIndex];
		if (aTrack != null && Math.round(theTransformCurrent.mFrame) >= 0 && aTrack.mBlendCounter > 0) {
			var aBlendFactor = aTrack.mBlendCounter / aTrack.mBlendTime;
			blendTransform(theTransformCurrent, theTransformCurrent, aTrack.mBlendTransform, aBlendFactor);
		}
	}

	public static function blendTransform(theResult:ReanimatorTransform, theTransform1:ReanimatorTransform, theTransform2:ReanimatorTransform,
			theBlendFactor:Float):Void {
		theResult.mTransX = floatLerp(theTransform1.mTransX, theTransform2.mTransX, theBlendFactor);
		theResult.mTransY = floatLerp(theTransform1.mTransY, theTransform2.mTransY, theBlendFactor);
		theResult.mScaleX = floatLerp(theTransform1.mScaleX, theTransform2.mScaleX, theBlendFactor);
		theResult.mScaleY = floatLerp(theTransform1.mScaleY, theTransform2.mScaleY, theBlendFactor);
		theResult.mAlpha = floatLerp(theTransform1.mAlpha, theTransform2.mAlpha, theBlendFactor);

		var aSkewX2 = theTransform2.mSkewX;
		var aSkewY2 = theTransform2.mSkewY;

		while (aSkewX2 > theTransform1.mSkewX + 180.0)
			aSkewX2 -= 360.0;
		while (aSkewX2 < theTransform1.mSkewX - 180.0)
			aSkewX2 += 360.0;
		while (aSkewY2 > theTransform1.mSkewY + 180.0)
			aSkewY2 -= 360.0;
		while (aSkewY2 < theTransform1.mSkewY - 180.0)
			aSkewY2 += 360.0;

		theResult.mSkewX = floatLerp(theTransform1.mSkewX, aSkewX2, theBlendFactor);
		theResult.mSkewY = floatLerp(theTransform1.mSkewY, aSkewY2, theBlendFactor);
		theResult.mFrame = theTransform1.mFrame;
		theResult.mFontName = theTransform1.mFontName;
		theResult.mText = theTransform1.mText;
		theResult.mGraphic = theTransform1.mGraphic;
	}

	public function findTrackIndex(theTrackName:String):Int {
		if (mDefinition == null) return 0;
		for (i in 0...mDefinition.mTrackCount) {
			if (mDefinition.mTracks[i] != null && mDefinition.mTracks[i].mName.toLowerCase() == theTrackName.toLowerCase())
				return i;
		}
		return 0;
	}

	public function getTrackInstanceByName(theTrackName:String):ReanimatorTrackInstance {
		return mTrackInstances[findTrackIndex(theTrackName)];
	}

	public function playReanim(theTrackName:String, theLoopType:ReanimLoopType, theBlendTime:Int, theAnimRate:Float):Void {
		if (theBlendTime > 0)
			startBlend(theBlendTime);
		if (theAnimRate != 0.0)
			mAnimRate = theAnimRate;

		mLoopType = theLoopType;
		mLoopCount = 0;
		setFramesForLayer(theTrackName);
	}

	public function startBlend(theBlendTime:Int):Void {
		if (mDefinition == null) return;
		for (i in 0...mDefinition.mTrackCount) {
			var aTransform = new ReanimatorTransform();
			getCurrentTransform(i, aTransform);
			if (Math.round(aTransform.mFrame) >= 0 && i < mTrackInstances.length) {
				var inst = mTrackInstances[i];
				if (inst != null) {
					inst.mBlendTransform = aTransform;
					inst.mBlendTime = theBlendTime;
					inst.mBlendCounter = theBlendTime;
					inst.mBlendTransform.mFontName = "";
					inst.mBlendTransform.mText = "";
					inst.mBlendTransform.mGraphic = null;
				}
			}
		}
	}

	public function getFramesForLayer(theTrackName:String, outFrames:{start:Int, count:Int}):Void {
		if (mDefinition == null || mDefinition.mTrackCount == 0) {
			outFrames.start = 0;
			outFrames.count = 0;
			return;
		}

		var trackIdx = findTrackIndex(theTrackName);
		var aTrack = mDefinition.mTracks[trackIdx];
		outFrames.start = 0;
		outFrames.count = 1;

		if (aTrack == null) return;

		for (i in 0...aTrack.mTransformCount) {
			if (aTrack.mTransforms[i] != null && aTrack.mTransforms[i].mFrame >= 0.0) {
				outFrames.start = i;
				break;
			}
		}
		for (j in outFrames.start...aTrack.mTransformCount) {
			if (aTrack.mTransforms[j] != null && aTrack.mTransforms[j].mFrame >= 0.0) {
				outFrames.count = j - outFrames.start + 1;
			}
		}
	}

	public function setFramesForLayer(theTrackName:String):Void {
		mAnimTime = (mAnimRate >= 0) ? 0.0 : 0.9999999;
		mLastFrameTime = -1.0;
		var outF = {start: 0, count: 0};
		getFramesForLayer(theTrackName, outF);
		mFrameStart = outF.start;
		mFrameCount = outF.count;
	}

	public static function parseAttacherTrack(theTransform:ReanimatorTransform, theAttacherInfo:AttacherInfo):Void {
		theAttacherInfo.mReanimName = "";
		theAttacherInfo.mTrackName = "";
		theAttacherInfo.mAnimRate = 12.0;
		theAttacherInfo.mLoopType = REANIM_LOOP;

		if (theTransform.mFrame == -1.0 || theTransform.mText == null)
			return;

		var text = theTransform.mText;
		var idx = text.indexOf("__");
		if (idx == -1)
			return;

		var rest = text.substr(idx + 2);
		var tagsIdx = rest.indexOf("[");
		var trackIdx = rest.indexOf("__");

		if (tagsIdx != -1 && trackIdx != -1 && tagsIdx < trackIdx)
			return;

		if (trackIdx != -1) {
			theAttacherInfo.mReanimName = rest.substr(0, trackIdx);
			var trackRest = rest.substr(trackIdx + 2);
			var trackTagsIdx = trackRest.indexOf("[");
			if (trackTagsIdx != -1) {
				theAttacherInfo.mTrackName = trackRest.substr(0, trackTagsIdx);
			} else {
				theAttacherInfo.mTrackName = trackRest;
			}
		} else if (tagsIdx != -1) {
			theAttacherInfo.mReanimName = rest.substr(0, tagsIdx);
		} else {
			theAttacherInfo.mReanimName = rest;
		}

		var reg = ~/\[(.*?)\]/;
		var pos = 0;
		while (reg.matchSub(text, pos)) {
			var code = reg.matched(1);
			var val = Std.parseFloat(code);
			if (!Math.isNaN(val)) {
				theAttacherInfo.mAnimRate = val;
			} else if (code == "hold") {
				theAttacherInfo.mLoopType = REANIM_PLAY_ONCE_AND_HOLD;
			} else if (code == "once") {
				theAttacherInfo.mLoopType = REANIM_PLAY_ONCE;
			}
			pos = reg.matchedPos().pos + reg.matchedPos().len;
		}
	}

	public function updateAttacherTrack(theTrackIndex:Int):Void {
		var aTransform = new ReanimatorTransform();
		getCurrentTransform(theTrackIndex, aTransform);
		var info = new AttacherInfo();
		parseAttacherTrack(aTransform, info);
	}
}

class ReanimationHolder {
	public var mReanimations:Array<Reanimation> = [];

	public function new() {}

	public function initializeHolder():Void {
		mReanimations = [];
	}

	public function disposeHolder():Void {
		mReanimations = [];
	}

	public function allocReanimation(theX:Float, theY:Float, theRenderOrder:Int, theReanimationType:Int, theDef:ReanimatorDefinition):Reanimation {
		var reanim = new Reanimation(theX, theY);
		reanim.mRenderOrder = theRenderOrder;
		reanim.mReanimationHolder = this;
		reanim.mReanimationType = theReanimationType;
		reanim.reanimationInitialize(theX, theY, theDef);
		mReanimations.push(reanim);
		return reanim;
	}
}

class ReanimatorGlobals {
	public static var gReanimatorDefArray:Array<ReanimatorDefinition> = [];
	public static var gReanimationParamArray:Array<ReanimationParams> = [];

	public static function reanimatorLoadDefinitions(params:Array<ReanimationParams>):Void {
		gReanimationParamArray = params;
		gReanimatorDefArray = [for (i in 0...params.length) new ReanimatorDefinition()];
	}

	public static function reanimatorFreeDefinitions():Void {
		for (def in gReanimatorDefArray) {
			if (def.mReanimAtlas != null) {
				def.mReanimAtlas.reanimAtlasDispose();
			}
		}
		gReanimatorDefArray = [];
		gReanimationParamArray = [];
	}
}
