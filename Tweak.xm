#import "Tweak.h"

static NSMutableDictionary *colorDictionary;
static NSString *nsNotificationString = @"com.nahtedetihw.volvibes.color/preferences.changed";

HBPreferences *preferences;
BOOL enabled;
BOOL useOLEDMode;
BOOL nukeHUD;
BOOL colorVolSlider;
BOOL hideGlyph;
BOOL volPercent;
BOOL colorVolTopSlider;
NSInteger feedbackStyle;
NSInteger hudStyle;
NSInteger feedbackSelection;
NSNumber * volumeStepper;
NSNumber * volumeStepperHeadphones;
BOOL enableSliderCornerRadius;

double customDimAlpha;
double customDismissTime;
double customLandscapeLargeHUDCornerRadius;
double customLandscapeMiniHUDCornerRadius;
double customLandscapeGiantHUDCornerRadius;
double customPortraitLargeHUDCornerRadius;
double customPortraitMiniHUDCornerRadius;
double customPortraitGiantHUDCornerRadius;
double customLandscapeLargeHUDWidth;
double customLandscapeLargeHUDHeight;
double customLandscapeMiniHUDWidth;
double customLandscapeMiniHUDHeight;
double customLandscapeGiantHUDWidth;
double customLandscapeGiantHUDHeight;
double customPortraitLargeHUDWidth;
double customPortraitLargeHUDHeight;
double customPortraitMiniHUDWidth;
double customPortraitMiniHUDHeight;
double customPortraitGiantHUDWidth;
double customPortraitGiantHUDHeight;
double customHUDYOffset;

static void feedbackcall() {
    UIImpactFeedbackGenerator * feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:(int)feedbackSelection];
    [feedback prepare];
    [feedback impactOccurred];
}

BOOL isPlayingOnBuiltInSpeaker() {
    NSArray *availableOutputs = [[AVAudioSession sharedInstance] currentRoute].outputs;
    for (AVAudioSessionPortDescription *portDescription in availableOutputs) {
        if ([portDescription.portType isEqualToString:AVAudioSessionPortBuiltInSpeaker]) {
            return YES;
        }
    }
    return NO;
}

%group VolVibes1314
%hook SBElasticSliderView
-(id)initWithFrame:(CGRect)arg1 {
    self = %orig;
    if (colorVolSlider) {
        self.backgroundColor = [SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"colorVolSliderKey"] withFallback:@"#777777"];
        MTMaterialView *backgroundView = MSHookIvar<MTMaterialView *>(self, "_backgroundView");
        backgroundView.hidden = YES;
    }
    if (colorVolTopSlider) {
        UIView *valueIndicatorClippingView = MSHookIvar<UIView *>(self, "_valueIndicatorClippingView");
        valueIndicatorClippingView.backgroundColor = [SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"colorVolTopSliderKey"] withFallback:@"#ffffff"];
        
        for (MTMaterialView *topMaterialView in valueIndicatorClippingView.subviews) {
            topMaterialView.hidden = YES;
        }
    }
    return self;
}

-(void)setContinuousSliderCornerRadius:(double)arg1 {
    %orig;
    if (enableSliderCornerRadius) {
        UIView *valueIndicatorClippingView2 = MSHookIvar<UIView *>(self, "_valueIndicatorClippingView");
        valueIndicatorClippingView2.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        valueIndicatorClippingView2.layer.cornerRadius = self.continuousSliderCornerRadius;
        valueIndicatorClippingView2.layer.masksToBounds = YES;
        valueIndicatorClippingView2.clipsToBounds = YES;
        valueIndicatorClippingView2.superview.clipsToBounds = YES;
        self.clipsToBounds = YES;
    } else {
        UIView *valueIndicatorClippingView3 = MSHookIvar<UIView *>(self, "_valueIndicatorClippingView");
        valueIndicatorClippingView3.layer.masksToBounds = YES;
        valueIndicatorClippingView3.clipsToBounds = YES;
        valueIndicatorClippingView3.superview.clipsToBounds = YES;
        self.clipsToBounds = YES;
    }
}

