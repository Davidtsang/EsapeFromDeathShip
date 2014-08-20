//
//  AppDelegate.m
//  Escape
//
//  Created by user on 14-7-14.
//  Copyright david_tsang 2014年. All rights reserved.
//
// -----------------------------------------------------------------------

#import "AppDelegate.h"
#import "HelloWorldScene.h"


@implementation AppDelegate

// 
-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// This is the only app delegate method you need to implement when inheriting from CCAppDelegate.
	// This method is a good place to add one time setup code that only runs when your app is first launched.
	
	// Setup Cocos2D with reasonable defaults for everything.
	// There are a number of simple options you can change.
	// If you want more flexibility, you can configure Cocos2D yourself instead of calling setupCocos2dWithOptions:.
	[self setupCocos2dWithOptions:@{
		// Show the FPS and draw call label.
		CCSetupShowDebugStats: @(NO),
		
		// More examples of options you might want to fiddle with:
		// (See CCAppDelegate.h for more information)
		
		// Use a 16 bit color buffer: 
//		CCSetupPixelFormat: kEAGLColorFormatRGB565,
		// Use a simplified coordinate system that is shared across devices.
//		CCSetupScreenMode: CCScreenModeFixed,
		// Run in portrait mode.
		CCSetupScreenOrientation: CCScreenOrientationPortrait,
		// Run at a reduced framerate.
//		CCSetupAnimationInterval: @(1.0/30.0),
		// Run the fixed timestep extra fast.
//		CCSetupFixedUpdateInterval: @(1.0/180.0),
		// Make iPad's act like they run at a 2x content scale. (iPad retina 4x)
//		CCSetupTabletScale2X: @(YES),
	}];
    [ThisIAPHelper sharedInstance];
    
    //self.cherryIDSafeStore = [[KeychainItemWrapper alloc] initWithIdentifier:@"cherry_board_id" accessGroup:nil];
    if (!self.safeStore) {
        self.safeStore = [UICKeyChainStore keyChainStore];
    }
    
    self.isProVersion = [self checkIsProVersion];
    
    if (!self.isProVersion) {
        [self createAdmobAds];
    }
    

    //game center
    GameKitHelper *gkHelper =[ GameKitHelper sharedInstance];
    gkHelper.delegate = self;
    
    [gkHelper authenticateLocalPlayer];
    
	return YES;
}


// IAP
-(void)makeIsProVersion{
    self.isProVersion = YES;
    //[self.cherryIDSafeStore setObject:@"IAP_OK" forKey:(__bridge id)kSecAttrAccount];
    [self.safeStore setString:@"IAP_OK" forKey:@"iap"];
    [self.safeStore synchronize];
}

-(BOOL)checkIsProVersion
{
    NSString *isProStr =  [self.safeStore stringForKey:@"iap"];
    BOOL isPro = NO;
    if ([isProStr isEqualToString:@"IAP_OK"]) {
        isPro = YES;
    }

    return isPro ;
    //return YES;
}
    //COCOS2D - ENTER POINT
-(CCScene *)startScene
{
	// This method should return the very first scene to be run when your app starts.
    HelloWorldScene *scene =[HelloWorldScene scene];
    [scene showGameHome];
	return scene;
}


// Called before ad is shown, good time to show the add
- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    NSLog(@"Admob receive ads" );
}

// An error occured
- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"Admob error: %@", error);

}

-(void)createAdmobAds
{
    mBannerType = BANNER_TYPE;
    
    if(mBannerType <= kBanner_Portrait_Bottom)
        mBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    else
        mBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
    
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    
    mBannerView.adUnitID = ADMOB_BANNER_UNIT_ID;
    
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    
    mBannerView.rootViewController = self.navController;
    [self.navController.view addSubview:mBannerView];
    GADRequest *request = [GADRequest request];
#ifdef DEBUG    
         request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID,@"9e9b79b9aca390df80133e98cc96612a", nil];
#endif
    
    
    // Initiate a generic request to load it with an ad.
    [mBannerView loadRequest:request];
    
    CGSize s = [[CCDirector sharedDirector] viewSize];
    
    CGRect frame = mBannerView.frame;
    
    off_x = 0.0f;
    on_x = 0.0f;
    
    switch (mBannerType)
    {
        case kBanner_Portrait_Top:
        {
            off_y = -frame.size.height;
            on_y = 0.0f;
        }
            break;
        case kBanner_Portrait_Bottom:
        {
            off_y = s.height;
            on_y = s.height-frame.size.height;
        }
            break;
        case kBanner_Landscape_Top:
        {
            off_y = -frame.size.height;
            on_y = 0.0f;
        }
            break;
        case kBanner_Landscape_Bottom:
        {
            off_y = s.height;
            on_y = s.height-frame.size.height;
        }
            break;
            
        default:
            break;
    }
    
    frame.origin.y = off_y;
    frame.origin.x = off_x;
    
    mBannerView.frame = frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    frame = mBannerView.frame;
    frame.origin.x = on_x;
    frame.origin.y = on_y;
    
    
    mBannerView.frame = frame;
    [UIView commitAnimations];
}


