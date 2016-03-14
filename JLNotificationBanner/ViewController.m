//
//  ViewController.m
//
//  Created by Jared LaSante on 1/24/14.
//  Copyright (c) 2014 jlasante. All rights reserved.
//

#import "ViewController.h"
#import "JLNotificationObject.h"
#import "JLUtils.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    [JLNotificationBanner getOverlay].hidden = NO;
}

- (IBAction)testModeButton:(id)sender
{
    [[JLNotificationBanner getOverlay] toggleTestMode];
}

- (IBAction)showBanner:(id)sender
{
    JLNotificationObject* newObj = [[JLNotificationObject alloc]init];
    newObj.title = @"Test Title";
    newObj.message = @"Test Message text goes here and can expand on to a second line";
    newObj.rightActionBackgroundImage = [JLUtils imageWithGradient:[NSArray arrayWithObjects:[JLUtils colorWithHexString:@"#63b0e3"], [JLUtils colorWithHexString:@"#4e94cd"], nil] forHeight:BANNER_RIGHT_ACTION_WIDTH];
    newObj.rightActionImage = [UIImage imageNamed:@"ic_phone"];
    newObj.rightActionBlock = ^(){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test Message"
                                                        message:@"This is a test of the right action"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    };
    newObj.mainActionBlock = ^(){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Main Test Message"
                                                        message:@"This is a test of the main action"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    };

    [[JLNotificationBanner getOverlay] pushNotification:newObj animated:YES];
}

- (IBAction)showBannerNow:(id)sender
{
    JLNotificationObject* newObj = [[JLNotificationObject alloc]init];
    newObj.title= @"Immediate Banner Notification Title";
    newObj.message = @"This message is immediately shown and must be manually dismissed";
    newObj.leftActionBackgroundColor = [UIColor redColor];
    newObj.leftActionImage = [UIImage imageNamed:@"ic_phone"];
    newObj.dismissOnAction = NO;
    newObj.dismissAutomatically = NO;
    newObj.leftActionBlock = ^(){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Test Message"
                                                        message:@"This is a test of the left action"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    };
    newObj.mainActionBlock = ^(){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Main Test Message"
                                                        message:@"This is a test of the main action"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    };
    [[JLNotificationBanner getOverlay] pushNotificationImmediately:newObj animated:YES];
}

- (IBAction)showPlainBanner:(id)sender
{
    JLNotificationObject* newObj = [[JLNotificationObject alloc]init];
    newObj.title = @"Plain Test Title";
    newObj.message = @"Plain test message without any side buttons and can expand on to a second line";
    newObj.mainActionBlock = ^(){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Main Test Message"
                                                        message:@"This is a test of the main action"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    };
    
    [[JLNotificationBanner getOverlay] pushNotification:newObj animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
