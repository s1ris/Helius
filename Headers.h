#include <UIKit/UIKit.h>
#include <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>
#include <CoreGraphics/CoreGraphics.h>
#include <QuartzCore/QuartzCore.h>
#include <Celestial/AVSystemController.h>
#include <CoreText/CoreText.h>
#include <MediaPlayer/MediaPlayer.h>
#import <objc/runtime.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import "Helius.h"
#import "SBBlurryArtworkView.h"
#import "MediaRemote.h"

#define VARIANT_LOCKSCREEN 0
#define VARIANT_HOMESCREEN 1

@interface NowPlayingArtPluginController : UIViewController
-(void)loadView;
@end

@interface _NowPlayingArtView : UIView {
	UIImageView *_artworkView;
}
@property(nonatomic,retain) UIImageView *artworkView;
-(UIImageView *) artworkView;
@end

@interface SBApplication
-(id)applicationWithDisplayIdentifier:(id)arg1;
-(id)bundleIdentifier;
@end

@interface SBAlertView : UIView
@end

@interface SBLockScreenView : SBAlertView
-(void) _setMediaControlsHidden:(BOOL)hidden;
-(UIImage *) image:(UIImage*)originalImage scaledToSize:(CGSize)size;
-(void) setMediaControlsHidden:(BOOL)hidden forRequester:(id)requester;
-(void) setSlideToUnlockHidden:(BOOL)hidden forRequester:(id)requester;
-(void) setPluginViewHidden:(BOOL)hidden forRequester:(id)requester;
-(void) setNotificationsHidden:(BOOL)hidden forRequester:(id)requester;
-(void) getScrollview;
-(id) dateView;
@end

@interface SBLockScreenPlugin
@property(copy) NSString *bundleName;
@end

@interface SBLockScreenNotificationListView : UIView
-(void) updateForAdditionOfItemAtIndex:(unsigned int)index allowHighlightOnInsert:(BOOL)insert;
@end

@interface SBLockScreenViewController : UIViewController
-(void) _setMediaControlsVisible:(BOOL)visible;
-(void) notificationListBecomingVisible:(BOOL)visible;
-(BOOL) shouldShowLockStatusBarTime;
@end

@interface SBLockScreenViewControllerBase
-(void) setPasscodeLockVisible:(BOOL)visibile animated:(BOOL)animated completion:(void (^)())completion;
-(void) seekWithFloat:(float)flowt;
@end

@interface SBLockScreenManager : NSObject
+(id) sharedInstance;
@property (nonatomic, readonly) BOOL isUILocked;
@property (nonatomic, readonly) SBLockScreenViewControllerBase *lockScreenViewController;
@end

@interface SBFLockScreenDateView : UIView
-(id) _timeFont;
@end

@interface SpringBoard
-(BOOL) launchApplicationWithIdentifier:(NSString *)identifier suspended:(BOOL)suspended;
@property (nonatomic, retain) SBFLockScreenDateView *dateView;
@end

@interface SBLockScreenSlideUpController
+(id) sharedInstanceCreatedByHelius;
-(id) init;
@property(retain) SBLockScreenView *lockScreenView;
@end

@interface UILabel (Private)
-(void) setMarqueeEnabled:(BOOL)marqueeEnabled;
-(void) setMarqueeRunning:(BOOL)marqueeRunning;
-(void) _startMarquee;
@end

@interface MPUNowPlayingController
-(BOOL) isPlaying;
@end

@interface SBWallpaperController : NSObject
+ (instancetype)sharedInstance;
- (void)setLockscreenOnlyWallpaperAlpha:(float)alpha;
- (id)_newWallpaperViewForProcedural:(id)proceduralWallpaper orImage:(UIImage *)image;
- (id)_newWallpaperViewForProcedural:(id)proceduralWallpaper orImage:(UIImage *)image forVariant:(int)variant; //iOS 7.1
- (id)_clearWallpaperView:(id *)wallpaperView;
- (void)_handleWallpaperChangedForVariant:(NSUInteger)variant;
- (void)_updateSeparateWallpaper;
- (void)_updateSharedWallpaper;
- (void)_reconfigureBlurViewsForVariant:(NSUInteger)variant;
- (void)_updateBlurImagesForVariant:(NSUInteger)variant;
@end

@interface SBFStaticWallpaperView : UIView
- (instancetype)initWithFrame:(CGRect)frame wallpaperImage:(UIImage *)wallpaperImage;
- (UIImageView *)contentView;
- (void)setVariant:(NSUInteger)variant;
- (void)setZoomFactor:(float)zoomFactor;
@end

@interface _SBFakeBlurView : UIView
+ (UIImage *)_imageForStyle:(int *)style withSource:(SBFStaticWallpaperView *)source;
- (void)updateImageWithSource:(id)source;
- (void)reconfigureWithSource:(id)source;
@end

@interface SBMediaController : NSObject
+ (instancetype)sharedInstance;
- (id)_nowPlayingInfo;
- (UIImage *)artwork;
- (NSUInteger)trackUniqueIdentifier;
- (BOOL)isPlaying;
@end

@interface SBUIController : NSObject
+ (instancetype)sharedInstance;
- (void)setLockscreenArtworkImage:(UIImage *)artworkImage;
- (void)updateLockscreenArtwork;
- (void)blurryArtworkPreferencesChanged;
@end

@interface SBLockScreenScrollView : UIScrollView
@end

