#import "Helius.h"
#import "UIImageAverageColorAddition.h"
#import "UIColor+ContrastingColor.h"

//this is Phillips fix for adding support for all phone screen sizes

#define kSixScreenWidth 414
#define kSixScreenHeight 736

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width;
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height;

CGFloat wAdjust(CGFloat value) { return (value/kSixScreenWidth) * kScreenWidth };
CGFloat hAdjust(CGFloat value) { return (value/kSixScreenHeight) * kScreenHeight };

@implementation Helius

@synthesize oppositeColor, clockLabel;

//setting up stuff, good luck reading

-(id) initWithFrame:(CGRect)frame {
	frame = [[UIScreen mainScreen] bounds];
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
		base = [[UIView alloc] init];
		base.backgroundColor = [UIColor grayColor];
		base.layer.cornerRadius = 18;
		[base setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin)];
		[self addSubview:base];
		imageViewBase = [[UIView alloc] init];
		imageViewBase.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:.5];
		[base addSubview:imageViewBase];
		imageView = [[UIImageView alloc] init];
		[imageView setClipsToBounds:1];
		imageView.contentMode = UIViewContentModeScaleAspectFill;
		[imageViewBase addSubview:imageView];
		buttonBase = [[UIView alloc] init];
		buttonBase.backgroundColor = [UIColor clearColor];
		[base addSubview:buttonBase];
		playOrPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[playOrPauseButton addTarget:self action:@selector(playOrPauseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		[playOrPauseButton setImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Helius2/play.png"] forState:UIControlStateNormal];
		[buttonBase addSubview:playOrPauseButton];
		skipForwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[skipForwardButton addTarget:self action:@selector(skipForwardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		[skipForwardButton setImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Helius2/forward.png"] forState:UIControlStateNormal];
		[buttonBase addSubview:skipForwardButton];
		UILongPressGestureRecognizer *longPress= [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressForward:)];
		[skipForwardButton addGestureRecognizer:longPress];
		backwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[backwardButton addTarget:self action:@selector(backwardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		[backwardButton setImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Helius2/back.png"] forState:UIControlStateNormal];
		[buttonBase addSubview:backwardButton];
		UILongPressGestureRecognizer *longPress2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressBackward:)];
		[backwardButton addGestureRecognizer:longPress2];
		volumeSlider = [[UISlider alloc] init];
		volumeSlider.minimumValue = 0;
		volumeSlider.maximumValue = 1;
		CGRect rect = CGRectMake(0, 0, 1, 1);
		UIGraphicsBeginImageContextWithOptions(rect.size, 0, 0);
		[[UIColor blackColor] setFill];
		UIRectFill(rect);
		UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		[volumeSlider setMinimumTrackImage:image forState:UIControlStateNormal];
		CGRect rect2 = CGRectMake(0, 0, 1, 1);
		UIGraphicsBeginImageContextWithOptions(rect2.size, 0, 0);
		[[UIColor grayColor] setFill];
		UIRectFill(rect2);
		UIImage *image2 = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		[volumeSlider setMaximumTrackImage:image2 forState:UIControlStateNormal];
		float volume = 0.0;
		//getting volume for music
		[[AVSystemController sharedAVSystemController] getVolume:&volume forCategory:@"Audio/Video"];
		volumeSlider.value = volume;
		[volumeSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
		[base addSubview:volumeSlider];
		clockLabel = [[UILabel alloc] init];
		[clockLabel setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin)];
		[clockLabel setBackgroundColor:[UIColor clearColor]];
		clockLabel.opaque = 1;
		clockLabel.textColor = [UIColor whiteColor];
		//add a shadow to clock text for legibility on white backgrounds
		clockLabel.layer.shadowColor = [UIColor blackColor].CGColor;
		clockLabel.layer.shadowOffset = CGSizeMake(0, 0);
		clockLabel.layer.shadowOpacity = .3;
		clockLabel.layer.shadowRadius = 5;
		[clockLabel setTextAlignment:NSTextAlignmentCenter];
		clockLabel.textColor = [UIColor whiteColor];
		clockLabel.frame = CGRectMake(wAdjust(7), hAdjust(30), self.frame.size.width-wAdjust(14), hAdjust(90));
		//stealing the lock screen clocks font :) works with custom fonts to
		clockLabel.font = [[(SBLockScreenView *)[(SBLockScreenViewController *)[(SBLockScreenManager *)[objc_getClass("SBLockScreenManager") sharedInstance] lockScreenViewController] view] dateView] _timeFont];
		[self addSubview:clockLabel];
		artistLabel = [[UILabel alloc] init];
		[artistLabel setBackgroundColor:[UIColor clearColor]];
		artistLabel.opaque = 1;
		[artistLabel setTextAlignment:NSTextAlignmentCenter];
		artistLabel.textColor = [UIColor whiteColor];
		artistLabel.text = @"Unknown";
		artistLabel.font = [UIFont fontWithName:@"HelveticaNeue-ThinItalic" size:15];
		//using UILabel private API for scrolling labels, see Headers.h file
		[artistLabel setMarqueeEnabled:1];
		[artistLabel setMarqueeRunning:1];
		[base addSubview:artistLabel];
		titleLabel = [[UILabel alloc] init];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		titleLabel.opaque = 1;
		titleLabel.textColor = [UIColor whiteColor];
		[titleLabel setTextAlignment:NSTextAlignmentCenter];
		titleLabel.text = @"Untitled";
		titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:20];
		[titleLabel setMarqueeEnabled:1];
		[titleLabel setMarqueeRunning:1];
		[base addSubview:titleLabel];
		albumLabel = [[UILabel alloc] init];
		[albumLabel setBackgroundColor:[UIColor clearColor]];
		albumLabel.opaque = 1;
		albumLabel.textColor = [UIColor whiteColor];
		[albumLabel setTextAlignment:NSTextAlignmentCenter];
		albumLabel.text = @"Untitled";
		albumLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:15];
		[albumLabel setMarqueeEnabled:1];
		[albumLabel setMarqueeRunning:1];
		[base addSubview:albumLabel];
		[self frames];
		
		//notifcation for volume change
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVolume:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
		//notifcation for media info changing
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMedia) name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
	}
	return self;
}

//create a sharedInstance

+(id) sharedInstance {
	static Helius *h = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		h = [[Helius alloc] init];
	});
	return h;
}

