//
//  JLNotificationBanner.h
//
//  Created by Jared LaSante on 1/24/14.
//  Copyright (c) 2014 jlasante. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLNotificationObject.h"

#define BANNER_HEIGHT 64.0f
#define BANNER_HANDLE_HEIGHT 8.0f
#define BANNER_PADDING 4.0f
#define BANNER_LEFT_ACTION_WIDTH 56
#define BANNER_RIGHT_ACTION_WIDTH 56
#define SLIDE_TIMING .30

/*!
 *   JLNotification Banner extends UIWindow and provides a way to show banners on any screen in your app.
 *   It also allows for showing if the app is in test mode or not
 */

@interface JLNotificationBanner : UIWindow <UIGestureRecognizerDelegate>

/*!
 *   @fn getOverlay
 *   @brief  A function to get the JLNotificationBanner singleton
 *   @return JLNotificationBanner the File Manager singleton
 */
+ (JLNotificationBanner*)getOverlay;

/*!
 *   @fn toggleTestMode
 *   @brief  A function to toggle the test mode banner on or off
 */
- (void)toggleTestMode;

/*!
 *   @fn setTestModeOn
 *   @brief  A function to set test mode on or off
 *   @param BOOL A BOOL specifying if you want to turn test mode on or off
 *   @param BOOL A BOOL specifying if the action should be animated
 */
- (void)setTestModeOn:(BOOL)turnOn animated:(BOOL)animated;

/*!
 *   @fn pushNotificationWithTitle
 *   @brief  A function to push a notification to the notification queue with a title and message
 *   @param NSString The title of the Notification
 *   @param NSString The message of the Notification
 */
- (void)pushNotificationWithTitle:(NSString*)title andMessage:(NSString*)message;

/*!
 *   @fn pushNotification
 *   @brief  A function to push a notification object to the notification queue
 *   @param JLNotificationObject The notification object to push
 *   @param BOOL Specifies if the notification should be animated or not
 */
- (void)pushNotification:(JLNotificationObject*)notificationObject animated:(BOOL)animated;

/*!
 *   @fn pushNotificationImmediately
 *   @brief  A function to push a notification object to the notification queue and immediately show it
 *   @param JLNotificationObject The notification object to push
 *   @param BOOL Specifies if the notification should be animated or not
 */
- (void)pushNotificationImmediately:(JLNotificationObject*)notificationObject animated:(BOOL)animated;
@end
