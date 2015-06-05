#import "Headers.h"

@interface Helius : UIView {
	UIView *base;
	UIView *imageViewBase;
	UIImageView *imageView;
	UIButton *playOrPauseButton;
	UIButton *backwardButton;
	UIButton *skipForwardButton;
	UIView *buttonBase;
	UISlider *volumeSlider;
	UILabel *titleLabel;
	UILabel *artistLabel;
	UILabel *albumLabel;
	UILabel *clockLabel;
	UIColor *oppositeColor;
}
@property (nonatomic, retain) UIColor *oppositeColor;
@property (nonatomic, retain) UILabel *clockLabel;
-(void) setPlayPauseButtonImage:(UIImage *)image;
-(UIImage *) colorImage:(UIImage *)image withColor:(UIColor *)color;
@end