#import <SparkColourPickerUtils.h>
#import <SparkColourPickerView.h>
#import <Cephei/HBPreferences.h>
#import <AudioToolbox/AudioServices.h>
#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <spawn.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface UIImpactFeedbackGenerator (Private)
- (id)initWithStyle:(long long)arg1;
- (void)prepare;
- (void)fire;
- (void)impactOccured;
@end

@interface _UILegibilitySettings : NSObject
@property (nonatomic, strong) UIColor *primaryColor;
@end

@interface _UILegibilityLabel : UILabel
@property (nonatomic, strong) _UILegibilitySettings *settings;
@property (nonatomic, retain) NSString *string;
@end

@interface MTMaterialView : UIView
@property (nonatomic, assign) NSInteger recipe;
@property (nonatomic, assign) NSInteger configuration;
@property (nonatomic, strong) NSString *recipeName;
@property (nonatomic, strong) NSString *groupNameBase;
@property (assign,nonatomic) double weighting;
@property (assign,getter=isBlurEnabled,nonatomic) BOOL blurEnabled;
@property (assign,getter=isZoomEnabled,nonatomic) BOOL zoomEnabled;
@property (assign,getter=isInPlaceFilteringEnabled,nonatomic) BOOL inPlaceFilteringEnabled;
+(id) materialViewWithRecipe:(long long)arg1 configuration:(long long)arg2;
- (id)_viewControllerForAncestor;
@end

@interface SBElasticValueViewController : UIViewController
@end

@interface SBElasticVolumeViewController : SBElasticValueViewController
-(void)_updateSliderViewMetricsForState:(long long)arg1 bounds:(CGRect)arg2 integralized:(BOOL)arg3 useSizeSpringData:(BOOL)arg4 useCenterSpringData:(BOOL)arg5;
@property (nonatomic, strong) UIView *OLEDView;
@property (nonatomic,readonly) BOOL volumeUpButtonIsDown;
@property (nonatomic,readonly) BOOL volumeDownButtonIsDown;
-(float)currentVolume;
- (void)volumeChanged:(NSNotification *)notification;
@end

@interface CCUIBaseSliderView : UIControl
@end

@interface CCUIContinuousSliderView : CCUIBaseSliderView
@property (assign,nonatomic) double continuousSliderCornerRadius;
@end

@interface MediaControlsVolumeSliderView : CCUIContinuousSliderView
-(void)setContinuousSliderCornerRadius:(double)arg1;
@end

@interface SBElasticSliderView : MediaControlsVolumeSliderView
@end

@interface SBElasticSliderMaterialWrapperView : UIView
@property (nonatomic,readonly) SBElasticSliderView* sliderView;
@end

@interface SBVolumeControl : NSObject
+(id)sharedInstance;
-(void)changeVolumeByDelta:(float)arg1 ;
- (float)volumeStepUp;
- (float)volumeStepDown;
-(float)_effectiveVolume;
-(void)_presentVolumeHUDWithVolume:(float)arg1 ;
-(void)_updateEffectiveVolume:(float)arg1 ;
-(void)_presentVolumeHUDIfDisplayable:(BOOL)arg1 orRefreshIfPresentedWithReason:(id)arg2 ;
-(void)clearAlwaysHiddenCategories;
-(BOOL)_isHUDDisplayable;
-(void)setActiveCategoryVolume:(float)arg1 ;
-(void)handleVolumeButtonWithType:(long long)arg1 down:(BOOL)arg2;
- (void)increaseVolume;
- (void)decreaseVolume;
@end

@interface SBCoverSheetPresentationManager : NSObject
-(BOOL)isAnyGestureActivelyRecognized;
+ (id)sharedInstance;
- (BOOL)isPresented;
- (BOOL)isTransitioning;
-(BOOL)dismissingCoverSheet;
@end
