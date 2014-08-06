//
//  AppDelegate.h
//  Escape
//
//  Created by user on 14-7-14.
//  Copyright david_tsang 2014年. All rights reserved.
//
// -----------------------------------------------------------------------

#import "cocos2d.h"
#import <FacebookSDK/FacebookSDK.h>
@interface AppDelegate : CCAppDelegate

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
@end
