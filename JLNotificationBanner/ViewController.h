//
//  ViewController.h
//
//  Created by Jared LaSante on 1/24/14.
//  Copyright (c) 2014 jlasante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLNotificationBanner.h"

@interface ViewController : UIViewController

/*!
 *   @fn testModeButton
 *   @brief  A function to trigger the test mode banner
 *   @param id the button that was tapped
 */
- (IBAction)testModeButton:(id)sender;

/*!
 *   @fn showBanner
 *   @brief  A function to show a banner with a right action button and auto dismiss
 *   @param id the button that was tapped
 */
- (IBAction)showBanner:(id)sender;

/*!
 *   @fn showBannerNow
 *   @brief  A function to show a banner with a left action button, manual dismiss and a immediate display
 *   @param id the button that was tapped
 */
- (IBAction)showBannerNow:(id)sender;

/*!
 *   @fn showPlainBanner
 *   @brief  A function to show a plan banner with no left or right action button and auto dismiss
 *   @param id the button that was tapped
 */
- (IBAction)showPlainBanner:(id)sender;

@end
