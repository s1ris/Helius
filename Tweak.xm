#import "Headers.h"

Helius *h;
UIView *_notificationListView;
BOOL noti;
id slideUp;
CFPropertyListRef value;
CFPropertyListRef value2;
static SBBlurryArtworkView *_blurryArtworkView = nil;

%hook MPUNowPlayingController

//I found current functions for getting updates on play/pause notifications somewhat unstable, this works fine

-(BOOL) isPlaying {
	if (!((CFBooleanRef)value == kCFBooleanTrue)) {
		return %orig;
	}
	BOOL isMPUPlaying = %orig;
	if (h.oppositeColor) {
		[h setPlayPauseButtonImage:(isMPUPlaying) ? [[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Helius2/pause.png"] : [[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Helius2/play.png"]];
	}
	return %orig;
}

%end

%hook SBLockScreenSlideUpController

-(id) init {
	slideUp = self;
	return %orig;
}

%new

//creating a sharedInstance for easy access while making sure to let developers know this instance is created by Helius

+(id) sharedInstanceCreatedByHelius {
	return slideUp;
}

%end

%hook SBLockScreenNotificationListView

//hide media controls when a notification comes in

-(void) updateForAdditionOfItemAtIndex:(CGFloat)index allowHighlightOnInsert:(BOOL)insert {
	if (!((CFBooleanRef)value == kCFBooleanTrue)) {
		[[[%c(SBLockScreenSlideUpController) sharedInstanceCreatedByHelius] lockScreenView] setMediaControlsHidden:1 forRequester:@"hi"];
	}
	%orig(index, insert);
}

//get a reference to _notificationListView

-(void) layoutSubviews {
	%orig;
	_notificationListView = self;
}

%end

%hook SBLockScreenView

//return custom media controls view here

-(void) setMediaControlsView:(id)view {
	%orig;
	value = CFPreferencesCopyAppValue(CFSTR("master"), CFSTR("org.thebigboss.helius2settings"));
	if (!((CFBooleanRef)value == kCFBooleanTrue)) {
		return %orig(view);
	}
	h = [%c(Helius) sharedInstance];
	return %orig(h);
}

//if our media controls are up, we need to hide notifications, or else things are ugly

-(BOOL) mediaControlsHidden {
	if (!((CFBooleanRef)value == kCFBooleanTrue)) {
		return %orig;
	}
	BOOL orig = %orig;
	_notificationListView.hidden = orig ? 0 : 1;
	return orig;
}

//fix for lock screen not swiping when media controls are up on iOS 8

-(BOOL) _disallowScrollingInTouchedView:(id)view {
	if (!((CFBooleanRef)value == kCFBooleanTrue)) {
		return %orig;
	}
	return 0;
}

//these next two methods prevent the media controls from hiding when control center is invoked

-(void) setLockHUDHidden:(BOOL)hidden forRequester:(id)requester {
	if (!((CFBooleanRef)value == kCFBooleanTrue)) {
		%orig(hidden, requester);
	}
	if ([requester isEqualToString:@"Control Center"]) {
	}
	else {
		%orig(hidden, requester);
	}
}

-(void) setMediaControlsContainerAlpha:(CGFloat)alpha {
	if (!((CFBooleanRef)value == kCFBooleanTrue)) {
		%orig(alpha);
	}
	return;
}

//set our media controls height

-(CGFloat) _mediaControlsHeight {
	if (!((CFBooleanRef)value == kCFBooleanTrue)) {
		return %orig;
	}
	return [[UIScreen mainScreen] bounds].size.height;
}

//set our media controls Y axis

-(CGFloat) _mediaControlsY {
	if (!((CFBooleanRef)value == kCFBooleanTrue)) {
		return %orig;
	}
	return 0;
}

//I forget exactly what this is for but it´s borrowed from Cydget, also hide slide to unlock on 480 point screens

-(void) setMediaControlsHidden:(BOOL)arg1 forRequester:(id)arg2 {
	%orig(arg1, arg2);
	if (!((CFBooleanRef)value == kCFBooleanTrue)) {
		return;
	}
	UIView *_mediaControlsContainerView = MSHookIvar<UIView *>(self, "_mediaControlsContainerView");
	UIView *_mediaControlsView = MSHookIvar<UIView *>(self, "_mediaControlsView");
	if (_mediaControlsContainerView != NULL && _mediaControlsView != NULL) {
		[_mediaControlsContainerView setUserInteractionEnabled:([_mediaControlsView alpha] != 0)];
		if ([[UIScreen mainScreen] bounds].size.height == 480) {
			[self setSlideToUnlockHidden:([_mediaControlsView alpha] != 0) forRequester:@"hi"];
		}
	}
}

//increase slide to unlock Y axis a bit

-(void) _layoutSlideToUnlockView {
	%orig;
	if (!((CFBooleanRef)value == kCFBooleanTrue)) {
		return;
	}
	if ([[UIScreen mainScreen] bounds].size.height == 480) {
		return; 
	}
	UIView *_slide = MSHookIvar<UIView *>(self, "_slideToUnlockView");
	UIView *_slideBack = MSHookIvar<UIView *>(self, "_slideToUnlockBackgroundView");
	CGRect sliderFrame = [_slide frame];
	sliderFrame.origin.y = 20;
	[_slide setFrame:sliderFrame];
	[_slideBack setFrame:sliderFrame];
}

%end

//next two hooks are for hiding default lock screen artwork

%hook NowPlayingArtPluginController

-(void) loadView {
	%orig;
	if (!((CFBooleanRef)value == kCFBooleanTrue)) {
		return;
	}
	_NowPlayingArtView *view = (_NowPlayingArtView*)self.view;
	view.hidden = 1;
}

%end

%hook SBLockScreenPlugin

-(void) setOverlay:(id)arg1  {
	if (!((CFBooleanRef)value == kCFBooleanTrue)) {
		%orig;
	}
	if([self.bundleName isEqual:@"NowPlayingArtLockScreen"]) {
		return;
	}
	else {
		%orig;
	}
}

%end

//hide status bar clock

%hook SBLockScreenViewController

-(BOOL) shouldShowLockStatusBarTime {
	if ((CFBooleanRef)value == kCFBooleanTrue) {
		return 0;
	}
	else {
		return %orig;
	}
}

%end

%hook SBFLockScreenDateView

//lazy mans fix for adding support for 24hour clock, alsk saves us an NSTimer in Helius.m

-(void) _updateLabels {
	%orig;
	h.clockLabel.text = MSHookIvar<UILabel *>(self, "_timeLabel").text;
}

%end

static void ReloadPreferences() {
	CFPreferencesAppSynchronize(CFSTR("org.thebigboss.helius2settings"));
	value = CFPreferencesCopyAppValue(CFSTR("master"), CFSTR("org.thebigboss.helius2settings"));
	BOOL tweakEnBOOL = !CFPreferencesCopyAppValue(CFSTR("artwork"), CFSTR("org.thebigboss.helius2settings")) ? 1 : !(CFBooleanRef)CFPreferencesCopyAppValue(CFSTR("artwork"), CFSTR("org.thebigboss.helius2settings"));
	_blurryArtworkView.hidden = tweakEnBOOL;
}

//this hook grouo is basically the source code for Spectral

%group NowPlayingArtView

static NSDictionary *_preferences = nil;
static __weak NSData *_artworkData;
static __weak UIImage *_artworkImage;
static __weak _NowPlayingArtView *_artView = nil;

%hook NowPlayingArtPluginController

-(void) viewWillAppear:(BOOL)animated {
	%orig;
	[[%c(SBUIController) sharedInstance] updateLockscreenArtwork];
}

-(void) viewWillDisappear:(BOOL)animated {
	%orig;
	[[%c(SBUIController) sharedInstance] updateLockscreenArtwork];
}

%end

%hook SBUIController

-(id) init {
	SBUIController *controller = %orig;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentSongChanged:) name:@"SBMediaNowPlayingChangedNotification" object:nil];
	_blurryArtworkView = [[SBBlurryArtworkView alloc] initWithFrame:CGRectZero];
	ReloadPreferences();
	return controller;
}