// Hide glyphs
-(void)stopGlyphAnimations {
    %orig;
    if (hideGlyph) {
        if ([self valueForKey:@"_glyphPackageView"]) {
            UIView *glyphView = (UIView *)[self valueForKey:@"_glyphPackageView"];
            glyphView.hidden = YES;
        }
        if ([self valueForKey:@"_compensatingGlyphPackageView"]) {
            UIView *compensatingGlyphView = [self valueForKey:@"_compensatingGlyphPackageView"];
            compensatingGlyphView.hidden = YES;
        }
    }
}
%end


%hook SBElasticVolumeViewController
%property (nonatomic, strong) UIView *OLEDView;
- (void)viewDidLoad {
    %orig;
    
    if (useOLEDMode) {
        self.OLEDView = [[UIView alloc] initWithFrame:self.view.frame];
        self.OLEDView.alpha = 0;
        self.OLEDView.backgroundColor = [UIColor blackColor];
        [self.view insertSubview:self.OLEDView atIndex:0];
        
        self.OLEDView.translatesAutoresizingMaskIntoConstraints = false;
        [self.OLEDView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0].active = YES;
        [self.OLEDView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:0].active = YES;
        [self.OLEDView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:0].active = YES;
        [self.OLEDView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:0].active = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    
    if (useOLEDMode) {
        [UIView animateWithDuration:1.0 animations:^{
            self.OLEDView.alpha = 1;
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    %orig;
    
    if (useOLEDMode) {
        [UIView animateWithDuration:1.0 animations:^{
            self.OLEDView.alpha = 0;
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    %orig;
    
    if (useOLEDMode) {
        [UIView animateWithDuration:1.0 animations:^{
            self.OLEDView.alpha = 0;
        }];
    }
}

-(BOOL)_canShowWhileLocked {
    return YES;
}

// Change persistant state of volume hud size
-(void)_updateSliderViewMetricsForState:(long long)arg1 bounds:(CGRect)arg2 integralized:(BOOL)arg3 useSizeSpringData:(BOOL)arg4 useCenterSpringData:(BOOL)arg5 {
    if (hudStyle == 0) {
        %orig;
    } else if (hudStyle == 1) {
        %orig(2, arg2, arg3, arg4, arg5);
    } else if (hudStyle == 2) {
        %orig(1, arg2, arg3, arg4, arg5);
    } else if (hudStyle == 3) {
        %orig(3, arg2, arg3, arg4, arg5);
    }
}

-(void)_continueTrackingWithGestureRecognizer:(id)arg1 {
    %orig;
    if (hudStyle == 0) {
        MSHookIvar<long long>(self, "_state") = 0;
        [self _updateSliderViewMetricsForState:0 bounds:self.view.bounds integralized:YES useSizeSpringData:YES useCenterSpringData:YES];
    } else if (hudStyle == 1) {
        MSHookIvar<long long>(self, "_state") = 2;
        [self _updateSliderViewMetricsForState:2 bounds:self.view.bounds integralized:YES useSizeSpringData:YES useCenterSpringData:YES];
    } else if (hudStyle == 2) {
        MSHookIvar<long long>(self, "_state") = 1;
        [self _updateSliderViewMetricsForState:1 bounds:self.view.bounds integralized:YES useSizeSpringData:YES useCenterSpringData:YES];
    } else if (hudStyle == 3) {
        MSHookIvar<long long>(self, "_state") = 3;
        [self _updateSliderViewMetricsForState:3 bounds:self.view.bounds integralized:YES useSizeSpringData:YES useCenterSpringData:YES];
    }
}

// Change label during volume presses
-(void)_updateViewsWithSpringData {
    %orig;
    if (volPercent) {
        _UILegibilityLabel *leadingLabel = MSHookIvar<_UILegibilityLabel *>(self, "_leadingLabel");
        CGFloat myFloat = [self currentVolume];
        leadingLabel.string = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:myFloat] numberStyle:NSNumberFormatterPercentStyle];
        leadingLabel.settings.primaryColor = [SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"volPercentLabelColorKey"] withFallback:@"#ffffff"];
    }
}

-(void)_beginDeflatorDismissalSpringAnimation {
    %orig;
    _UILegibilityLabel *leadingLabel = MSHookIvar<_UILegibilityLabel *>(self, "_leadingLabel");
    [UIView animateWithDuration:1.0 animations:^{
        leadingLabel.alpha = 0;
    }];
    
    if (useOLEDMode) {
        [UIView animateWithDuration:1.0 animations:^{
            self.OLEDView.alpha = 0;
        }];
    }
}

// Change label during sliding gesture
-(void)_updateVolumeLevelSlider:(float)arg1 animated:(BOOL)arg2 {
    %orig;
    if (volPercent) {
        _UILegibilityLabel *leadingLabel = MSHookIvar<_UILegibilityLabel *>(self, "_leadingLabel");
        leadingLabel.alpha = 1;
        CGFloat myFloat = [self currentVolume];
        leadingLabel.string = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:myFloat] numberStyle:NSNumberFormatterPercentStyle];
        leadingLabel.settings.primaryColor = [SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"volPercentLabelColorKey"] withFallback:@"#ffffff"];
    }
}

// Add vibrations
-(void)noteVolumeUpWasHit:(BOOL)arg1 {
    
    switch (feedbackStyle) {

        case 0:
        feedbackSelection = UIImpactFeedbackStyleSoft;
        feedbackcall();
        break;

        case 1:
        feedbackSelection = UIImpactFeedbackStyleLight;
        feedbackcall();
        break;

        case 2:
        feedbackSelection = UIImpactFeedbackStyleMedium;
        feedbackcall();
        break;
        
        case 3:
        feedbackSelection = UIImpactFeedbackStyleHeavy;
        feedbackcall();
        break;

        case 4:
        break;

        default:
        break;

    }
    %orig;
}

-(void)noteVolumeDownWasHit:(BOOL)arg1 {
    switch (feedbackStyle) {

        case 0:
        feedbackSelection = UIImpactFeedbackStyleSoft;
        feedbackcall();
        break;

        case 1:
        feedbackSelection = UIImpactFeedbackStyleLight;
        feedbackcall();
        break;

        case 2:
        feedbackSelection = UIImpactFeedbackStyleMedium;
        feedbackcall();
        break;
        
        case 3:
        feedbackSelection = UIImpactFeedbackStyleHeavy;
        feedbackcall();
        break;

        case 4:
        break;

        default:
        break;

    }
    %orig;
}
%end

%hook SBVolumeControl

- (void)decreaseVolume {
    %orig;
    
    // when volume is decreased, set the volume to current volume minus our custom step amount
    if ([volumeStepper floatValue]/100 >= 0) { // don't let volume % go below 0
        if (isPlayingOnBuiltInSpeaker() == YES) {
            [self setActiveCategoryVolume:[self _effectiveVolume]-[volumeStepper floatValue]/100];
        } else {
            [self setActiveCategoryVolume:[self _effectiveVolume]-[volumeStepperHeadphones floatValue]/100];
        }
    }
    
}
- (void)increaseVolume {
    %orig;
    
    // when volume is increased, set the volume to current volume plus our custom step amount
    if ([volumeStepper floatValue]/100 <= 100) { // don't let volume % go above 100
        if (isPlayingOnBuiltInSpeaker() == YES) {
            [self setActiveCategoryVolume:[self _effectiveVolume]+[volumeStepper floatValue]/100];
        } else {
            [self setActiveCategoryVolume:[self _effectiveVolume]+[volumeStepperHeadphones floatValue]/100];
        }
    }
    
}

- (void)changeVolumeByDelta:(float)arg1 {
    //remove orig value so we can make our own
}

- (float)volumeStepUp {
    return 0; // set this to 0 to let volume go below 6%
}

- (float)volumeStepDown {
    return 0; // set this to 0 to let volume go below 6%
}

%end

%hook SBVolumeHUDViewController

// Hide volume hud
-(void)viewDidLoad {
if (nukeHUD) {
}
else %orig;
}
%end

%hook SBVolumeHUDSettings
- (float)volumeStepDelta {
    return 0; // set this to 0 to let volume go below 6%
}
-(double)dimmingAlpha {
    return customDimAlpha;
}
-(double)dismissalInterval {
    return customDismissTime;
}
-(double)landscapeStateBaseCornerRadius {
    return customLandscapeLargeHUDCornerRadius;
}
-(double)landscapeState1CornerRadius {
    return customLandscapeLargeHUDCornerRadius;
}
-(double)landscapeState2CornerRadius {
    return customLandscapeMiniHUDCornerRadius;
}
-(double)landscapeState3CornerRadius {
    return customLandscapeGiantHUDCornerRadius;
}
-(double)portraitStateBaseCornerRadius {
    return customPortraitLargeHUDCornerRadius;
}
-(double)portraitState1CornerRadius {
    return customPortraitLargeHUDCornerRadius;
}
-(double)portraitState2CornerRadius {
    return customPortraitMiniHUDCornerRadius;
}
-(double)portraitState3CornerRadius {
    return customPortraitGiantHUDCornerRadius;
}
-(double)landscapeState1Width {
    return customLandscapeLargeHUDWidth;
}
-(double)landscapeState1Height {
    return customLandscapeLargeHUDHeight;
}
-(double)landscapeState2Width {
    return customLandscapeMiniHUDWidth;
}
-(double)landscapeState2Height {
    return customLandscapeMiniHUDHeight;
}
-(double)landscapeState3Width {
    return customLandscapeGiantHUDWidth;
}
-(double)landscapeState3Height {
    return customLandscapeGiantHUDHeight;
}
-(double)portraitState1Width {
    return customPortraitLargeHUDWidth;
}
-(double)portraitState1Height {
    return customPortraitLargeHUDHeight;
}
-(double)portraitState2Width {
    return customPortraitMiniHUDWidth;
}
-(double)portraitState2Height {
    return customPortraitMiniHUDHeight;
}
-(double)portraitState3Width {
    return customPortraitGiantHUDWidth;
}
-(double)portraitState3Height {
    return customPortraitGiantHUDHeight;
}
-(double)volumeButtonsCenterY {
    return customHUDYOffset;
}
%end
%end

%group VolVibes1516
%hook SBElasticValueViewController
-(void)noteButtonUpWasHit:(BOOL)arg1 {
    %orig;
    
    switch (feedbackStyle) {
        case 0:
            feedbackSelection = UIImpactFeedbackStyleSoft;
            feedbackcall();
        break;

        case 1:
            feedbackSelection = UIImpactFeedbackStyleLight;
            feedbackcall();
        break;

        case 2:
            feedbackSelection = UIImpactFeedbackStyleMedium;
            feedbackcall();
        break;
        
        case 3:
            feedbackSelection = UIImpactFeedbackStyleHeavy;
            feedbackcall();
        break;

        case 4:
        break;

        default:
        break;
    }
    
}

-(void)noteButtonDownWasHit:(BOOL)arg1 {
    %orig;
    
    switch (feedbackStyle) {
        case 0:
            feedbackSelection = UIImpactFeedbackStyleSoft;
            feedbackcall();
        break;

        case 1:
            feedbackSelection = UIImpactFeedbackStyleLight;
            feedbackcall();
        break;

        case 2:
            feedbackSelection = UIImpactFeedbackStyleMedium;
            feedbackcall();
        break;
        
        case 3:
            feedbackSelection = UIImpactFeedbackStyleHeavy;
            feedbackcall();
        break;

        case 4:
        break;

        default:
        break;
    }
}
%end

%hook SBElasticVolumeViewController
%property (nonatomic, strong) UIView *OLEDView;
- (void)viewDidLoad {
    %orig;
    
    if (useOLEDMode) {
        self.OLEDView = [[UIView alloc] initWithFrame:self.view.frame];
        self.OLEDView.alpha = 0;
        self.OLEDView.backgroundColor = [UIColor blackColor];
        [self.view insertSubview:self.OLEDView atIndex:0];
        
        self.OLEDView.translatesAutoresizingMaskIntoConstraints = false;
        [self.OLEDView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0].active = YES;
        [self.OLEDView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:0].active = YES;
        [self.OLEDView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:0].active = YES;
        [self.OLEDView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:0].active = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    
    if (useOLEDMode) {
        [UIView animateWithDuration:1.0 animations:^{
            self.OLEDView.alpha = 1;
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    %orig;
    
    if (useOLEDMode) {
        [UIView animateWithDuration:1.0 animations:^{
            self.OLEDView.alpha = 0;
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    %orig;
    
    if (useOLEDMode) {
        [UIView animateWithDuration:1.0 animations:^{
            self.OLEDView.alpha = 0;
        }];
    }
}

-(BOOL)_canShowWhileLocked {
    return YES;
}

// Change persistant state of volume hud size
-(void)_updateSliderViewMetricsForState:(long long)arg1 bounds:(CGRect)arg2 integralized:(BOOL)arg3 useSizeSpringData:(BOOL)arg4 useCenterSpringData:(BOOL)arg5 {
    if (hudStyle == 0) {
        %orig;
    } else if (hudStyle == 1) {
        %orig(2, arg2, arg3, arg4, arg5);
    } else if (hudStyle == 2) {
        %orig(1, arg2, arg3, arg4, arg5);
    } else if (hudStyle == 3) {
        %orig(3, arg2, arg3, arg4, arg5);
    }
}

-(void)_continueTrackingWithGestureRecognizer:(id)arg1 {
    %orig;
    if (hudStyle == 0) {
        MSHookIvar<long long>(self, "_state") = 0;
        [self _updateSliderViewMetricsForState:0 bounds:self.view.bounds integralized:YES useSizeSpringData:YES useCenterSpringData:YES];
    } else if (hudStyle == 1) {
        MSHookIvar<long long>(self, "_state") = 2;
        [self _updateSliderViewMetricsForState:2 bounds:self.view.bounds integralized:YES useSizeSpringData:YES useCenterSpringData:YES];
    } else if (hudStyle == 2) {
        MSHookIvar<long long>(self, "_state") = 1;
        [self _updateSliderViewMetricsForState:1 bounds:self.view.bounds integralized:YES useSizeSpringData:YES useCenterSpringData:YES];
    } else if (hudStyle == 3) {
        MSHookIvar<long long>(self, "_state") = 3;
        [self _updateSliderViewMetricsForState:3 bounds:self.view.bounds integralized:YES useSizeSpringData:YES useCenterSpringData:YES];
    }
}

// Change label during volume presses
-(void)_updateViewsWithSpringData {
    %orig;
    if (volPercent) {
        _UILegibilityLabel *leadingLabel = MSHookIvar<_UILegibilityLabel *>(self, "_leadingLabel");
        CGFloat myFloat = [self currentVolume];
        leadingLabel.string = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:myFloat] numberStyle:NSNumberFormatterPercentStyle];
        leadingLabel.settings.primaryColor = [SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"volPercentLabelColorKey"] withFallback:@"#ffffff"];
    }
}

-(void)_beginDeflatorDismissalSpringAnimation {
    %orig;
    _UILegibilityLabel *leadingLabel = MSHookIvar<_UILegibilityLabel *>(self, "_leadingLabel");
    [UIView animateWithDuration:1.0 animations:^{
        leadingLabel.alpha = 0;
    }];
    
    if (useOLEDMode) {
        [UIView animateWithDuration:1.0 animations:^{
            self.OLEDView.alpha = 0;
        }];
    }
}

// Change label during sliding gesture
-(void)_updateVolumeLevelSlider:(float)arg1 animated:(BOOL)arg2 {
    %orig;
    
    if (volPercent) {
        _UILegibilityLabel *leadingLabel = MSHookIvar<_UILegibilityLabel *>(self, "_leadingLabel");
        leadingLabel.alpha = 1;
        CGFloat myFloat = [self currentVolume];
        leadingLabel.string = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithFloat:myFloat] numberStyle:NSNumberFormatterPercentStyle];
        leadingLabel.settings.primaryColor = [SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"volPercentLabelColorKey"] withFallback:@"#ffffff"];
    }
}
%end

%hook MTMaterialView
-(void)_updateRecipeNameIfNeeded {
    %orig;
    if ([self.recipeName isEqual:@"elasticHUDBackground"]) {
        if (colorVolSlider) {
            self.backgroundColor = [SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"colorVolSliderKey"] withFallback:@"#777777"];
        }
    }
    if ([self.recipeName isEqual:@"modules"] && [NSStringFromClass([self.superview class]) isEqualToString:@"SBElasticSliderView"]) {
        if (colorVolTopSlider) {
            self.backgroundColor = [SparkColourPickerUtils colourWithString:[colorDictionary objectForKey:@"colorVolTopSliderKey"] withFallback:@"#ffffff"];
        }
    }
}
%end

%hook SBElasticSliderView
// Hide glyphs
-(void)stopGlyphAnimations {
    %orig;
    if (hideGlyph) {
        if ([self valueForKey:@"_glyphPackageView"]) {
            UIView *glyphView = (UIView *)[self valueForKey:@"_glyphPackageView"];
            glyphView.hidden = YES;
        }
        if ([self valueForKey:@"_compensatingGlyphPackageView"]) {
            UIView *compensatingGlyphView = [self valueForKey:@"_compensatingGlyphPackageView"];
            compensatingGlyphView.hidden = YES;
        }
    }
}
%end

%hook SBVolumeControl
- (void)decreaseVolume {
    %orig;
    // when volume is decreased, set the volume to current volume minus our custom step amount
    if ([volumeStepper floatValue]/100 >= 0) { // don't let volume % go below 0
        if (isPlayingOnBuiltInSpeaker() == YES) {
            [self setActiveCategoryVolume:[self _effectiveVolume]-[volumeStepper floatValue]/100];
        } else {
            [self setActiveCategoryVolume:[self _effectiveVolume]-[volumeStepperHeadphones floatValue]/100];
        }
    }
}
- (void)increaseVolume {
    %orig;
    // when volume is increased, set the volume to current volume plus our custom step amount
    if ([volumeStepper floatValue]/100 <= 100) { // don't let volume % go above 100
        if (isPlayingOnBuiltInSpeaker() == YES) {
            [self setActiveCategoryVolume:[self _effectiveVolume]+[volumeStepper floatValue]/100];
        } else {
            [self setActiveCategoryVolume:[self _effectiveVolume]+[volumeStepperHeadphones floatValue]/100];
        }
    }
}

- (void)changeVolumeByDelta:(float)arg1 {
    //remove orig value so we can make our own
}

- (float)volumeStepUp {
    return 0; // set this to 0 to let volume go below 6%
}

- (float)volumeStepDown {
    return 0; // set this to 0 to let volume go below 6%
}
%end

%hook SBVolumeHUDViewController
// Hide volume hud
-(void)viewDidLoad {
if (nukeHUD) {
}
else %orig;
}
%end

%hook SBElasticHUDSettings
- (float)volumeStepDelta {
    return 0; // set this to 0 to let volume go below 6%
}
-(double)dimmingAlpha {
    return customDimAlpha;
}
-(double)dismissalInterval {
    return customDismissTime;
}
-(double)landscapeStateBaseCornerRadius {
    return customLandscapeLargeHUDCornerRadius;
}
-(double)landscapeState1CornerRadius {
    return customLandscapeLargeHUDCornerRadius;
}
-(double)landscapeState2CornerRadius {
    return customLandscapeMiniHUDCornerRadius;
}
-(double)landscapeState3CornerRadius {
    return customLandscapeGiantHUDCornerRadius;
}
-(double)portraitStateBaseCornerRadius {
    return customPortraitLargeHUDCornerRadius;
}
-(double)portraitState1CornerRadius {
    return customPortraitLargeHUDCornerRadius;
}
-(double)portraitState2CornerRadius {
    return customPortraitMiniHUDCornerRadius;
}
-(double)portraitState3CornerRadius {
    return customPortraitGiantHUDCornerRadius;
}
-(double)landscapeState1Width {
    return customLandscapeLargeHUDWidth;
}
-(double)landscapeState1Height {
    return customLandscapeLargeHUDHeight;
}
-(double)landscapeState2Width {
    return customLandscapeMiniHUDWidth;
}
-(double)landscapeState2Height {
    return customLandscapeMiniHUDHeight;
}
-(double)landscapeState3Width {
    return customLandscapeGiantHUDWidth;
}
-(double)landscapeState3Height {
    return customLandscapeGiantHUDHeight;
}
-(double)portraitState1Width {
    return customPortraitLargeHUDWidth;
}
-(double)portraitState1Height {
    return customPortraitLargeHUDHeight;
}
-(double)portraitState2Width {
    return customPortraitMiniHUDWidth;
}
-(double)portraitState2Height {
    return customPortraitMiniHUDHeight;
}
-(double)portraitState3Width {
    return customPortraitGiantHUDWidth;
}
-(double)portraitState3Height {
    return customPortraitGiantHUDHeight;
}
-(double)volumeButtonsCenterY {
    return customHUDYOffset;
}
%end
%end

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    // Notification for colors
    colorDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/private/var/mobile/Library/Preferences/com.nahtedetihw.volvibes.color.plist"];
}

