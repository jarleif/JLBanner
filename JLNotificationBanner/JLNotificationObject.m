//
//  JLNotificationObject.m
//  Test
//
//  Created by Jared LaSante on 1/28/14.
//  Copyright (c) 2014 jlasante. All rights reserved.
//

#import "JLNotificationObject.h"

#define DISPLAY_TIME 4.0

@implementation JLNotificationObject


- (id)init
{
    self = [super init];
    if (self) {
        _displayTime = DISPLAY_TIME;
        _dismissAutomatically = YES;
        _dismissOnAction = YES;
        _replaceNilMainAction = YES;
    }
    return self;
}
@end
