//
//  JLNotificationObject.h
//  Test
//
//  Created by Jared LaSante on 1/28/14.
//  Copyright (c) 2014 jlasante. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ ActionBlock)();

/*!
 *   JLNotificationObject is the object used to define what a banner contains and how it behaves
 *   It also includes blocks holding the actions for the left,right and main actions
 */
@interface JLNotificationObject : NSObject

/// The block of code when user taps the left action button
@property (nonatomic, copy) ActionBlock leftActionBlock;
/// The block of code when user taps the right action button
@property (nonatomic, copy) ActionBlock rightActionBlock;
/// The block of code when user taps the banner
@property (nonatomic, copy) ActionBlock mainActionBlock;

/// A UIImage for the background of the left action button
@property (nonatomic, strong) UIImage* leftActionBackgroundImage;
/// A UIImage for the background of the right action button
@property (nonatomic, strong) UIImage* rightActionBackgroundImage;

/// A UIColor for the background of the left action button
@property (nonatomic, strong) UIColor* leftActionBackgroundColor;
/// A UIColor for the background of the right action button
@property (nonatomic, strong) UIColor* rightActionBackgroundColor;

/// A UIImage for the left action button
@property (nonatomic, strong) UIImage* leftActionImage;
/// A UIImage for the right action button
@property (nonatomic, strong) UIImage* rightActionImage;
@property (nonatomic, strong) NSString* rightActionTitle;

/// The title of the notification
@property(nonatomic, copy) NSString* title;
/// The message of the notification
@property(nonatomic, copy) NSString* message;
/// The date of the notification
@property(nonatomic, copy) NSString* date;

/// Specifies if the banner is animated
@property BOOL animated;
/// How long should the banner display for
@property float displayTime;

/// Should we replace a nil main action with a left or right action?
@property float replaceNilMainAction;

/// Should the banner dismiss after an action is tapped
@property BOOL dismissOnAction;
/// Should the banner dismiss automatically
@property BOOL dismissAutomatically;

@end