//update our labels and artwork
-(void) updateMedia {
	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef result) {
		__block UIImage *nowPlayingImage = [UIImage imageWithData:[(__bridge NSDictionary *)result objectForKey:(NSData *)(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData]] ? [UIImage imageWithData:[(__bridge NSDictionary *)result objectForKey:(NSData *)(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData]] : [[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Helius2/noalbum.png"];
		base.backgroundColor = [nowPlayingImage mergedColor];
		imageViewBase.backgroundColor = [self darkerColorForColor:base.backgroundColor];
		[UIView transitionWithView:imageView duration:.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
			imageView.image = nowPlayingImage;
			artistLabel.text = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist] ? [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist] : @"Unknown";
			titleLabel.text = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle] ? [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle] : @"Untitled";
			albumLabel.text = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoAlbum] ? [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoAlbum] : @"Untitled";
		} completion:nil];
		self.oppositeColor = [base.backgroundColor sqf_contrastingColorWithMethod:SQFContrastingColorYIQMethod];
		[self colorViewsWithColor:self.oppositeColor];
	});
}

//toggle play/pause, using MediaRemote, you can guess what the rest of these functions do
-(void) playOrPauseButtonPressed {
	MRMediaRemoteSendCommand(2, nil);
}

-(void) skipForwardButtonPressed {
	MRMediaRemoteSendCommand(4, nil);
}

-(void) backwardButtonPressed {
	MRMediaRemoteSendCommand(5, nil);
}

-(void) longPressForward:(UILongPressGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		MRMediaRemoteSendCommand(8, nil);
	}
	if (recognizer.state == UIGestureRecognizerStateEnded) {
		MRMediaRemoteSendCommand(9, nil);
	}
}

-(void) longPressBackward:(UILongPressGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		MRMediaRemoteSendCommand(10, nil);
	}
	if (recognizer.state == UIGestureRecognizerStateEnded) {
		MRMediaRemoteSendCommand(11, nil);
	}
}

