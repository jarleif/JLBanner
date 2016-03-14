//
//  JLUtils.h
//
//  Created by Jared LaSante on 1/24/14.
//  Copyright (c) 2014 jlasante. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JLUtils : NSObject {
    
}

/*!
 *   @fn runOnMainQueueWithoutDeadlocking
 *   @brief  A function helper to make sure we run on the main thread
 *   @param block the block of code to run
 */
void runOnMainQueueWithoutDeadlocking(void (^block)(void));

/*! 
 *   @fn colorWithHexString
 *   @brief  A function create a color for a hex string
 *   @param NSString the color hex string
 *   @return UIColor Returns a UIColor of the hex string
 */
+ (UIColor *)colorWithHexString:(NSString *)str;

/*!
 *   @fn colorWithHex
 *   @brief  A function create a color for a hex value
 *   @param UInt32 the color hex
 *   @return UIColor Returns a UIColor of the hex string
 */
+ (UIColor *)colorWithHex:(UInt32)col;
/*!
 *   @fn imageFromColor
 *   @brief  A function create a uiimage from a UIColor
 *   @param UIColor the color to use
 *   @return UIImage Returns a UIImage of the color
 */
+ (UIImage *)imageFromColor:(UIColor *)color;
/*!
 *   @fn imageWithGradient
 *   @brief  A function create a gradient uiimage from an array of UIColor
 *   @param NSArray the array of color to use
 *   @param NSInteger the height of the gradient
 *   @return UIImage Returns a UIImage of the gradient
 */
+ (UIImage*)imageWithGradient:(NSArray*)colorsArray forHeight:(NSInteger)imageHeight;
/*!
 *   @fn imageWithGradient
 *   @brief  A function create a gradient uiimage from an array of UIColor
 *   @param NSArray the array of color to use
 *   @param NSInteger the height of the gradient
 *   @param NSInteger the width of the gradient
 *   @return UIImage Returns a UIImage of the gradient
 */
+ (UIImage*)imageWithGradient:(NSArray*)colorsArray forHeight:(NSInteger)imageHeight width:(NSInteger)imageWidth;



#pragma mark -
#pragma mark DEBUG Helpers
/*! 
 *   @fn dumpView
 *   @brief Prints out all the subViews of the passed in view
 *   @param UIView the view and its subviews to be printed
 *   @param NSString the string to indent for the subviews
 */
+(void)dumpView:(UIView*)aView stringIndent:(NSString*) indent;

/*! 
 *   @fn dumpWindows
 *   @brief Prints out all the subViews that are loaded
 *   @param UIView the view and its subviews to be printed
 *   @param NSString the string to indent for the subviews
 */
+(void)dumpWindows;

@end
