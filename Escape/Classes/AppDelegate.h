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

static NSString *iFBSessionOpened =@"fb_session_opened";
static NSString *iFBSessionClosed = @"fb_session_closed";
static NSString *iFBSessionError =@"fb_session_error";

@interface AppDelegate : CCAppDelegate

@property(nonatomic,strong)NSString *fbSessionState;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
@end
