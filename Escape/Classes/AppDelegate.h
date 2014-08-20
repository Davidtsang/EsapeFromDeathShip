//
//  AppDelegate.h
//  Escape
//
//  Created by user on 14-7-14.
//  Copyright david_tsang 2014年. All rights reserved.
//
// -----------------------------------------------------------------------

#import "cocos2d.h"
//#import <FacebookSDK/FacebookSDK.h>
#import "GADBannerView.h"
#import "ThisIAPHelper.h"
#import "GameKitHelper.h"
 
#import "UICKeyChainStore.h"

#define kMyAppID @"906580965"
#define kAPPStroeURL  @"https://itunes.apple.com/us/app/escape-from-death-ship/id906580965?mt=8"
#define ADMOB_BANNER_UNIT_ID @"ca-app-pub-3382314773591418/1563825481"

typedef enum _bannerType
{
    kBanner_Portrait_Top,
    kBanner_Portrait_Bottom,
    kBanner_Landscape_Top,
    kBanner_Landscape_Bottom,
}CocosBannerType;

#define BANNER_TYPE kBanner_Portrait_Top

@interface AppDelegate : CCAppDelegate
<GADBannerViewDelegate,GameKitHelperProtocol>
{
    CocosBannerType mBannerType;
    GADBannerView *mBannerView;
    float on_x, on_y, off_x, off_y;
    //UICKeyChainStore *_safeStore;
    
}
@property(nonatomic,strong)NSString *fbSessionState;
@property(nonatomic,assign)BOOL   isProVersion;
//@property(nonatomic,strong)KeychainItemWrapper *cherryIDSafeStore;
@property(nonatomic,strong)UICKeyChainStore * safeStore;
-(void)hideBannerView;
-(void)showBannerView;
-(void)makeIsProVersion;
-(BOOL)checkIsProVersion;

@end