//our slider was changed, update system volume
-(void) sliderChanged:(UISlider *)sender{
	if ([sender isEqual:volumeSlider]){
		[[AVSystemController sharedAVSystemController] setVolumeTo:sender.value forCategory:@"Audio/Video"];
	}
}

//volume was changed, update our slider
-(void) updateVolume:(NSNotification *)notification {
	volumeSlider.value = [notification.userInfo[@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
}

-(void) setPlayPauseButtonImage:(UIImage *)image {
	[playOrPauseButton setImage:[self colorImage:image withColor:self.oppositeColor] forState:UIControlStateNormal];
}

-(UIImage *) colorImage:(UIImage *)image withColor:(UIColor *)color {
	CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClipToMask(context, rect, image.CGImage);
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	UIImage *flippedImage = [UIImage imageWithCGImage:img.CGImage scale:1.0 orientation:UIImageOrientationDownMirrored];
	return flippedImage;
}

-(void) colorViewsWithColor:(UIColor *)color {
	titleLabel.textColor = color;
	artistLabel.textColor = color;
	albumLabel.textColor = color;
	[backwardButton setImage:[self colorImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Helius2/back.png"] withColor:color] forState:UIControlStateNormal];
	[skipForwardButton setImage:[self colorImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Helius2/forward.png"] withColor:color] forState:UIControlStateNormal];
}

-(UIImage *) clippedImageForRect:(CGRect)clipRect inView:(UIView *)view {
	UIGraphicsBeginImageContextWithOptions(clipRect.size, 1, 1.f);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(ctx, -clipRect.origin.x, -clipRect.origin.y);
	[view.layer renderInContext:ctx];
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return img;
}

-(UIColor *) darkerColorForColor:(UIColor *)c {
	CGFloat r, g, b, a;
	if ([c getRed:&r green:&g blue:&b alpha:&a]) {
		return [UIColor colorWithRed:MAX(r - 0.2, 0.0) green:MAX(g - 0.2, 0.0) blue:MAX(b - 0.2, 0.0) alpha:a];
	}
	return c;
}

//setting my frames all here
-(void) frames {
	base.frame = CGRectMake(wAdjust(60), hAdjust(150), self.frame.size.width-wAdjust(120), (([[UIScreen mainScreen] bounds].size.height == 480) ? 345 : hAdjust(455)));
	imageViewBase.frame = CGRectMake(wAdjust(0), hAdjust(75), base.frame.size.width, base.frame.size.width);
	imageView.frame = CGRectMake(wAdjust(18), hAdjust(18), imageViewBase.frame.size.width-wAdjust(36), imageViewBase.frame.size.width-hAdjust(36));
	buttonBase.frame = CGRectMake(wAdjust(0), (([[UIScreen mainScreen] bounds].size.height == 480) ? 315 : hAdjust(410)), base.frame.size.width, hAdjust(30));
	playOrPauseButton.frame = CGRectMake(buttonBase.frame.size.width/2 - wAdjust(15), 0, wAdjust(30), hAdjust(30));
	skipForwardButton.frame = CGRectMake(buttonBase.frame.size.width/2+wAdjust(60), 0, wAdjust(30), hAdjust(30));
	backwardButton.frame = CGRectMake(buttonBase.frame.size.width/2-wAdjust(60+25), 0, wAdjust(30), hAdjust(30));
	volumeSlider.frame = CGRectMake(wAdjust(15), (([[UIScreen mainScreen] bounds].size.height == 480) ? 287 : hAdjust(380)), base.frame.size.width-wAdjust(30), hAdjust(25));
	artistLabel.frame = CGRectMake(wAdjust(15), hAdjust(5), base.frame.size.width-wAdjust(30), hAdjust(20));
	titleLabel.frame = CGRectMake(wAdjust(15), hAdjust(22), base.frame.size.width-wAdjust(30), hAdjust(32));
	albumLabel.frame = CGRectMake(wAdjust(15), hAdjust(50), base.frame.size.width-wAdjust(30), hAdjust(20));
}

@end