%new

-(void) updateLockscreenArtwork {
	[[NSOperationQueue mainQueue] addOperationWithBlock:^(){
		UIImage *artwork = nil;
		if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
			SBMediaController *mediaController = [%c(SBMediaController) sharedInstance];
			NSData *artworkData = [[mediaController _nowPlayingInfo] valueForKey:@"artworkData"];
			if (artworkData == _artworkData) {
				return;
			}
			_artworkData = artworkData;
			artwork = mediaController.artwork;
		} else {
			artwork = _artView.artworkView.image;
		}
		if (artwork != _artworkImage) {
			self.lockscreenArtworkImage = artwork;
			_artworkImage = artwork;
		}
	}];
}

%new

-(void) currentSongChanged:(NSNotification *)notification {
	[self updateLockscreenArtwork];
}

%new

-(void) setLockscreenArtworkImage:(UIImage *)artworkImage {
	_blurryArtworkView.artworkImage = artworkImage;
}

%new

-(SBBlurryArtworkView *) blurryArtworkView {
	return _blurryArtworkView;
}


-(void) cleanUpOnFrontLocked {
	%orig;
	SBMediaController *mediaController = [%c(SBMediaController) sharedInstance];
	if (!mediaController.isPlaying) {
		self.lockscreenArtworkImage = nil;
	}
}

%end

%hook SBMediaController

-(void) setNowPlayingInfo:(id)info {
	%orig;
	[[%c(SBUIController) sharedInstance] updateLockscreenArtwork];
}

%end

%hook _NowPlayingArtView

-(id) initWithFrame:(CGRect)frame {
	id orig = %orig;
	_artView = orig;
	return orig;
}

-(void) layoutSubviews {
	%orig;
	_blurryArtworkView.frame = [UIScreen mainScreen].bounds;
	SBLockScreenScrollView *scrollView = nil;
	UIView *superview = self.superview;
	Class SBLockScreenScrollViewClass = %c(SBLockScreenScrollView);
	while (scrollView == nil) {
		for (UIView *subview in superview.subviews) {
			if ([subview isKindOfClass:SBLockScreenScrollViewClass])
				scrollView = (SBLockScreenScrollView *)subview;
			}
		superview = superview.superview;
		if (superview == nil) {
			break;
		}
	}
	if (_blurryArtworkView.superview != nil)
		[_blurryArtworkView removeFromSuperview];
	if (scrollView != nil)
		[scrollView.superview insertSubview:_blurryArtworkView belowSubview:scrollView];
}

%end
%end

%ctor {
	dlopen("/System/Library/SpringBoardPlugins/NowPlayingArtLockScreen.lockbundle/NowPlayingArtLockScreen", 2);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)ReloadPreferences, CFSTR("org.thebigboss.helius/settings.changed"), NULL, 0);
	CFPreferencesAppSynchronize(CFSTR("org.thebigboss.helius2settings"));
	value2 = CFPreferencesCopyAppValue(CFSTR("artwork"), CFSTR("org.thebigboss.helius2settings"));
	%init;
	//background artwork breaks some tweaks, those users have to disable it and respring so group isnt initiated
	if (((CFBooleanRef)value2 == kCFBooleanTrue)) {
		%init(NowPlayingArtView);
	}
}
