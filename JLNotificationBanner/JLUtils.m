//
//  JLUtils.m
//
//  Created by Jared LaSante on 1/24/14.
//  Copyright (c) 2014 jlasante. All rights reserved.
//

#import "JLUtils.h"
#import <QuartzCore/QuartzCore.h>

@implementation JLUtils
//Used to make sure we run our functions on the main thread and don't get a deadlock
void runOnMainQueueWithoutDeadlocking(void (^block)(void))
{
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}



#pragma mark -
#pragma mark Color Helpers
+ (UIColor *)colorWithHexString:(NSString *)str {
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    return [JLUtils colorWithHex:(UInt32)x];
}

// takes 0x123456
+ (UIColor *)colorWithHex:(UInt32)col {
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}

+ (UIImage *) imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    //  [[UIColor colorWithRed:222./255 green:227./255 blue: 229./255 alpha:1] CGColor]) ;
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage*)imageWithGradient:(NSArray*)colorsArray forHeight:(NSInteger)imageHeight
{
    return [JLUtils imageWithGradient:colorsArray forHeight:imageHeight width:1];
}

+ (UIImage*)imageWithGradient:(NSArray*)colorsArray forHeight:(NSInteger)imageHeight width:(NSInteger)imageWidth
{
    UIGraphicsBeginImageContext(CGSizeMake(imageWidth, imageHeight));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Create gradient.
    CGColorRef colorRefs[colorsArray.count];// = {
    NSInteger i=0;
    for(UIColor* color in colorsArray)
    {
        colorRefs[i] = [color CGColor];
        i++;
    }
    //   };
    CFArrayRef colors = CFArrayCreate(NULL, (const void **)colorRefs, colorsArray.count, NULL);
    CGGradientRef gradient = CGGradientCreateWithColors(NULL, colors, NULL);
    
    // Create image.
    CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, imageHeight), 0);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Clean up.
    CFRelease(colors);
    CGGradientRelease(gradient);
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark -
#pragma mark DEBUG Helpers

/***********************************************
 *  debugging to print out subviews
 ***********************************************/
+ (void)dumpView:(UIView*)aView stringIndent:(NSString*) indent {
    if (aView) {
        NSLog(@"%@%@", indent, aView);      // dump this view
        
        if (aView.subviews.count > 0) {
            NSString* subIndent = [[NSString alloc] initWithFormat:@"%@%@", 
                                   indent, ([indent length]/2)%2==0 ? @"| " : @": "];
            for (UIView* aSubview in aView.subviews) 
                [self dumpView:aSubview stringIndent: subIndent];
        }
    }
}

/***********************************************
 *  debugging to print out all views
 ***********************************************/
+ (void)dumpWindows {
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        [self dumpView:window stringIndent: @"dumpView: "];
    }   
}

@end