-(void)showBannerView
{
    if (mBannerView && self.isProVersion == NO )
    {
        //banner on bottom
        {
            CGRect frame = mBannerView.frame;
            frame.origin.y = off_y;
            frame.origin.x = on_x;
            mBannerView.frame = frame;
            
            
            [UIView animateWithDuration:0.5
                                  delay:0.1
                                options: UIViewAnimationCurveEaseOut
                             animations:^
             {
                 CGRect frame = mBannerView.frame;
                 frame.origin.y = on_y;
                 frame.origin.x = on_x;
                 
                 mBannerView.frame = frame;
             }
                             completion:^(BOOL finished)
             {
             }];
        }
        //Banner on top
        //        {
        //            CGRect frame = mBannerView.frame;
        //            frame.origin.y = -frame.size.height;
        //            frame.origin.x = off_x;
        //            mBannerView.frame = frame;
        //
        //            [UIView animateWithDuration:0.5
        //                                  delay:0.1
        //                                options: UIViewAnimationCurveEaseOut
        //                             animations:^
        //             {
        //                 CGRect frame = mBannerView.frame;
        //                 frame.origin.y = 0.0f;
        //                 frame.origin.x = off_x;
        //                 mBannerView.frame = frame;
        //             }
        //                             completion:^(BOOL finished)
        //             {
        //
        //
        //             }];
        //        }
        
    }
    
}


-(void)hideBannerView
{
    if (mBannerView)
    {
        [UIView animateWithDuration:0.5
                              delay:0.1
                            options: UIViewAnimationCurveEaseOut
                         animations:^
         {
             CGRect frame = mBannerView.frame;
             frame.origin.y = off_y;
             frame.origin.x = off_x;
             mBannerView.frame = frame;
         }
                         completion:^(BOOL finished)
         {
             
             
         }];
    }
}


-(void)dismissAdView
{
    if (mBannerView)
    {
        [UIView animateWithDuration:0.5
                              delay:0.1
                            options: UIViewAnimationCurveEaseOut
                         animations:^
         {
             CGSize s = [[CCDirector sharedDirector] viewSize];
             
             CGRect frame = mBannerView.frame;
             frame.origin.y = frame.origin.y + frame.size.height ;
             frame.origin.x = (s.width/2.0f - frame.size.width/2.0f);
             mBannerView.frame = frame;
         }
                         completion:^(BOOL finished)
         {
             [mBannerView setDelegate:nil];
             [mBannerView removeFromSuperview];
             mBannerView = nil;
             
         }];
    }
    
}

//game helper delegate
-(void) onLocalPlayerAuthenticationChanged
{
	GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
	CCLOG(@"LocalPlayer isAuthenticated changed to: %@", localPlayer.authenticated ? @"YES" : @"NO");
	
	if (localPlayer.authenticated)
	{
        [GameKitHelper sharedInstance].isUserLogined = YES;
		//GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
		//[gkHelper getLocalPlayerFriends];
		//[gkHelper resetAchievements];
	}
}
-(void) onAchievementReported:(GKAchievement*)achievement
{
	CCLOG(@"onAchievementReported: %@", achievement);
}

-(void) onAchievementsLoaded:(NSDictionary*)achievements
{
	CCLOG(@"onLocalPlayerAchievementsLoaded: %@", [achievements description]);
}

-(void) onResetAchievements:(bool)success
{
	CCLOG(@"onResetAchievements: %@", success ? @"YES" : @"NO");
}

-(void) onLeaderboardViewDismissed
{
	CCLOG(@"onLeaderboardViewDismissed");
	
//	GameKitHelper* gkHelper = [GameKitHelper sharedInstance];
//	[gkHelper retrieveTop100AllTimeGlobalScores];
}

-(void) onAchievementsViewDismissed
{
	CCLOG(@"onAchievementsViewDismissed");
}

-(void) onReceivedMatchmakingActivity:(NSInteger)activity
{
	CCLOG(@"receivedMatchmakingActivity: %i", activity);
}

-(void) onMatchFound:(GKMatch*)match
{
	CCLOG(@"onMatchFound: %@", match);
}

-(void) onPlayersAddedToMatch:(bool)success
{
	CCLOG(@"onPlayersAddedToMatch: %@", success ? @"YES" : @"NO");
}

-(void) onMatchmakingViewDismissed
{
	CCLOG(@"onMatchmakingViewDismissed");
}
-(void) onMatchmakingViewError
{
	CCLOG(@"onMatchmakingViewError");
}

-(void) onPlayerConnected:(NSString*)playerID
{
	CCLOG(@"onPlayerConnected: %@", playerID);
}

-(void) onPlayerDisconnected:(NSString*)playerID
{
	CCLOG(@"onPlayerDisconnected: %@", playerID);
}

-(void) onStartMatch
{
	CCLOG(@"onStartMatch");
}

-(void) onReceivedData:(NSData*)data fromPlayer:(NSString*)playerID
{
	CCLOG(@"onReceivedData: %@ fromPlayer: %@", data, playerID);
}

-(void) onScoresSubmitted:(bool)success
{
	CCLOG(@"onScoresSubmitted: %@", success ? @"YES" : @"NO");
}

-(void) onScoresReceived:(NSArray*)scores
{
	CCLOG(@"onScoresReceived: %@", [scores description]);
	 GameKitHelper* gkHelper = [GameKitHelper sharedInstance];
	[gkHelper showLeaderboard];
}

@end
