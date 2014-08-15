//
//  HelloWorldScene.h
//  Escape
//
//  Created by user on 14-7-14.
//  Copyright david_tsang 2014年. All rights reserved.
//
// -----------------------------------------------------------------------

// Importing cocos2d.h and cocos2d-ui.h, will import anything you need to start using Cocos2D v3
#import "cocos2d.h"
#import "cocos2d-ui.h"
#import "AppDelegate.h"

static NSString *KeyHighScore = @"high_score";
static NSString *kCoins =@"game_coins";

// -----------------------------------------------------------------------

#define kSceneHome 20
#define kSceneGetReady 21
#define kSceneGameOver 22
#define kSceneGameing 23

#define kScoreSubmitLine 25

/**
 *  The main scene
 */
#define kFirstRunCoins 50

@class  ContactServer;

@interface HelloWorldScene : CCScene
<UIActionSheetDelegate >
{
    CCActionRepeatForever *_fightRepeat;
    BOOL _isGemeOver;
    BOOL _isNewBest;
    
    AppDelegate *_appDelegate;
}
// -----------------------------------------------------------------------
@property(nonatomic,assign)NSInteger sceneType;
@property(nonatomic,strong) id<ALSoundSource> fightEngine;

@property(nonatomic,strong)NSNumber *cherryID;
@property(nonatomic,strong)NSNumber *worldHiscore;
@property(nonatomic,assign)float beatrank;
@property(nonatomic,strong)ContactServer *connServer;
@property(nonatomic,assign)NSInteger coinNum;
+ (HelloWorldScene *)scene;
- (id)init;

// -----------------------------------------------------------------------
-(void)showGameHome;
-(void)showGetReady;
@end