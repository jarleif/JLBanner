//
//  JLNotificationBanner.m
//  Test
//
//  Created by Jared LaSante on 1/24/14.
//  Copyright (c) 2014 jlasante. All rights reserved.
//

#import "JLNotificationBanner.h"
#import "JLUtils.h"


static JLNotificationBanner* _notificationOverlay;
@interface JLNotificationBanner()

@property BOOL isTestMode;
@property (nonatomic,strong) UILabel* testModeLabel;

@property (nonatomic,strong) UIView* notificationBG;
@property (nonatomic,strong) UIView* bannerCenterContainer;
@property (nonatomic,strong) UIView* bannerLeftContainer;
@property (nonatomic,strong) UIView* bannerRightContainer;
@property (nonatomic,strong) UIButton* bannerLeftButton;
@property (nonatomic,strong) UIButton* bannerRightButton;
@property (nonatomic,strong) UIButton* bannerMainButton;
@property (nonatomic,strong) NSLayoutConstraint *constraintBannerLeftWidth;
@property (nonatomic,strong) NSLayoutConstraint *constraintBannerRightWidth;

@property (nonatomic,strong) UILabel* bannerTitleLabel;
@property (nonatomic,strong) UILabel* bannerMessageLabel;
@property (nonatomic,strong) UILabel* bannerTimeLabel;

@property BOOL showingBanner;
@property (nonatomic, assign) CGPoint preVelocity;

@property (nonatomic,strong) UIDynamicAnimator* animator;
@property (nonatomic,strong) UIGravityBehavior* gravity;
@property (nonatomic,strong) UICollisionBehavior* collision;

@property (nonatomic,strong) NSMutableArray* notificationQueue;
@property BOOL isShowingBanner;
@property BOOL shouldCloseBanner;
@property (nonatomic,strong) NSTimer* notificationDisplayTimer;

@property (nonatomic,strong) JLNotificationObject* currentNotification;
@end

@implementation JLNotificationBanner

/***********************************************
 *  get the Banner Singleton
 ***********************************************/