%ctor {
    
    notificationCallback(NULL, NULL, NULL, NULL, NULL);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)nsNotificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);

    preferences = [[HBPreferences alloc] initWithIdentifier:@"com.nahtedetihw.volvibes"];
    [preferences registerBool:&enabled default:NO forKey:@"enabled"];
    [preferences registerBool:&useOLEDMode default:NO forKey:@"useOLEDMode"];
    [preferences registerInteger:&feedbackStyle default:0 forKey:@"feedbackStyle"];
    [preferences registerInteger:&hudStyle default:0 forKey:@"hudStyle"];
    [preferences registerBool:&nukeHUD default:NO forKey:@"nukeHUD"];
    [preferences registerBool:&colorVolSlider default:NO forKey:@"colorVolSlider"];
    [preferences registerObject:&volumeStepper default:[NSNumber numberWithInt:16] forKey:@"volumeStepper"];
    [preferences registerObject:&volumeStepperHeadphones default:[NSNumber numberWithInt:16] forKey:@"volumeStepperHeadphones"];
    [preferences registerBool:&hideGlyph default:NO forKey:@"hideGlyph"];
    [preferences registerBool:&volPercent default:NO forKey:@"volPercent"];
    [preferences registerBool:&colorVolTopSlider default:NO forKey:@"colorVolTopSlider"];
    [preferences registerBool:&enableSliderCornerRadius default:NO forKey:@"enableSliderCornerRadius"];
    
    [preferences registerDouble:&customDimAlpha default:0.18 forKey:@"customDimAlpha"];
    [preferences registerDouble:&customDismissTime default:1 forKey:@"customDismissTime"];
    [preferences registerDouble:&customLandscapeLargeHUDCornerRadius default:11 forKey:@"customLandscapeLargeHUDCornerRadius"];
    [preferences registerDouble:&customLandscapeMiniHUDCornerRadius default:2.5 forKey:@"customLandscapeMiniHUDCornerRadius"];
    [preferences registerDouble:&customLandscapeGiantHUDCornerRadius default:13 forKey:@"customLandscapeGiantHUDCornerRadius"];
    [preferences registerDouble:&customPortraitLargeHUDCornerRadius default:15 forKey:@"customPortraitLargeHUDCornerRadius"];
    [preferences registerDouble:&customPortraitMiniHUDCornerRadius default:3.5 forKey:@"customPortraitMiniHUDCornerRadius"];
    [preferences registerDouble:&customPortraitGiantHUDCornerRadius default:18 forKey:@"customPortraitGiantHUDCornerRadius"];
    [preferences registerDouble:&customLandscapeLargeHUDWidth default:209 forKey:@"customLandscapeLargeHUDWidth"];
    [preferences registerDouble:&customLandscapeLargeHUDHeight default:32 forKey:@"customLandscapeLargeHUDHeight"];
    [preferences registerDouble:&customLandscapeMiniHUDWidth default:238 forKey:@"customLandscapeMiniHUDWidth"];
    [preferences registerDouble:&customLandscapeMiniHUDHeight default:5 forKey:@"customLandscapeMiniHUDHeight"];
    [preferences registerDouble:&customLandscapeGiantHUDWidth default:260 forKey:@"customLandscapeGiantHUDWidth"];
    [preferences registerDouble:&customLandscapeGiantHUDHeight default:37 forKey:@"customLandscapeGiantHUDHeight"];
    [preferences registerDouble:&customPortraitLargeHUDWidth default:47 forKey:@"customPortraitLargeHUDWidth"];
    [preferences registerDouble:&customPortraitLargeHUDHeight default:148 forKey:@"customPortraitLargeHUDHeight"];
    [preferences registerDouble:&customPortraitMiniHUDWidth default:7 forKey:@"customPortraitMiniHUDWidth"];
    [preferences registerDouble:&customPortraitMiniHUDHeight default:134 forKey:@"customPortraitMiniHUDHeight"];
    [preferences registerDouble:&customPortraitGiantHUDWidth default:58 forKey:@"customPortraitGiantHUDWidth"];
    [preferences registerDouble:&customPortraitGiantHUDHeight default:170 forKey:@"customPortraitGiantHUDHeight"];
    [preferences registerDouble:&customHUDYOffset default:204 forKey:@"customHUDYOffset"];
    
    if (enabled && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0") && SYSTEM_VERSION_LESS_THAN(@"15.0")) {
        %init(VolVibes1314);
        return;
    }
    if (enabled && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"14.0")) {
        %init(VolVibes1516);
        return;
    }
    return;
}