+ (JLNotificationBanner*)getOverlay
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        if(!_notificationOverlay)
        {
            _notificationOverlay = [[JLNotificationBanner alloc] init];
        }
    });
    //Fix for the background
    [_notificationOverlay setBackgroundColor:[UIColor clearColor]];
	return _notificationOverlay;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.windowLevel = UIWindowLevelStatusBar+1.0f;
        self.frame = [[UIApplication sharedApplication] statusBarFrame];
        [self setBackgroundColor:[UIColor clearColor]];
        
        _testModeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width-100,0,100,self.frame.size.height)];
        [_testModeLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [_testModeLabel setTextAlignment:NSTextAlignmentCenter];
        [_testModeLabel setMinimumScaleFactor:0.5];
        [_testModeLabel setText:@"Test Mode"];
        [_testModeLabel setTextColor:[UIColor whiteColor]];
        [_testModeLabel setBackgroundColor:[UIColor redColor]];
        [self addSubview:_testModeLabel];
        [self setTestModeOn:NO animated:NO];
        
        //Setup the Notification Banner
        _notificationBG = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, BANNER_HEIGHT+BANNER_HANDLE_HEIGHT)];
        self.frame = _notificationBG.frame;
        [_notificationBG setBackgroundColor:[UIColor clearColor]];
        [_notificationBG setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_notificationBG setUserInteractionEnabled:YES];
        
        UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        [panRecognizer setDelegate:self];
        
        [_notificationBG addGestureRecognizer:panRecognizer];
        if([[UIDevice currentDevice].systemVersion floatValue]>=7.0)
        {
            UIToolbar* blurToolbar = [[UIToolbar alloc]initWithFrame:_notificationBG.frame];
            [blurToolbar setTranslucent:YES];
            [blurToolbar setBarStyle:UIBarStyleBlack];
            [blurToolbar setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
            [_notificationBG addSubview:blurToolbar];
        }
        else
        {
            [_notificationBG setBackgroundColor:[UIColor blackColor]];
        }
        
        //Setup the notification Handle
        UIView* notificationBGHandle = [[UIView alloc]initWithFrame:CGRectZero];
        [notificationBGHandle setBackgroundColor:[UIColor lightGrayColor]];
        notificationBGHandle.layer.cornerRadius = 3;
        notificationBGHandle.translatesAutoresizingMaskIntoConstraints = NO;
        [_notificationBG addSubview:notificationBGHandle];
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:notificationBGHandle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_notificationBG attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
        [_notificationBG addConstraint:constraint];
        constraint = [NSLayoutConstraint constraintWithItem:notificationBGHandle attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_notificationBG attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-4.0f];
        [_notificationBG addConstraint:constraint];
        constraint = [NSLayoutConstraint constraintWithItem:notificationBGHandle attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:35.0f];
        [_notificationBG addConstraint:constraint];
        constraint = [NSLayoutConstraint constraintWithItem:notificationBGHandle attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:6.0f];
        [_notificationBG addConstraint:constraint];
        
        //Setup the Left Container
        _bannerLeftContainer = [[UIView alloc]initWithFrame:CGRectZero];
        [_bannerLeftContainer setBackgroundColor:[UIColor clearColor]];
        _bannerLeftContainer.layer.cornerRadius = 3;
        [_bannerLeftContainer setClipsToBounds:YES];
        _bannerLeftContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [_notificationBG addSubview:_bannerLeftContainer];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerLeftContainer attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_notificationBG attribute:NSLayoutAttributeLeading multiplier:1.0f constant:BANNER_PADDING];
        [_notificationBG addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerLeftContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_notificationBG attribute:NSLayoutAttributeTop multiplier:1.0f constant:BANNER_PADDING];
        [_notificationBG addConstraint:constraint];
        
        _constraintBannerLeftWidth = [NSLayoutConstraint constraintWithItem:_bannerLeftContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:BANNER_LEFT_ACTION_WIDTH];
        [_notificationBG addConstraint:_constraintBannerLeftWidth];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerLeftContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:BANNER_LEFT_ACTION_WIDTH];
        [_notificationBG addConstraint:constraint];
        
        //Setup the Left Action Button
        _bannerLeftButton = [[UIButton alloc]init];
        [_bannerLeftButton setBackgroundColor:[UIColor redColor]];//clearColor]];
        _bannerLeftButton.layer.cornerRadius = 3;
        [_bannerLeftButton setClipsToBounds:YES];
        _bannerLeftButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_bannerLeftButton addTarget:self action:@selector(handleLeftAction) forControlEvents:UIControlEventTouchUpInside];
        [_bannerLeftContainer addSubview:_bannerLeftButton];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerLeftButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_bannerLeftContainer attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
        [_bannerLeftContainer addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerLeftButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_bannerLeftContainer attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
        [_bannerLeftContainer addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerLeftButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem: _bannerLeftContainer attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
        [_bannerLeftContainer addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerLeftButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem: _bannerLeftContainer attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
        [_bannerLeftContainer addConstraint:constraint];
        
        
        //Setup the Right Container
        _bannerRightContainer = [[UIView alloc]initWithFrame:CGRectZero];
        [_bannerRightContainer setBackgroundColor:[UIColor whiteColor]];//clearColor]];
        _bannerRightContainer.layer.cornerRadius = 3;
        [_bannerRightContainer setClipsToBounds:YES];
        _bannerRightContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [_notificationBG addSubview:_bannerRightContainer];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerRightContainer attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_notificationBG attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-BANNER_PADDING];
        [_notificationBG addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerRightContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_notificationBG attribute:NSLayoutAttributeTop multiplier:1.0f constant:BANNER_PADDING];
        [_notificationBG addConstraint:constraint];
        
        _constraintBannerRightWidth = [NSLayoutConstraint constraintWithItem:_bannerRightContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:BANNER_RIGHT_ACTION_WIDTH];
        [_notificationBG addConstraint:_constraintBannerRightWidth];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerRightContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:BANNER_LEFT_ACTION_WIDTH];
        [_notificationBG addConstraint:constraint];
        
        //Setup the Right Action Button
        _bannerRightButton = [[UIButton alloc]init];
        [_bannerRightButton setBackgroundColor:[UIColor redColor]];//clearColor]];
        _bannerRightButton.layer.cornerRadius = 3;
        [_bannerRightButton setClipsToBounds:YES];
        _bannerRightButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_bannerRightButton addTarget:self action:@selector(handleRightAction) forControlEvents:UIControlEventTouchUpInside];
        [_bannerRightContainer addSubview:_bannerRightButton];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerRightButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_bannerRightContainer attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
        [_bannerRightContainer addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerRightButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_bannerRightContainer attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
        [_bannerRightContainer addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerRightButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem: _bannerRightContainer attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
        [_bannerRightContainer addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerRightButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem: _bannerRightContainer attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
        [_bannerRightContainer addConstraint:constraint];
        
        
        //Setup the Center container
        _bannerCenterContainer = [[UIView alloc]initWithFrame:CGRectZero];
        [_bannerCenterContainer setBackgroundColor:[UIColor clearColor]];
        _bannerCenterContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [_notificationBG addSubview:_bannerCenterContainer];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerCenterContainer attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_bannerLeftContainer attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0];
        [_notificationBG addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerCenterContainer attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_bannerRightContainer attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
        [_notificationBG addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerCenterContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_notificationBG attribute:NSLayoutAttributeTop multiplier:1.0f constant:BANNER_PADDING];
        [_notificationBG addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerCenterContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:BANNER_HEIGHT-2*BANNER_PADDING];
        [_notificationBG addConstraint:constraint];
        
        
        //Setup the Right Action Button
        _bannerMainButton = [[UIButton alloc]init];
        [_bannerMainButton setBackgroundColor:[UIColor clearColor]];
        [_bannerMainButton setClipsToBounds:YES];
        _bannerMainButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_bannerMainButton addTarget:self action:@selector(handleMainAction) forControlEvents:UIControlEventTouchUpInside];
        [_bannerCenterContainer addSubview:_bannerMainButton];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerMainButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_bannerCenterContainer attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.0f];
        [_bannerCenterContainer addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerMainButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_bannerCenterContainer attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
        [_bannerCenterContainer addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerMainButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem: _bannerCenterContainer attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f];
        [_bannerCenterContainer addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerMainButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem: _bannerCenterContainer attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0.0f];
        [_bannerCenterContainer addConstraint:constraint];
        
        //Setup the Banner title label
        _bannerTitleLabel = [[UILabel alloc]init];
        [_bannerTitleLabel setBackgroundColor:[UIColor clearColor]];
        _bannerTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_bannerTitleLabel setText:@"Title"];
        [_bannerTitleLabel setTextColor:[UIColor whiteColor]];
        [_bannerTitleLabel setFont:[UIFont systemFontOfSize:16]];
        [_bannerTitleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [_bannerTitleLabel setMinimumScaleFactor:10.0/16.0];
        [_bannerTitleLabel setAdjustsFontSizeToFitWidth:YES];
        [_bannerCenterContainer addSubview:_bannerTitleLabel];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerTitleLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_bannerCenterContainer attribute:NSLayoutAttributeLeading multiplier:1.0f constant:BANNER_PADDING];
        [_notificationBG addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerTitleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_bannerCenterContainer attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
        [_notificationBG addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerTitleLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem: _bannerCenterContainer attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-BANNER_PADDING];
        [_notificationBG addConstraint:constraint];
        
        CGSize labelSize = [_bannerTitleLabel.text sizeWithFont:_bannerTitleLabel.font
                                    constrainedToSize:_bannerTitleLabel.frame.size
                                        lineBreakMode:NSLineBreakByWordWrapping];
        constraint = [NSLayoutConstraint constraintWithItem:_bannerTitleLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem: nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:labelSize.height];
        [_notificationBG addConstraint:constraint];
        
        //Setup the Banner message label
        _bannerMessageLabel = [[UILabel alloc]init];
        [_bannerMessageLabel setBackgroundColor:[UIColor clearColor]];
        _bannerMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_bannerMessageLabel setText:@"A longer MessageText that should take up two lines of code"];
        [_bannerMessageLabel setTextColor:[UIColor whiteColor]];
        [_bannerMessageLabel setNumberOfLines:2];
        [_bannerMessageLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [_bannerMessageLabel setFont:[UIFont systemFontOfSize:16]];
        [_bannerMessageLabel setMinimumScaleFactor:10.0/16.0];
        [_bannerMessageLabel setAdjustsFontSizeToFitWidth:YES];
        
        [_bannerCenterContainer addSubview:_bannerMessageLabel];

        constraint = [NSLayoutConstraint constraintWithItem:_bannerMessageLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_bannerCenterContainer attribute:NSLayoutAttributeLeading multiplier:1.0f constant:BANNER_PADDING];
        [_notificationBG addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerMessageLabel attribute:NSLayoutAttributeTop relatedBy:0.0f toItem:_bannerTitleLabel attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
        [_notificationBG addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerMessageLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem: _bannerCenterContainer attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-BANNER_PADDING];
        [_notificationBG addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerMessageLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem: _bannerCenterContainer attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
        [_notificationBG addConstraint:constraint];
        
        //Setup the Time Label
        /*_bannerTimeLabel = [[UILabel alloc]init];
        [_bannerTimeLabel setBackgroundColor:[UIColor clearColor]];
        _bannerTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_bannerTimeLabel setText:@"30m ago"];
        [_bannerTimeLabel setTextColor:[UIColor whiteColor]];
        [_bannerTimeLabel setFont:[UIFont systemFontOfSize:12]];
        [_bannerTimeLabel setMinimumScaleFactor:10.0/12.0];
        [_bannerTimeLabel setAdjustsFontSizeToFitWidth:YES];
        [_bannerTimeLabel setAdjustsLetterSpacingToFitWidth:YES];
        
        [_bannerCenterContainer addSubview:_bannerTimeLabel];

       // constraint = [NSLayoutConstraint constraintWithItem:_bannerTimeLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_bannerTitleLabel attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
        //Currently not using Time label so set its width to become 0
         constraint = [NSLayoutConstraint constraintWithItem:_bannerTimeLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:_bannerCenterContainer attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
        [_notificationBG addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerTimeLabel attribute:NSLayoutAttributeTop relatedBy:0.0f toItem:_bannerTitleLabel attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
        [_notificationBG addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerTimeLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:_bannerCenterContainer attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.0f];
        [_notificationBG addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:_bannerTimeLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem: _bannerTitleLabel attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
        [_notificationBG addConstraint:constraint];
        */
        [self addSubview:_notificationBG];
        [_notificationBG setHidden:YES];
        [self setUserInteractionEnabled:YES];

        _notificationQueue = [[NSMutableArray alloc] init];
        [self closeBannerAnimated:NO];
        
        //Setup Notification to detect change in orientation
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarDidChangeFrame:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

/*!
 *   @fn setOverlayVisible
 *   @brief  A function to set the window overlay to be visible or hidden
 *   @param BOOL Specifies if the window should be visible or not
 */
- (void)setOverlayVisible:(BOOL)becomeVisible
{
    if(becomeVisible)
        [self showOverlay];
    else
        [self hideOverlay];
}
/*!
 *   @fn showOverlay
 *   @brief  A function to set the window overlay to be visible
 */
- (void)showOverlay
{
    [self setHidden:false];
}
/*!
 *   @fn hideOverlay
 *   @brief  A function to set the window overlay to be hidden
 */
- (void)hideOverlay
{
    if(!_isShowingBanner && !_isTestMode)
        [self setHidden:true];
}

- (void)toggleTestMode
{
    [self setTestModeOn:!_isTestMode animated:YES];
}

- (void)setTestModeOn:(BOOL)turnOn animated:(BOOL)animated
{
    _isTestMode = turnOn;
    if(turnOn)
    {
        if(!_isShowingBanner)
            self.frame = [[UIApplication sharedApplication] statusBarFrame];
        [self showOverlay];
    }
    if(animated)
    {
        UIViewAnimationOptions animationOption = UIViewAnimationOptionTransitionCurlDown;
        if(!turnOn)
            animationOption = UIViewAnimationOptionTransitionCurlUp;
        [UIView transitionWithView:_testModeLabel
                          duration:0.8
                           options:animationOption
                        animations:^{
                             _testModeLabel.hidden = !_isTestMode;
                        }
                        completion:^(BOOL finished){
                            if(finished && !turnOn)
                                [self hideOverlay];
                        }];
    }
    else
        _testModeLabel.hidden = !_isTestMode;
}

- (void)pushNotificationWithTitle:(NSString*)title andMessage:(NSString*)message
{
    runOnMainQueueWithoutDeadlocking( ^{
        JLNotificationObject* object = [[JLNotificationObject alloc] init];
        object.title = title;
        object.message = message;
        [self pushNotification:object animated:YES];
    });
}

- (void)pushNotification:(JLNotificationObject*)notificationObject animated:(BOOL)animated
{
    runOnMainQueueWithoutDeadlocking( ^{
        notificationObject.animated = animated;
        [_notificationQueue insertObject:notificationObject atIndex:0];
        if(!_isShowingBanner)
            [self checkForNotificationToShow];
    });
}

- (void)pushNotificationImmediately:(JLNotificationObject*)notificationObject animated:(BOOL)animated
{
    runOnMainQueueWithoutDeadlocking( ^{
        notificationObject.animated = animated;
        [_notificationQueue addObject:notificationObject];
        if(_isShowingBanner)
            [self closeBannerAnimated:YES];
        else
            [self checkForNotificationToShow];
    });
}

/*!
 *   @fn checkForNotificationToShow
 *   @brief  A function to check if it should show another notification
 */
- (void)checkForNotificationToShow
{
    if([_notificationQueue count]>0&&!_isShowingBanner)
    {
        [self showNotification:_notificationQueue.lastObject];
        [_notificationQueue removeLastObject];
    }
}
/*!
 *   @fn showNotification
 *   @brief  A function to display the notification object
 *   @param JLNotificationObject The notification object to display
 */
- (void)showNotification:(JLNotificationObject*)notificationObject
{
    [self setHidden:false];
    [_notificationBG setHidden:NO];
    if(!_isShowingBanner)
    {
        //Make sure banner frame is correct based on the orientation
        switch ([[UIApplication sharedApplication] statusBarOrientation]) {
            case UIInterfaceOrientationLandscapeLeft:
                self.frame = CGRectMake([[UIApplication sharedApplication] statusBarFrame].origin.x, [[UIApplication sharedApplication] statusBarFrame].origin.y,BANNER_HEIGHT+BANNER_HANDLE_HEIGHT, [[UIApplication sharedApplication] statusBarFrame].size.height );
                break;
            case UIInterfaceOrientationLandscapeRight:
                self.frame = CGRectMake([[UIApplication sharedApplication] statusBarFrame].origin.x-(BANNER_HEIGHT+BANNER_HANDLE_HEIGHT-20), [[UIApplication sharedApplication] statusBarFrame].origin.y, (BANNER_HEIGHT+BANNER_HANDLE_HEIGHT),[[UIApplication sharedApplication] statusBarFrame].size.height);
                break;
            case UIInterfaceOrientationPortraitUpsideDown:
                self.frame = CGRectMake([[UIApplication sharedApplication] statusBarFrame].origin.x, [[UIApplication sharedApplication] statusBarFrame].origin.y, [[UIApplication sharedApplication] statusBarFrame].size.width, BANNER_HEIGHT+BANNER_HANDLE_HEIGHT);
                break;
            case UIInterfaceOrientationPortrait:
            default:
                self.frame = CGRectMake([[UIApplication sharedApplication] statusBarFrame].origin.x, [[UIApplication sharedApplication] statusBarFrame].origin.y, [[UIApplication sharedApplication] statusBarFrame].size.width, BANNER_HEIGHT+BANNER_HANDLE_HEIGHT);
                break;
        }
    }
    _isShowingBanner = YES;
    //Configure the left Action Button
    if(notificationObject.leftActionBackgroundImage || notificationObject.leftActionBackgroundColor || notificationObject.leftActionImage)
    {
        if(notificationObject.leftActionBackgroundColor)
            [_bannerLeftButton setBackgroundColor:notificationObject.leftActionBackgroundColor];
        if(notificationObject.leftActionBackgroundImage)
            [_bannerLeftButton setBackgroundImage:notificationObject.leftActionBackgroundImage forState:UIControlStateNormal];
        if(notificationObject.leftActionImage)
            [_bannerLeftButton setImage:notificationObject.leftActionImage forState:UIControlStateNormal];
        _constraintBannerLeftWidth.constant = BANNER_LEFT_ACTION_WIDTH;
    }
    else
        _constraintBannerLeftWidth.constant = 0;
    
    if(notificationObject.leftActionBlock)
    {
        _bannerLeftButton.userInteractionEnabled = YES;
    }
    else
        _bannerLeftButton.userInteractionEnabled = NO;
    
    //Configure the right Action Button
    if(notificationObject.rightActionBackgroundImage || notificationObject.rightActionBackgroundColor || notificationObject.rightActionImage)
    {
        if(notificationObject.rightActionBackgroundColor)
            [_bannerRightButton setBackgroundColor:notificationObject.rightActionBackgroundColor];
        if(notificationObject.rightActionBackgroundImage)
            [_bannerRightButton setBackgroundImage:notificationObject.rightActionBackgroundImage forState:UIControlStateNormal];
        if(notificationObject.rightActionImage)
           [_bannerRightButton setImage:notificationObject.rightActionImage forState:UIControlStateNormal];
        
        _constraintBannerRightWidth.constant = BANNER_RIGHT_ACTION_WIDTH;
    }
    else
        _constraintBannerRightWidth.constant = 0;
    
    if(notificationObject.rightActionBlock)
    {
        _bannerRightButton.userInteractionEnabled = YES;
    }
    else
        _bannerRightButton.userInteractionEnabled = NO;

    if(notificationObject.mainActionBlock)
    {
        _bannerMainButton.userInteractionEnabled = YES;
    }
    else
        _bannerMainButton.userInteractionEnabled = NO;
    
    _currentNotification = notificationObject;
    if(notificationObject.animated)
    {
        [UIView transitionWithView:_bannerCenterContainer
                      duration:0.8
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [_bannerMessageLabel setText:notificationObject.message];
                        [_bannerTitleLabel setText:notificationObject.title];
                        [self layoutIfNeeded];
                    }
                    completion:^(BOOL finished){
                        if(finished)
                            [self moveBannerToOriginalPosition];
                    }];
    }
    else
    {
        [_bannerMessageLabel setText:notificationObject.message];
        [_bannerTitleLabel setText:notificationObject.title];
        [self layoutIfNeeded];
        _notificationBG.frame = CGRectMake(0, 0, _notificationBG.frame.size.width, _notificationBG.frame.size.height);
    }
    if(notificationObject.dismissAutomatically)
        _notificationDisplayTimer = [NSTimer scheduledTimerWithTimeInterval:notificationObject.displayTime target:self selector:@selector(closeBanner) userInfo:nil repeats:NO];
}

/*!
 *   @fn moveBannerToOriginalPosition
 *   @brief  A function to move the banner to its original position
 */
- (void)moveBannerToOriginalPosition
{
   /* if([[UIDevice currentDevice].systemVersion floatValue]>=7.0)
    {
        if(!_animator)
            _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
        else
            [_animator removeAllBehaviors];
        _gravity = [[UIGravityBehavior alloc] initWithItems:@[_notificationBG]];
        [_animator addBehavior:_gravity];
        _collision = [[UICollisionBehavior alloc] initWithItems:@[_notificationBG]];
        CGPoint bottomEdge = CGPointMake(self.frame.size.width, self.frame.size.height);
        [_collision addBoundaryWithIdentifier:@"barrier"
                                    fromPoint:CGPointMake(self.frame.origin.x, self.frame.size.height)
                                      toPoint:bottomEdge];
        [_animator addBehavior:_collision];
        UIDynamicItemBehavior *elasticityBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[_notificationBG]];
        elasticityBehavior.elasticity = 0.5f;
        [_animator addBehavior:elasticityBehavior];
    }
    else
    {*/
        [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState |UIViewAnimationCurveEaseOut animations:^{
            _notificationBG.frame = CGRectMake(0, 0, _notificationBG.frame.size.width, _notificationBG.frame.size.height);
            }
            completion:nil];
    //}
}

/*!
 *   @fn closeBanner
 *   @brief  A helper function to close the banner
 */
- (void)closeBanner
{
    [self closeBannerAnimated:YES];
}

/*!
 *   @fn closeBannerAnimated
 *   @brief  A function to close the banner
 *   @param BOOL Specifies if the notification should be animated or not
 */
- (void)closeBannerAnimated:(BOOL)animated
{
    [[self layer] removeAllAnimations];
    _currentNotification = nil;
    if(_notificationDisplayTimer)
    {
        [_notificationDisplayTimer invalidate];
        _notificationDisplayTimer = nil;
    }
    if(animated)
    {
        [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseIn animations:^{
            _notificationBG.frame = CGRectMake(0, -_notificationBG.frame.size.height, _notificationBG.frame.size.width, _notificationBG.frame.size.height);
        }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 _isShowingBanner = NO;
                                 [self hideOverlay];
                                 [self checkForNotificationToShow];
                                 [_notificationBG setHidden:NO];
                             }
                         }];
    }
    else
    {
        _notificationBG.frame = CGRectMake(0, -_notificationBG.frame.size.height, _notificationBG.frame.size.width, _notificationBG.frame.size.height);
        _isShowingBanner = NO;
        [self hideOverlay];
        [self checkForNotificationToShow];
    }
}
/*!
 *   @fn handleLeftAction
 *   @brief  A function for when the left action button is clicked
 */
- (void)handleLeftAction
{
    if(_currentNotification &&  _currentNotification.leftActionBlock)
    {
        _currentNotification.leftActionBlock();
        if(_currentNotification.dismissOnAction)
            [self closeBannerAnimated:YES];
    }
}

/*!
 *   @fn handleRightAction
 *   @brief  A function for when the right action button is clicked
 */
- (void)handleRightAction
{
    if(_currentNotification &&  _currentNotification.rightActionBlock)
    {
        _currentNotification.rightActionBlock();
        if(_currentNotification.dismissOnAction)
            [self closeBannerAnimated:YES];
    }
}

/*!
 *   @fn handleMainAction
 *   @brief  A function for when the main action button is clicked
 */
- (void)handleMainAction
{
    //If there isn't a main notificationAction, but there is a right action, make tapping the banner use the right or left button action
    if(!_currentNotification.mainActionBlock && _currentNotification.replaceNilMainAction)
    {
        if(_currentNotification.leftActionBlock)
            _currentNotification.mainActionBlock = _currentNotification.leftActionBlock;
        if(_currentNotification.rightActionBlock)
            _currentNotification.mainActionBlock = _currentNotification.rightActionBlock;
    }
    if(_currentNotification &&  _currentNotification.mainActionBlock)
    {
        _currentNotification.mainActionBlock();
        if(_currentNotification.dismissOnAction)
            [self closeBannerAnimated:YES];
    }
}

/*!
 *   @fn handlePanFrom
 *   @brief  A function for the handling the pan gesture on the banner
 *   @param UIPanGestureRecognizer The pan gesture
 */
- (void)handlePanFrom:(UIPanGestureRecognizer*)sender
{
    [[[(UITapGestureRecognizer*)sender view] layer] removeAllAnimations];
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self];
    CGPoint velocity = [(UIPanGestureRecognizer*)sender velocityInView:[sender view]];
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        if(_notificationDisplayTimer)
        {
            [_notificationDisplayTimer invalidate];
            _notificationDisplayTimer = nil;
        }
        
        [[sender view] bringSubviewToFront:[(UIPanGestureRecognizer*)sender view]];
    }
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded)
    {
        NSLog(@"%f",velocity.y);
        if(velocity.y < -150) {
            // NSLog(@"gesture went UP");
            [self closeBannerAnimated:YES];
            return;
        } else {
            // NSLog(@"gesture went Down");
        }

        float gestureCheckHeight = [sender view].frame.size.height;//+[sender view].frame.origin.y;
        float notifCheckHeight = _notificationBG.frame.size.height;//*2/3;
        if(gestureCheckHeight <= notifCheckHeight){
            [self closeBannerAnimated:YES];
        }
        else
        {
            [self moveBannerToOriginalPosition];
            if(_currentNotification.dismissAutomatically)
                _notificationDisplayTimer = [NSTimer scheduledTimerWithTimeInterval:_currentNotification.displayTime target:self selector:@selector(closeBanner) userInfo:nil repeats:NO];
        }
    }
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged)
    {
        if(velocity.y > 0) {
            // NSLog(@"gesture went down");
        } else {
            // NSLog(@"gesture went up");
        }
        
        // Allow dragging only in y-coordinates by only updating the y-coordinate with translation position.
        NSInteger centerPosY = [sender view].center.y + translatedPoint.y;
        if(centerPosY<=_notificationBG.frame.size.height/2)
        {
            [sender view].center = CGPointMake([sender view].center.x,centerPosY);
        
            [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0,0) inView:_notificationBG];
        }
        // If you needed to check for a change in direction, you could use this code to do so.
        if(velocity.x*_preVelocity.x + velocity.y*_preVelocity.y > 0) {
            // NSLog(@"same direction");
        } else {
            // NSLog(@"opposite direction");
        }
            _preVelocity = velocity;
        }
}

#define DegreesToRadians(degrees) (degrees * M_PI / 180)
/*!
 *   @fn transformForOrientation
 *   @brief  A function for rotating the banner with the screen
 *   @param UIInterfaceOrientation The current orientation of the screen
 */
- (void)transformForOrientation:(UIInterfaceOrientation)orientation {
    
    NSLog(@"%@", NSStringFromCGRect([[UIApplication sharedApplication] statusBarFrame]));

    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            [self setTransform:(CGAffineTransform)CGAffineTransformMakeRotation(-DegreesToRadians(90))];
            [self setFrame:CGRectMake([[UIApplication sharedApplication] statusBarFrame].origin.x, [[UIApplication sharedApplication] statusBarFrame].origin.y, self.frame.size.width, [[UIApplication sharedApplication] statusBarFrame].size.height)];
            break;
        case UIInterfaceOrientationLandscapeRight:
            [self setTransform:(CGAffineTransform)CGAffineTransformMakeRotation(DegreesToRadians(90))];
            [self setFrame:CGRectMake([[UIApplication sharedApplication] statusBarFrame].origin.x-self.frame.size.width+20, [[UIApplication sharedApplication] statusBarFrame].origin.y, self.frame.size.width, [[UIApplication sharedApplication] statusBarFrame].size.height)];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            [self setTransform:(CGAffineTransform)CGAffineTransformMakeRotation(DegreesToRadians(180))];
            [self setFrame:CGRectMake([[UIApplication sharedApplication] statusBarFrame].origin.x, [[UIApplication sharedApplication] statusBarFrame].origin.y, [[UIApplication sharedApplication] statusBarFrame].size.width, self.frame.size.height)];
            break;
        case UIInterfaceOrientationPortrait:
        default:
            [self setTransform:(CGAffineTransform)CGAffineTransformMakeRotation(DegreesToRadians(0))];
            [self setFrame:CGRectMake([[UIApplication sharedApplication] statusBarFrame].origin.x, [[UIApplication sharedApplication] statusBarFrame].origin.y, [[UIApplication sharedApplication] statusBarFrame].size.width, self.frame.size.height)];
            break;
    }
}

/*!
 *   @fn statusBarDidChangeFrame
 *   @brief  A function for handling the statusbar UIApplicationDidChangeStatusBarFrameNotification
 *   @param NSNotification The current notification
 */

- (void)statusBarDidChangeFrame:(NSNotification *)notification {
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self transformForOrientation:orientation];
    
    
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
