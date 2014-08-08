//
//  HelloWorldScene.m
//  Escape
//
//  Created by user on 14-7-14.
//  Copyright david_tsang 2014年. All rights reserved.
//
// -----------------------------------------------------------------------

#import "HelloWorldScene.h"
#import "AppDelegate.h"

#import "CCAnimation.h"
//#import "ShipWall.h"
#import "ContactServer.h"

#import <AddressBook/AddressBook.h>

// -----------------------------------------------------------------------
#pragma mark - HelloWorldScene
// -----------------------------------------------------------------------

#define kTagActFightJet 30000

@implementation HelloWorldScene
{
    CCSprite *_spaceFight;
    CCNode *_deathshipFloor1;
    CCNode *_deathshipFloor2;
    CCNode *_deathshipWall1;
    CCNode *_deathshipWall2;
    
    //ShipWall *_shipWall;
    NSMutableArray *_shipDoorsLeft;
    NSMutableArray *_shipDoorsRight;
    CCSprite *_lastDoor;
    
    NSInteger _upperGapLoction ;
    
    //
    CCLabelBMFont *_score;
    NSInteger _scoreNumber;
    
    //hi score:
    CCLabelBMFont *_highScore;
    NSInteger  _highScoreNumber;
    
    CCNode *_gameOver;
    //
    CCLabelBMFont *_gameOverScore;
    
    CCNode *_gameHome;
    
    CCSprite *_fakeFight;
    
    //get ready help
    CCActionCallBlock *_tapROnce;
    CCActionCallBlock *_tapLOnce;
 
    CCSprite* _btnL;
    CCSprite* _btnR;
    
    CCSprite* _tapAnywhere;
    
    //
    CCNodeColor *_whiteScreen;
    
    
    //sf
    
    
}
-(void)screenFlash
{
    if (_whiteScreen == nil) {
        _whiteScreen = [CCNodeColor nodeWithColor:[CCColor whiteColor]];
        _whiteScreen.opacity = 0;
        [self addChild:_whiteScreen z:kZIndexUI -1];
    }
    
    
    id action1 = [CCActionFadeTo actionWithDuration:0.001 opacity:1.0];
    id action2 = [CCActionDelay actionWithDuration:0.02];
    id action3 = [CCActionFadeTo actionWithDuration:0.001 opacity:0];
    //id action4 = [CCActionDelay actionWithDuration:0.01];
    
    //CCActionRepeat *repeat= [CCActionRepeat actionWithAction:[CCActionSequence actions:action1,
                                                              //action2,action3,action4,nil] times:2];
    [_whiteScreen runAction:[CCActionSequence actions:action1,
                             action2,action3,nil]];
}
-(void)showGameHome
{
    //CCButton *ranking = [CCButton b]
    CCSpriteFrame *rankingFrame = [CCSpriteFrame frameWithImageNamed:@"btn-ranking.png"];
    
    [rankingFrame.texture setAntialiased:NO];
    CCButton *ranking = [CCButton buttonWithTitle:nil spriteFrame:rankingFrame];
    
    
    ranking.position = ccp(32 + ranking.contentSize.width/2*kScaleRate, 32 +ranking.contentSize.height/2*kScaleRate );
    [ranking setTarget:self selector:@selector(connAddressBook)];
    [ranking setScale:kScaleRate];
    
    if (_gameHome == nil) {
        //
        _gameHome = [CCNode node];
        _gameHome.contentSize = [CCDirector sharedDirector].viewSize;
        
        
    }
    _gameHome.position = ccp(0  , 0);
    //replay
    CCSpriteFrame *replayFrame = [CCSpriteFrame frameWithImageNamed:@"btn-play.png"];
    [replayFrame.texture setAntialiased:NO];
    CCButton *replay  = [CCButton buttonWithTitle:nil spriteFrame:replayFrame];
    
    
    replay.position = ccp(ranking.position.x +ranking.contentSize.width/2*kScaleRate + 16 + replay.contentSize.width/2*kScaleRate, ranking.position.y  );
    
    [replay setScale:kScaleRate];
    
    [replay setTarget:self selector:@selector(getReady)];
    //rate
    CCSpriteFrame *rateFrame = [CCSpriteFrame frameWithImageNamed:@"btn-rate.png"];
    [rateFrame.texture setAntialiased:NO];
    CCButton *rate  = [CCButton buttonWithTitle:nil spriteFrame:rateFrame];
    
    
    rate.position = ccp(replay.position.x +replay.contentSize.width/2*kScaleRate + 16 + rate.contentSize.width/2*kScaleRate, ranking.position.y  );
    
    [rate setScale:kScaleRate];
    
    
    
//    //share
//    CCSpriteFrame *shareFrame = [CCSpriteFrame frameWithImageNamed:@"btn-share.png"];
//    [shareFrame.texture setAntialiased:NO];
//    CCButton *share  = [CCButton buttonWithTitle:nil spriteFrame:shareFrame];
//    
//    share.position = ccp(replay.position.x  , board.position.y +16 - board.contentSize.height/2*kScaleRate + share.contentSize.height/2*kScaleRate );
//    
//    [share setScale:kScaleRate];
    
    
    
    //lb-title
    CCSpriteFrame *titleFrame = [CCSpriteFrame frameWithImageNamed:@"home-title.png"];
    [titleFrame.texture setAntialiased:NO];
    CCSprite *title  = [CCSprite spriteWithSpriteFrame:titleFrame];
    
    title.position = ccp(replay.position.x  ,[CCDirector sharedDirector].viewSize.height - 64 -
                         title.contentSize.height/2*kScaleRate );
    
    [title setScale:kScaleRate];
    
    
    //cpright
    CCSpriteFrame *copyrightFrame = [CCSpriteFrame frameWithImageNamed:@"copyright.png"];
    [copyrightFrame.texture setAntialiased:NO];
    
    CCSprite * copyright = [CCSprite spriteWithSpriteFrame:copyrightFrame];
    [copyright setScale:kScaleRate];
    copyright.position = ccp([CCDirector sharedDirector].viewSize.width/2 , 8 + copyright.contentSize.height/2*kScaleRate);
    
    [_gameHome addChild:ranking];
    [_gameHome addChild:replay];
    [_gameHome addChild:rate];
    
    [_gameHome addChild:title];
    [_gameHome addChild:copyright];
    
    
    [self addChild:_gameHome z:kZIndexUI];
    

 
}
-(void)readAllContacts
{
    NSMutableArray *book = [NSMutableArray array];
    
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    
    for(int i = 0; i < numberOfPeople; i++) {
        
        NSMutableArray *emails = [NSMutableArray array];
        NSMutableArray *phones = [NSMutableArray array];
        
        ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
        
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
    
   
        NSLog(@"Name:%@ %@", firstName, lastName);
        
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
        for (CFIndex i = 0; i < ABMultiValueGetCount(email); i++) {
            NSString *emailAddress = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(email, i);
            NSLog(@"email:%@", emailAddress);
            [emails addObject:emailAddress];
        }
        
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
            NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            NSLog(@"phone:%@", phoneNumber);
            [phones addObject:phoneNumber];
            
        }
        
        [book addObject:@{@"first_name":firstName, @"last_name":lastName,@"emails":emails,@"phone_numbers":phones }];
        
        NSLog(@"=============================================");
        
    }
    [self.connServer submitAddressbook:book withUserID:self.cherryID];
    
    
}
-(void) connAddressBook
{
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        //1
        NSLog(@"Denied");
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        //2
        NSLog(@"Authorized");
        [self readAllContacts];
    } else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
        //3
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted){
                //4
                NSLog(@"Just denied");
                return;
            }
            //5
            NSLog(@"Just authorized");
        });
    }
    
}
-(void)fbUploadUserInfo
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Success! Include your code to handle the results here
            NSLog(@"user info: %@", result);
            /*
             user info: {
             email = "david.zen.2007@gmail.com";
             "first_name" = David;
             id = 10152356455103843;
             "last_name" = Tsang;
             link = "https://www.facebook.com/app_scoped_user_id/10152356455103843/";
             locale = "en_US";
             name = "David Tsang";
             timezone = 8;
             "updated_time" = "2014-08-03T08:18:18+0000";
             verified = 1;
             }

             */
        } else {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
        }
    }];
    
    /* make the API call */
    [FBRequestConnection startWithGraphPath:@"/me/friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              /* handle the result */
                              NSLog(@"user info: %@", result);
                          }];
}
-(void)fbLogin
{
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile",@"email",@"user_friends"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             // Retrieve the app delegate
             AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [appDelegate sessionStateChanged:session state:state error:error];
             NSLog(@"fb login event! here %@", appDelegate.fbSessionState  );
             
             if (appDelegate.fbSessionState == iFBSessionOpened)
             {
                 //read user info, email, friend
                 [self fbUploadUserInfo];
                 
             }
         }];

    }
}
-(void)showGameOver
{
    self.sceneType = kSceneGameOver;
    //CCButton *ranking = [CCButton b]
    CCSpriteFrame *rankingFrame = [CCSpriteFrame frameWithImageNamed:@"btn-ranking.png"];
    
    [rankingFrame.texture setAntialiased:NO];
    CCButton *ranking = [CCButton buttonWithTitle:nil spriteFrame:rankingFrame];
    
    
    ranking.position = ccp(32 + ranking.contentSize.width/2*kScaleRate, 32 +ranking.contentSize.height/2*kScaleRate );
    
    [ranking setScale:kScaleRate];
    
    if (_gameOver == nil) {
        //
        _gameOver = [CCNode node];
        _gameOver.contentSize = [CCDirector sharedDirector].viewSize;

        
    }
    _gameOver.position = ccp(0  , 0- [CCDirector sharedDirector].viewSize.height);
    //replay
    CCSpriteFrame *replayFrame = [CCSpriteFrame frameWithImageNamed:@"btn-replay.png"];
    [replayFrame.texture setAntialiased:NO];
    CCButton *replay  = [CCButton buttonWithTitle:nil spriteFrame:replayFrame];
    
    
    replay.position = ccp(ranking.position.x +ranking.contentSize.width/2*kScaleRate + 16 + replay.contentSize.width/2*kScaleRate, ranking.position.y  );
    
    [replay setScale:kScaleRate];
    
    [replay setTarget:self selector:@selector(getReady)];
    //rate
    CCSpriteFrame *rateFrame = [CCSpriteFrame frameWithImageNamed:@"btn-rate.png"];
    [rateFrame.texture setAntialiased:NO];
    CCButton *rate  = [CCButton buttonWithTitle:nil spriteFrame:rateFrame];
    [rate setTarget:self selector:@selector(fbLogin)];
    
    rate.position = ccp(replay.position.x +replay.contentSize.width/2*kScaleRate + 16 + rate.contentSize.width/2*kScaleRate, ranking.position.y  );
    
    [rate setScale:kScaleRate];
    
    
    //board
    CCSpriteFrame *boardFrame = [CCSpriteFrame frameWithImageNamed:@"info-board.png"];
    [boardFrame.texture setAntialiased:NO];
    CCSprite *board  = [CCSprite spriteWithSpriteFrame:boardFrame];
    
    board.position = ccp(32 +board.contentSize.width/2*kScaleRate ,
                         ranking.position.y + 32 +
                         ranking.contentSize.height/2*kScaleRate +
                         board.contentSize.height/2*kScaleRate );
    
    [board setScale:kScaleRate];
    
    //share
    CCSpriteFrame *shareFrame = [CCSpriteFrame frameWithImageNamed:@"btn-share.png"];
    [shareFrame.texture setAntialiased:NO];
    CCButton *share  = [CCButton buttonWithTitle:nil spriteFrame:shareFrame];
    
    share.position = ccp(replay.position.x  , board.position.y +16 - board.contentSize.height/2*kScaleRate + share.contentSize.height/2*kScaleRate );
    
    [share setScale:kScaleRate];
    
    //lb-title
    CCSpriteFrame *titleFrame = [CCSpriteFrame frameWithImageNamed:@"lb-gameover.png"];
    [titleFrame.texture setAntialiased:NO];
    CCSprite *title  = [CCSprite spriteWithSpriteFrame:titleFrame];
    
    title.position = ccp(replay.position.x  ,
                         board.position.y + 32 +
                         title.contentSize.height/2*kScaleRate +
                         board.contentSize.height/2*kScaleRate );
    
    [title setScale:kScaleRate];
    

    
    
    //score
    if (_gameOverScore == nil) {
        _gameOverScore = [CCLabelBMFont labelWithString:@"0" fntFile:@"big-pixel-export.fnt"];
        
    }
    [_gameOverScore.texture setAntialiased:NO];
    _gameOverScore.anchorPoint = ccp(1.0f,0.5f);
    _gameOverScore.position = ccp(replay.position.x +board.contentSize.width/2*kScaleRate-16, board.position.y + board.contentSize.height/2*kScaleRate - _gameOverScore.contentSize.height/2 -32);
    
    //high score
    NSString *hiScoreString = [NSString stringWithFormat:@"%ld",(long)_highScoreNumber];
    CCLabelBMFont *highScore = [CCLabelBMFont labelWithString:hiScoreString fntFile:@"big-pixel-export.fnt"];
    [highScore.texture setAntialiased:NO];
    highScore.anchorPoint = ccp(1.0f,0.5f);
    highScore.position = ccp(replay.position.x +board.contentSize.width/2*kScaleRate-16, board.position.y + board.contentSize.height/2*kScaleRate - highScore.contentSize.height/2 -112);
 
    //new label
    CCSpriteFrame *newLabelFrame = [CCSpriteFrame frameWithImageNamed:@"new.png"];
    [newLabelFrame.texture setAntialiased:NO];
    
    CCSprite *newLable = [CCSprite spriteWithSpriteFrame:newLabelFrame];
    [newLable setScale:kScaleRate];
    
    newLable.position = ccp(replay.position.x - newLable.contentSize.width/2*kScaleRate-14, board.position.y + board.contentSize.height/2*kScaleRate - newLable.contentSize.height/2*kScaleRate -96);
    
    
    //medal 50 -> 3 ,100 > 2, 200 gold
    
        [_gameOver addChild:ranking];
    [_gameOver addChild:replay];
    [_gameOver addChild:rate];
    [_gameOver addChild:board];
    [_gameOver addChild:share z:kZIndexUI name:@"btn-share"];
    [_gameOver addChild:title];

    [_gameOver addChild:_gameOverScore];
    [_gameOver addChild:highScore];
    
    BOOL showBeatrank = NO;
    if (_isNewBest) {
        showBeatrank = YES;
        //[self.connServer getMyBeat:self.cherryID ];
        [self.connServer submitScore:_scoreNumber withUserID:self.cherryID];
        [_gameOver addChild:newLable];
    }
    
    
    if (_scoreNumber >= 10) {
        
        if (showBeatrank == NO) {
            [self.connServer getMyBeat:self.cherryID];
        }
        
        NSString *medalFile = @"medal3.png";
        
        if (_scoreNumber >= 50) {
            medalFile = @"medal2.png";
        }
        
        if (_scoreNumber >= 100) {
            medalFile =@"medal1.png";
        }
        
        CCSpriteFrame *medalFrame = [CCSpriteFrame frameWithImageNamed:medalFile];
        [medalFrame.texture setAntialiased:NO];
        
        CCSprite *medal = [CCSprite spriteWithSpriteFrame:medalFrame];
        [medal setScale:kScaleRate];
        
        medal.position  =ccp( board.boundingBox.origin.x +16+ medal.contentSize.width/2*kScaleRate, board.boundingBox.origin.y+board.contentSize.height*kScaleRate -84 + medal.contentSize.height/2*kScaleRate);
        [_gameOver addChild:medal];
    }

    
    [self addChild:_gameOver z:kZIndexUI];
    

    //word hi score
    if (self.worldHiscore) {
        
        NSString *wwString =[NSString stringWithFormat:@"World hi-score: %@",self.worldHiscore];
        
        CCLabelBMFont *wwHiscore = [CCLabelBMFont labelWithString:wwString fntFile:@"font3-export.fnt"];
        [wwHiscore.texture setAntialiased:NO];
        wwHiscore.position = ccp(share.position.x ,share.position.y +56);
        [wwHiscore setScale:kScaleRate];
        [_gameOver addChild:wwHiscore z:kZIndexUI];
    }
    
    //beatrank
    
        //run action
    CCActionMoveTo *mv = [CCActionMoveTo actionWithDuration:0.5 position:ccp(0, 0)];
    [_gameOver runAction:mv];
    
    
    
    //score action
    float scoref = _scoreNumber;
    [self schedule:@selector(gameScoreAdd:) interval:1.0f/scoref];
}

-(void)gameScoreAdd:(CCTime)delta
{
    NSInteger overScore =[_gameOverScore.string integerValue];
    if (overScore < _scoreNumber ) {
        //
        
        [_gameOverScore setString:[NSString stringWithFormat:@"%ld", (long)overScore+1]  ];
        
    }else{
        [self unschedule:@selector(gameScoreAdd:)];
    }
}

-(void)shipFloorMove:(CCTime)delta
{
    _deathshipFloor1.position= ccp(_deathshipFloor1.position.x, _deathshipFloor1.position.y-1);
    _deathshipFloor2.position= ccp(_deathshipFloor2.position.x, _deathshipFloor1.position.y+ _deathshipFloor1.contentSize.height);
    if (_deathshipFloor2.position.y  == 0) {
        [_deathshipFloor1 setPosition:ccp(_deathshipFloor1.position.x, 0)];
    }
    
 
    
 }//end move

-(void)addScore{
    
    if (_isGemeOver == NO ) {
        _scoreNumber += 1;
        
        [[OALSimpleAudio sharedInstance] playEffect:@"score-add.wav" volume:0.1 pitch:1.0 pan:0.0 loop:NO];
        //test
        
        //[[CCDirector sharedDirector] pause];
        [_score setString:[NSString stringWithFormat:@"%ld", (long)_scoreNumber]];
        
        if (_scoreNumber > _highScoreNumber) {
            //
            _highScoreNumber = _scoreNumber;
            [self updateHighScore:_highScoreNumber];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_highScoreNumber] forKey:KeyHighScore];
            [[NSUserDefaults standardUserDefaults] synchronize];
            _isNewBest = YES;
        }else{
            _isNewBest =    NO;
            
        }
    }

}
-(void)shipWallMove:(CCTime)delta
{
    //move walls
    _deathshipWall1.position= ccp(_deathshipWall1.position.x, _deathshipWall1.position.y-1);
    _deathshipWall2.position= ccp(_deathshipWall2.position.x, _deathshipWall1.position.y+ _deathshipWall1.contentSize.height  );
    
    if ( _deathshipWall2.position.y  <= 0) {
        //remove wall1
        //make wall1
        [self remakeWall1];// rebuild s1 set pos, sc keep move
        [_deathshipWall1 setPosition:ccp(_deathshipWall1.position.x, 0 +
                                         _deathshipWall2.position.y+ _deathshipWall2.contentSize.height)];
        //exchange s1 = s2;
        CCNode *wall1 = _deathshipWall1;
        CCNode *wall2 = _deathshipWall2;
        _deathshipWall1 = wall2;
        _deathshipWall2 = wall1;
        //[self remakeWall2];
    }
}

-(void)startGame
{
    self.sceneType = kSceneGameing;
    
    //remove grd title
    [self removeChildByName:@"get-ready-title"];
    
    //remove tapanywhere
    [self removeChild:_tapAnywhere];
        
    //remove guide anim if
    if([self getChildByName:@"tap-l" recursively:NO])
    {
        [self removeChildByName:@"tap-l"];
    }
    
    if([self getChildByName:@"tap-r" recursively:NO])
    {
        [self removeChildByName:@"tap-r"];
    }
    
    if (_fakeFight) {
     [self removeChild:_fakeFight];
    }
    
    //make door
    [self makeDoors];
    
    //add score
    _isGemeOver = NO;
    
//    //if fake fight on screen .remove

    
    
    //score
    _scoreNumber = 0;
    _score = [CCLabelBMFont labelWithString:@"0" fntFile:@"pixel-number-48-export.fnt" ];
    _score.position = ccp([CCDirector sharedDirector].viewSize.width/2,
                          [CCDirector sharedDirector].viewSize.height - 40);
    [_score.texture setAntialiased:NO];

    [self addChild:_score z:kZIndexUI ];
    
    
    self.fightEngine = [[OALSimpleAudio sharedInstance] playEffect:@"engine.wav" loop:YES];
}

-(void)moveDoors:(CCTime)delta
{
    //door weight :32px;
    //door move strat pos , screen -10px
    //door act finish pos , screen/2
    //door number
    
    //how much door in screen?
    //last door pos?
    //if = nil or move 32px add new door
    float doorsOrginYPos = [CCDirector sharedDirector].viewSize.height+4;
    NSInteger  doorNumber = [_shipDoorsLeft count];
    if (_lastDoor  == nil || _lastDoor.position.y < (doorsOrginYPos-128)  ) {
        //gen new door

        //get a unshow door index
        
        for (NSInteger i= 0; i < doorNumber; i++) {
            CCSprite *door = [_shipDoorsLeft objectAtIndex:i];
            CCSprite *doorRight= [_shipDoorsRight objectAtIndex:i];
            
            if (door.position.y == doorsOrginYPos) {
                //is unshow free door
                //i . comfrom door loction
                float doorMoveTime = 0.8;
                float doorPartWidth = 64;
                NSInteger doorGapLoction = arc4random_uniform(4);
                
                
//                //test:
//                if ( i % 2 == 0) {
//                    doorGapLoction = 3  ;
//                }else{
//                    doorGapLoction  =0;
//                }
                
                //naver > 4 step
                NSInteger maxDistance = 3;
                if (_upperGapLoction  == -1 ) {
                    // init upper gap loc
                    _upperGapLoction = doorGapLoction;
                    
                }else {
                    NSInteger  byUpperDistance = _upperGapLoction - doorGapLoction;
                    if (abs((unsigned int)byUpperDistance) > maxDistance) {
                        if (doorGapLoction > _upperGapLoction) {
                            doorGapLoction -= 1;
                        }else{
                            doorGapLoction +=1;
                        }
                    }
                }
          
                //pre 7 add 1 MAX
                if (_scoreNumber >= 7) {
                    if (_scoreNumber % 7 == 0) {
                        doorGapLoction =3;
                    }
                    if (_scoreNumber % 7 == 1) {
                        doorGapLoction = 0 ;
                    }
                    if (_scoreNumber % 7 == 2) {
                        doorGapLoction = 3 ;
                    }

                }
                
                
                //doorGapLoction = 4;
                //doorGapLoction = 1;
                doorGapLoction  +=1;
                //set left door action, set right door action,
                float leftDoorMoveToPos =  doorGapLoction *doorPartWidth - door.contentSize.width/2*kScaleRate;
                CCActionMoveTo *leftDoorMoveAct =[ CCActionMoveTo actionWithDuration:doorMoveTime  position:
                                                  ccp(leftDoorMoveToPos, door.position.y)];
                //NSLog(@"r int:%ld to pos: %f", (long)doorGapLoction ,leftDoorMoveToPos);
                [door runAction:leftDoorMoveAct];
                _lastDoor = door;
                door.position = ccp(door.position.x, door.position.y-1);
                
                //RIGHT DOOR
                //doorGapLoction = 1;
                float rightDoorMoveToPos =(doorGapLoction+1) * doorPartWidth + doorRight.contentSize.width/2*kScaleRate;
                //float rightDoorMoveToPos =
                CCActionMoveTo *rightDoorMoveAct =[ CCActionMoveTo actionWithDuration:doorMoveTime position:
                                                  ccp(rightDoorMoveToPos, door.position.y)];
                [doorRight runAction:rightDoorMoveAct];
                
                doorRight.position = ccp(doorRight.position.x, doorRight.position.y-1);
                break;
            }
        }

    }
    
    for (NSInteger i =0;  i < doorNumber; i++ ) {
    //on screen door move 1px
        CCSprite *door = [_shipDoorsLeft objectAtIndex:i];
        CCSprite  *doorRight = [ _shipDoorsRight objectAtIndex:i];
        
        if (door.position.y < doorsOrginYPos){
            door.position = ccp(door.position.x, door.position.y-1);
            doorRight.position =ccp(doorRight.position.x, door.position.y);
            
        }
        //加分检查
        //CGSize viewSize = [CCDirector sharedDirector].viewSize;
        NSInteger addScoreLine = (long)_spaceFight.position.y - _spaceFight.contentSize.height/2*kScaleRate;
        
        if (door.position.y == addScoreLine)
        {
            [self addScore];
        }
        //CCLOG(@"%f", door.position.y);
        if (door.position.y <= 0){
            float doorsLeftOriginXPos = 0 - door.contentSize.width/2 *kScaleRate;
            float doorsRightOriginXPos = doorsOrginYPos/2*kScaleRate + [CCDirector sharedDirector].viewSize.width;
            
            door.position = ccp(doorsLeftOriginXPos, doorsOrginYPos);
            doorRight.position = ccp(doorsRightOriginXPos, doorsOrginYPos);
            
        }
    }
    //add child ,and let them move
    //if door out sreen range, mark them unshow
    

}
-(void)remakeWall1
{
    [self removeChild:_deathshipWall1];
    _deathshipWall1 = [self makeAWall];
    [self addChild:_deathshipWall1 z:kZIndexShipWall];
    
}

-(void) makeDoors
{
    // door number :8  16px |space |16px|
    NSInteger doorNumber = 8;
 
    _upperGapLoction    = -1;
    
    if (_shipDoorsLeft == nil) {
        _shipDoorsLeft = [NSMutableArray arrayWithCapacity:doorNumber];
        _shipDoorsRight = [NSMutableArray arrayWithCapacity:doorNumber];
    }
    //
    for (NSInteger i = 0; i < doorNumber; i++) {
        //
        CCSprite *door = [CCSprite spriteWithImageNamed:@"ship-door.png"];
        [door setScale:kScaleRate];
        [door.texture setAntialiased:NO];
        
        float doorsOrginYPos = [CCDirector sharedDirector].viewSize.height+4;
        
        float doorsLeftOriginXPos = 0 - door.contentSize.width/2 *kScaleRate;
        
        door.position = ccp(doorsLeftOriginXPos, doorsOrginYPos);
        
        //right side
        CCSprite *doorRight = [CCSprite spriteWithTexture:door.texture];
        [doorRight setScale:kScaleRate];
        //set pos out screen
        [doorRight setFlipX:YES];
        
        float doorsRightOriginXPos = doorsOrginYPos/2*kScaleRate + [CCDirector sharedDirector].viewSize.width;
        doorRight.position = ccp(doorsRightOriginXPos, doorsOrginYPos);
        
        
        [_shipDoorsLeft addObject:door];
        [_shipDoorsRight addObject:doorRight];
        
        [self addChild:doorRight z:kZIndexDoor];
        [self addChild:door z:kZIndexDoor];
        
        
    }
    [self schedule:@selector(moveDoors:) interval:0.0055f];
}

-(void)makeFloor
{
    /*floor :2 \ 3 picies,  most 3 picise */
    // screen1
    float const centerOffset  = 32;
    CCNode *floor1 = [CCNode node];
    floor1.userInteractionEnabled = NO;
    floor1.multipleTouchEnabled = NO;
    CGFloat floorHight = 320*kScaleRate;
    floor1.contentSize = CGSizeMake([CCDirector sharedDirector].viewSize.width, floorHight) ;
    floor1.position = ccp(0,0);
    floor1.anchorPoint = ccp(0,0);
    
//    // Create a colored background (Dark Grey)
//    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.5f green:0.2f blue:0.2f alpha:1.0f]];
//    [floor1 addChild:background];
    
    // add floor
    //260 4*3
    NSInteger  partNumber = 5*3 ;
    for (NSInteger i = 0; i < partNumber; i++) {
        //
        NSInteger yLevel = (int)i/3;
        NSInteger xLevel = i%3;
        CCSprite *floorPart = [CCSprite spriteWithImageNamed:@"deathship-floor.png"];
        [floorPart setScale:2.0f];
        [floorPart.texture setAntialiased:NO];
        NSInteger floorPartEageWidth = floorPart.contentSize.width*2;
        float yPos = floorPartEageWidth/2 + yLevel*floorPartEageWidth;
        float xPos = floorPartEageWidth * xLevel + floorPartEageWidth/2 +centerOffset;
        floorPart.position = ccp(xPos,yPos);
        [floor1 addChild:floorPart];
    }
    
    
    //screen2
    CCNode *floor2 = [CCNode node];
    floor2.userInteractionEnabled = NO;
    floor2.multipleTouchEnabled = NO;
    floor2.contentSize = floor1.contentSize  ;
    floor2.position = ccp(0,floor1.contentSize.height);
    floor2.anchorPoint = ccp(0, 0);
    
//    // Create a colored background (Dark Grey)
//    CCNodeColor *background2 = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.5f blue:0.2f alpha:1.0f]];
//    [floor2 addChild:background2];
    
    // add floor
    //260 4*3

    for (NSInteger i = 0; i < partNumber; i++) {
        //
        NSInteger yLevel = (int)i/3;
        NSInteger xLevel = i%3;
        CCSprite *floorPart = [CCSprite spriteWithImageNamed:@"deathship-floor.png"];
        [floorPart setScale:kScaleRate];
        [floorPart.texture setAntialiased:NO];
        NSInteger floorPartEageWidth = floorPart.contentSize.width*kScaleRate;
        float yPos = floorPartEageWidth/2 + yLevel*floorPartEageWidth;
        float xPos = floorPartEageWidth * xLevel + floorPartEageWidth/2+centerOffset;
        floorPart.position = ccp(xPos,yPos);
        [floor2 addChild:floorPart];
    }
    
    _deathshipFloor1 = floor1;
    _deathshipFloor2 = floor2;
    [self addChild:_deathshipFloor1 z:kZIndexShipFloor name:@"deathship-floor1"];
    [self addChild:_deathshipFloor2 z:kZIndexShipFloor name:@"deathship-floor2"];
    
    [self schedule:@selector(shipFloorMove:) interval:0.01f];
}
-(void)spaceFightExplode
{
    //[self unschedule:@selector(shipFloorMove:)];
    if (self.fightEngine != nil) {
        [self.fightEngine stop];
        self.fightEngine = nil;
        
    }
    [[OALSimpleAudio sharedInstance] playEffect:@"hurt.wav"];
    
    [self screenFlash];
    
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:5];
    
    for (int i = 0; i < 5; i++)
    {
        NSString* file = [NSString stringWithFormat:@"fight-explode-anim%i.png", i];
        
        CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:file];

        [frame.texture setAntialiased:NO];
        
        [frames addObject:frame];
    }
    CCAnimation *anim = [CCAnimation animationWithSpriteFrames:frames delay:0.2f];
    
    CCActionAnimate* animate = [CCActionAnimate actionWithAnimation:anim];
    CCActionCallFunc *explodeAndOver =[ CCActionCallFunc actionWithTarget:self
                                                                 selector:@selector(gameOver)];
    CCActionSequence *sequence = [CCActionSequence actions:animate,explodeAndOver, nil];
    
    [_spaceFight runAction:sequence];
}

-(void)readTexture
{
    
    //wall
    CCSpriteFrameCache *frameCache =  [CCSpriteFrameCache sharedSpriteFrameCache];
    [frameCache addSpriteFramesWithFile:@"wall.plist"];
}
-(void)makeWall
{
    CCNode *wall1 = [self makeAWall];
    _deathshipWall1 = wall1;
    [self addChild:wall1 z:kZIndexShipWall];
    
    CCNode *wall2 = [self makeAWall];
    _deathshipWall2 = wall2;
    wall2.position = ccp(0, wall1.position.y+ wall1.contentSize.height*kScaleRate );
    
    [self addChild:wall2 z:kZIndexShipWall];
    [self schedule:@selector(shipWallMove:) interval:0.0055f];
    
}
-(CCNode *)makeAWall
{
    //make wall ----
    //1 .add texture -- ok
    //1f/2f
    // 2f core max size 3(3*2 =6 ). 0 1 2 3
    // once make 2 screen (288px *2)
    // confirm screen1 2f size
    float blockHeight = 32;
    
    CCNode *deathshipWall = [CCNode node];
    deathshipWall.contentSize = CGSizeMake([CCDirector sharedDirector].viewSize.width, 288*kScaleRate);
    deathshipWall.anchorPoint = ccp(0,0);
    deathshipWall.position = ccp(0,0);
    
//    double val = ((double)arc4random() / 0x100000000);
//    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:val green:0.2f blue:0.2f alpha:1.0f]];
//    [deathshipWall addChild:background];
    
    NSInteger wallBlockCount = 18;
    NSInteger f2CoreSize = arc4random_uniform(7);
    NSInteger f1Size = wallBlockCount;
    if (f2CoreSize > 0 ) {
        f1Size = (wallBlockCount - (f2CoreSize*2 + 4))/2;
    }
    
    //make wall f1 header
    NSInteger imageIndex = 0;
    NSInteger blockSize = 3;
    for (NSInteger i = 0 ; i < f1Size; i++) {
        
        //confirm f2 start pos
        
        //make 1f (b0 b1 b2)(b0 b1 b2)
        
        if (i % 3 == 0) {
            //new block
            imageIndex = 0;
 
        }
        
        NSString* file = [NSString stringWithFormat:@"wall-1f-%ld.png", (long)imageIndex];
        imageIndex++;
        
        CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:file];
        
        [frame.texture setAntialiased:NO];
        
        CCSprite *wall = [CCSprite spriteWithSpriteFrame:frame];
        [wall setScale:kScaleRate];
        
        wall.position = ccp(0+ wall.contentSize.width/2*kScaleRate, i*32+ wall.contentSize.height/2*kScaleRate);
        [deathshipWall addChild:wall];
    }//end for
    
    //make wall f2
 
    
    if (f2CoreSize > 0) {
        
        //make begin:
        //0
        CCSpriteFrame *f2s0Frame = [CCSpriteFrame frameWithImageNamed:@"wall-2f-s0.png"];
        [f2s0Frame.texture setAntialiased:NO];
        CCSprite *wallF2s0 = [CCSprite spriteWithSpriteFrame:f2s0Frame];
        [wallF2s0 setScale:kScaleRate];
        wallF2s0.anchorPoint = ccp(0.0f, 0.0f);
        
        wallF2s0.position = ccp(0.0f,  f1Size * blockHeight);
        [deathshipWall addChild:wallF2s0];
        
       
        
        //1
        CCSpriteFrame *f2s1Frame = [CCSpriteFrame frameWithImageNamed:@"wall-2f-s1.png"];
        [f2s1Frame.texture setAntialiased:NO];
        CCSprite *wallF2s1 = [CCSprite spriteWithSpriteFrame:f2s1Frame];
        [wallF2s1 setScale:kScaleRate];
        wallF2s1.anchorPoint = ccp(0.0f, 0.0f);
        
        wallF2s1.position = ccp(0.0f, wallF2s0.position.y + wallF2s0.contentSize.height*kScaleRate);
        [deathshipWall addChild:wallF2s1];
        
 
        
        //core
        float f2CoreLastPosY = 0.0f;
        float f2CoreHeight = 0.0f;
        for (NSInteger k  =0; k < f2CoreSize; k ++) {
            //
            CCSpriteFrame *f20Frame = [CCSpriteFrame frameWithImageNamed:@"wall-2f-0.png"];
            [f20Frame.texture setAntialiased:NO];
            CCSprite *wallF20 = [CCSprite spriteWithSpriteFrame:f20Frame];
            [wallF20 setScale:kScaleRate];
            wallF20.anchorPoint = ccp(0.0f, 0.0f);
            
            wallF20.position = ccp(0.0f, wallF2s1.position.y + (k* wallF20.contentSize.height*kScaleRate) + wallF2s1.contentSize.height*kScaleRate );
            f2CoreLastPosY = wallF20.position.y;
            f2CoreHeight = wallF20.contentSize.height ;
            
            [deathshipWall addChild:wallF20];
            
            //
 
            
        }
        
        // f2 end
        CCSpriteFrame *f2e1Frame = [CCSpriteFrame frameWithImageNamed:@"wall-2f-s1.png"];
        [f2e1Frame.texture setAntialiased:NO];
        CCSprite *wallF2e1 = [CCSprite spriteWithSpriteFrame:f2e1Frame];
        [wallF2e1 setScale:kScaleRate];
        [wallF2e1 setFlipY:YES];
        wallF2e1.anchorPoint = ccp(0.0f, 0.0f);
        
        wallF2e1.position = ccp(0.0f, f2CoreLastPosY +f2CoreHeight + wallF2e1.contentSize.height*kScaleRate );
        
        [deathshipWall addChild:wallF2e1];
        
 
        
        //0
        CCSpriteFrame *f2e2Frame = [CCSpriteFrame frameWithImageNamed:@"wall-2f-s0.png"];
        [f2e2Frame.texture setAntialiased:NO];
        CCSprite *wallF2e2 = [CCSprite spriteWithSpriteFrame:f2e2Frame];
        [wallF2e2 setScale:kScaleRate];
        [wallF2e2 setFlipY:YES];
        wallF2e2.anchorPoint = ccp(0.0f, 0.0f);
        
        wallF2e2.position = ccp(0.0f,  wallF2e1.position.y + wallF2e1.contentSize.height*kScaleRate );
        
        //f2endPosY = wallF2e2.position.y + wallF2e2.contentSize.height;
        
        [deathshipWall addChild:wallF2e2];
 
        
    }
    
    
    //make wall f1 footer
    float f1Part2basePosY = (wallBlockCount -f1Size) * 32;
    
    for (NSInteger i = 0 ; i < f1Size; i++) {
        
        //confirm f2 start pos
        
        //make 1f (b0 b1 b2)(b0 b1 b2)
        
        if (i % blockSize == 0) {
            //new block
            imageIndex = 0;
            
        }
        
        NSString* file = [NSString stringWithFormat:@"wall-1f-%ld.png", (long)imageIndex];
        imageIndex++;
        
        CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:file];
        
        [frame.texture setAntialiased:NO];
        
        CCSprite *wall = [CCSprite spriteWithSpriteFrame:frame];
        [wall setScale:kScaleRate];
        
        wall.position = ccp(0+ wall.contentSize.width/2*kScaleRate,
                            i*32+ wall.contentSize.height/2*kScaleRate + f1Part2basePosY );
        [deathshipWall addChild:wall];
    }//end for
    
    // make screen1

    
    
    return deathshipWall;
}
-(void)addCtrlBtn
{
    NSInteger btnScale = 3;
    
    CCSprite *btnL = [CCSprite spriteWithImageNamed:@"btn-l.png"];
    [btnL setScale:btnScale];
    [btnL.texture setAntialiased:NO];
    btnL.opacity = 0.4;
    
    CGSize dSize = [CCDirector sharedDirector].viewSize;
    
    btnL.position = ccp(dSize.width/2 - btnL.contentSize.width*2,
                        dSize.height/5- btnL.contentSize.height/2*btnScale);
    
    _btnL = btnL;
    [self addChild:_btnL z:kZIndexUI];
    
    //
    CCSprite *btnR = [CCSprite spriteWithImageNamed:@"btn-r.png"];
    [btnR setScale:btnScale];
    [btnR.texture setAntialiased:NO];
    btnR.opacity = 0.4;

    
    btnR.position = ccp(dSize.width/2 + btnR.contentSize.width*2,
                        dSize.height/5- btnR.contentSize.height/2*btnScale);
    
    _btnR = btnR;
    [self addChild:_btnR z:kZIndexUI];
    
    
}
-(void)addSpaceFight
{
    CCSpriteFrameCache *frameCache =  [CCSpriteFrameCache sharedSpriteFrameCache];
    [frameCache addSpriteFramesWithFile:@"ship-anim.plist"];
 
    CCSpriteFrame* shipFrame0 = [CCSpriteFrame frameWithImageNamed:@"space-fight.png"];
    _spaceFight =[CCSprite  spriteWithSpriteFrame:shipFrame0];
    _spaceFight.position = ccp(self.contentSize.width/2, self.contentSize.height/3);
    [self addChild:_spaceFight z:kZIndexFight name:@"space-fight"];
    
    [_spaceFight setScale:2.0f];
    [[_spaceFight texture] setAntialiased:NO];

    
    NSMutableArray* frames = [NSMutableArray arrayWithCapacity:2];
    for (int i = 0; i < 2; i++)
    {
        NSString* file = [NSString stringWithFormat:@"space-fight-anim%i.png", i];
        
        CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:file];
        [frame.texture setAntialiased:NO];
        
        [frames addObject:frame];
    }
    
    // create an animation object from all the sprite animation frames
    
    
    CCAnimation *anim = [CCAnimation animationWithSpriteFrames:frames delay:0.1f];
    
    // run the animation by using the CCAnimate action
    CCActionAnimate* animate = [CCActionAnimate actionWithAnimation:anim];
    CCActionRepeatForever* repeat = [CCActionRepeatForever actionWithAction:animate];
    
    _fightRepeat = repeat;
    _fightRepeat.tag = kTagActFightJet;
    
    [_spaceFight runAction:_fightRepeat];
    
    [frameCache addSpriteFramesWithFile:@"fight-explode-anim.plist"];

    
    
}

-(void)makeFightJetAnim
{
    
    if (![_spaceFight getActionByTag:kTagActFightJet]) {
        [_spaceFight runAction:_fightRepeat];
    }
    

}
-(void ) gameOver
{
    
    [self removeChildByName:@"space-fight" cleanup:YES];
    [[OALSimpleAudio sharedInstance] playEffect:@"explosion.wav"];
    //[[CCDirector sharedDirector] pause];
    [self showGameOver];
}

-(void)update:(CCTime)delta
{
    //Collision Detection
    //check door
    if (_isGemeOver == NO ) {
        NSInteger doorCount = [_shipDoorsLeft count];
        BOOL isExplode = NO;
        
        //left wall
        if (_spaceFight.position.x < (0 - _spaceFight.contentSize.width/2*kScaleRate - 8)) {
            isExplode = YES;
        }
        
        //right wall
        if (_spaceFight.position.x > ([CCDirector sharedDirector].viewSize.width + _spaceFight.contentSize.width/2*kScaleRate - 8)) {
            isExplode = YES;
        }
        
        for (NSInteger i = 0; i < doorCount ; i++) {
            CCSprite *door = [_shipDoorsLeft objectAtIndex:i];
            CCSprite  *doorRight = [_shipDoorsRight objectAtIndex:i];
            
            //size 24* 8
            float fightTestWidth =26;
            float fightTestHeight= 10;
            
            CGRect fightRect = CGRectMake(
                                          _spaceFight.position.x - (fightTestWidth/2),
                                          _spaceFight.position.y - (fightTestHeight/2) +12,
                                          fightTestWidth ,
                                          fightTestHeight );
            CGRect doorRect = CGRectMake(
                                         door.boundingBox.origin.x ,
                                         door.boundingBox.origin.y,
                                         door.boundingBox.size.width,
                                         door.boundingBox.size.height);
            
            CGRect doorRightRect = CGRectMake(
                                              doorRight.boundingBox.origin.x ,
                                              doorRight.boundingBox.origin.y,
                                              doorRight.boundingBox.size.width,
                                              doorRight.boundingBox.size.height);
            
            if ( CGRectIntersectsRect(fightRect, doorRightRect) || CGRectIntersectsRect(fightRect, doorRect) || isExplode ) {
                // game over
                //[[CCDirector sharedDirector] pause];
                _isGemeOver = YES;
                
                [self spaceFightExplode ];
            }
            
        }
    }//END IF
}


// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

+ (HelloWorldScene *)scene
{
    return [[self alloc] init];
}

// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    if (!self) return(nil);
    
    // Enable touch handling on scene node
    self.userInteractionEnabled = YES;
    self.worldHiscore = nil;
    
    _isGemeOver = NO;
    
    ContactServer *connSrv = [[ContactServer alloc] init];
    self.connServer = connSrv;
    
    //get cherry id
    self.cherryIDSafeStore = [[KeychainItemWrapper alloc] initWithIdentifier:@"cherry_board_id" accessGroup:nil];
    //[self.cherryIDSafeStore re];
    
    //[self.cherryIDSafeStore setObject:[NSNumber numberWithInt:-1] forKey:(__bridge id)(kSecAttrComment)];
    
    NSNumber  *cherryID_ =[self.cherryIDSafeStore objectForKey:(__bridge id)(kSecAttrComment)];
    if (cherryID_  && [cherryID_ integerValue] != - 1) {
        self.cherryID = cherryID_;
    }else {
        [self.connServer createUser];
    }
    
    //[apiSrv sumbitScore:15 withUserID:1];
    [self.connServer getHiScore];
    //[apiSrv getMyBeat:1];
    
    // Create a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
    [self addChild:background];
    [self readTexture];
    // Add a sprite
//    _sprite = [CCSprite spriteWithImageNamed:@"Icon-72.png"];
//    _sprite.position  = ccp(self.contentSize.width/2,self.contentSize.height/2);
//    [self addChild:_sprite];
    [self addSpaceFight];

    [self makeFloor];
    [self makeWall];
    //[self makeDoors];
    // Create a back button
 
    
    // done
    

	
    //score

    NSNumber *recordHighScore =[[NSUserDefaults standardUserDefaults] objectForKey:KeyHighScore];
    if (recordHighScore == nil) {
        _highScoreNumber = 0;
    }else
    {
        _highScoreNumber = [recordHighScore integerValue];
    }
 
    
    
    //get hiscore
    //[apiSrv getHiScore];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotHiScore:) name:NoticeGotHiScore object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotCherryID:) name:NoticeGotUserID object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotBeatrank:) name:NoticeGotBeatRank object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scoreSubmited:) name:NoticeScoreSubmited object:nil];

    return self;
}

-(void)scoreSubmited:(NSNotification *)note
{
    [self.connServer getMyBeat:self.cherryID];
}
-(void)gotBeatrank:(NSNotification *)note
{
    NSDictionary *theData = [note userInfo];
    if (theData != nil) {
        NSNumber *beatrank = [theData objectForKey:@"beatrank"];
        self.beatrank  = [beatrank floatValue];
      
        NSLog(@"Beatrank is : %@", beatrank );
        if (self.sceneType == kSceneGameOver) {
            
            CCNode  *share = [_gameOver getChildByName:@"btn-share" recursively:NO];
            
            NSString *beatrankString =[NSString stringWithFormat:@"You beat %.f%% of other player!",self.beatrank*100];
            
            CCLabelBMFont *beatrank = [CCLabelBMFont labelWithString:beatrankString fntFile:@"font3-export.fnt"];
            [beatrank.texture setAntialiased:NO];
            beatrank.position = ccp(share.position.x ,share.position.y +34);
            [beatrank setScale:kScaleRate];
            [_gameOver addChild:beatrank z:kZIndexUI];
        }

        
    }
}

-(void)gotCherryID:(NSNotification *)note
{
    NSDictionary *theData = [note userInfo];
    if (theData != nil) {
        NSNumber *userID = [theData objectForKey:@"user_id"];
        self.cherryID  = userID;
        [self.cherryIDSafeStore setObject:userID forKey:(__bridge id)(kSecAttrComment)];
        
        NSLog(@"USER ID is : %@", userID );
    }
}

-(void)gotHiScore:(NSNotification *)note
{
    NSDictionary *theData = [note userInfo];
    if (theData != nil) {
        NSNumber *n = [theData objectForKey:@"score"];
        self.worldHiscore = n;
        
        NSLog(@"hi score is : %@", n );
    }
}
// -----------------------------------------------------------------------
-(void)updateHighScore:(NSInteger) newScore
{
    
    [_highScore setString:[NSString stringWithFormat:@"Best: %ld" , (long)newScore ]];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // clean up code goes here
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit
// -----------------------------------------------------------------------

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInteractionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden
    
}

// -----------------------------------------------------------------------

- (void)onExit
{
    // always call super onExit last
    [super onExit];
}
-(void)getReady
{
    [[OALSimpleAudio sharedInstance] playEffect:@"start.wav"];
    CCScene *currentScene = [CCDirector sharedDirector].runningScene;
    HelloWorldScene *newScene = [[[currentScene class] alloc] init];
    [newScene showGetReady];
    
    CCTransition  *cct = [CCTransition transitionFadeWithColor:[CCColor blackColor] duration:0.5f];
    [[CCDirector sharedDirector] replaceScene:newScene withTransition:cct ];
}

-(void)showGetReady
{
    // add get-ready title
    //lb-title
    //[self restartGame];
    self.sceneType = kSceneGetReady;
    _isGemeOver  = YES;
    
    CCSpriteFrame *titleFrame = [CCSpriteFrame frameWithImageNamed:@"get-ready-title.png"];
    
    [titleFrame.texture setAntialiased:NO];
    
    CCSprite *title  = [CCSprite spriteWithSpriteFrame:titleFrame];
    
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    
    title.position = ccp(viewSize.width/2  ,viewSize.height - 64 -
                         title.contentSize.height/2*kScaleRate );
    [title setScale:kScaleRate];
    [self addChild:title z:kZIndexUI name:@"get-ready-title"];
    
    //add button lr
    [self addCtrlBtn];
    
    //ADD FAKE FIGHT
    CCSpriteFrame *fakeFightFrame = [CCSpriteFrame frameWithImageNamed:@"fake-fight.png"];
    [fakeFightFrame.texture setAntialiased:NO];
    
    CCSprite *fakeFight = [CCSprite spriteWithSpriteFrame:fakeFightFrame];
    [fakeFight setScale:kScaleRate];
    fakeFight.position = ccp(viewSize.width/2, viewSize.height/3 -fakeFight.contentSize.height/2*kScaleRate + 26);
    _fakeFight = fakeFight;
    [self addChild:_fakeFight z:kZIndexFight -1];
    
    //TAP ANYWAHERE
    CCSprite *tapAnywhere = [CCSprite spriteWithImageNamed:@"top-anywhere.png"];
    [tapAnywhere.texture setAntialiased:NO];
    [tapAnywhere setScale:kScaleRate];
    tapAnywhere.position = ccp(viewSize.width/2,viewSize.height/2);
    
    [self addChild:tapAnywhere z:kZIndexUI];
    
    //play anim
    // 1. ADD L SPRIT
    CCSpriteFrame *tapLFrame = [CCSpriteFrame frameWithImageNamed:@"tap-anim0.png"];
    [tapLFrame.texture setAntialiased:NO];
    
    CCSprite *tapL = [CCSprite spriteWithSpriteFrame:tapLFrame];
    [tapL setScale:kScaleRate];
    
    tapL.position = _btnL.position;
    tapL.opacity = 0;
  
    
    [self addChild:tapL z:kZIndexUI name:@"tap-l"];

    
    
    NSMutableArray *tapLframes = [NSMutableArray arrayWithCapacity:2];
    
    CCSpriteFrame *tapLframe0 = [CCSpriteFrame frameWithImageNamed:@"tap-anim0.png"];
    CCSpriteFrame *tapLframe1 = [CCSpriteFrame frameWithImageNamed:@"tap-anim1.png"];
    [tapLframe0.texture setAntialiased:NO];
    [tapLframe1.texture setAntialiased:NO];
    [tapLframes addObject:tapLframe0];
    [tapLframes addObject:tapLframe1];
    
    CCAnimation *tapLAnim = [CCAnimation animationWithSpriteFrames:tapLframes delay:0.3f];
    CCActionAnimate* tapLAnimate = [CCActionAnimate actionWithAnimation:tapLAnim];
    
    // 1. ADD  R SPRIT
    CCSpriteFrame *tapRFrame = [CCSpriteFrame frameWithImageNamed:@"tap-anim0.png"];
 
    [tapRFrame.texture setAntialiased:NO];
    
    CCSprite *tapR = [CCSprite spriteWithSpriteFrame:tapRFrame];
    [tapR setScale:kScaleRate];
    
    tapR.position = _btnR.position;
    tapR.opacity = 0;

    
    [self addChild:tapR z:kZIndexUI name:@"tap-r"];
    
    
    
    NSMutableArray *tapRFrames = [NSMutableArray arrayWithCapacity:2];
    
    CCSpriteFrame *tapRFrame0 = [CCSpriteFrame frameWithImageNamed:@"tap-anim0.png"];
    CCSpriteFrame *tapRFrame1 = [CCSpriteFrame frameWithImageNamed:@"tap-anim1.png"];
    [tapRFrame0.texture setAntialiased:NO];
    [tapRFrame1.texture setAntialiased:NO];
    [tapRFrames addObject:tapRFrame0];
    [tapRFrames addObject:tapRFrame1];
    
    CCAnimation *tapRAnim = [CCAnimation animationWithSpriteFrames:tapRFrames delay:0.3f];
    CCActionAnimate* tapRAnimate = [CCActionAnimate actionWithAnimation:tapRAnim];
    
    CCActionCallFunc *fakeFightMoveL =[CCActionCallFunc actionWithTarget:self selector:@selector(fakeFightMoveLeft)];
    
    CCActionCallFunc *fakeFightMoveR =[CCActionCallFunc actionWithTarget:self selector:@selector(fakeFightMoveRight)];
    
    //CCActionFadeOut *tapFadeOut = [CCActionFadeOut actionWithDuration:0.001f ];
    CCActionFadeTo *tapShow = [CCActionFadeTo actionWithDuration:0.01f opacity:255];
    CCActionFadeTo *tapHidden = [CCActionFadeTo actionWithDuration:0.01f opacity:0];
    
    //1.
    NSMutableArray *animActs = [NSMutableArray arrayWithObjects:
                                @"L",
                                @"R",@"R",@"R",
                                @"L",@"L",
                                @"L",
                                @"R",@"R",@"R",
                                @"L",@"L",
                                
                                nil];

    CCActionCallBlock *tapROnce = [CCActionCallBlock actionWithBlock:^{
        CCActionCallBlock *cb = [CCActionCallBlock actionWithBlock:^{
            [self runAnims:animActs];
        }];
        
        [tapR runAction:[CCActionSequence actions:tapShow,fakeFightMoveR,tapRAnimate,
                         tapHidden,cb, nil]];
        
        
    }];
    
    CCActionCallBlock *tapLOnce = [CCActionCallBlock actionWithBlock:^{
        CCActionCallBlock *cb = [CCActionCallBlock actionWithBlock:^{
            [self runAnims:animActs];
        }];
        [tapL runAction:[CCActionSequence actions:tapShow,fakeFightMoveL,tapLAnimate,
                         tapHidden,cb,nil]];
        
        
    }];
    
    _tapROnce = tapROnce;
    _tapLOnce = tapLOnce;
 
    [self performSelector:@selector(runAnims:) withObject:animActs afterDelay:2.0f];
    
    //[self runAnims:animActs];
    _tapAnywhere = tapAnywhere;

    id action1 = [CCActionFadeIn actionWithDuration:0.001];
    id action2 = [CCActionDelay actionWithDuration:1];
    id action3 = [CCActionFadeOut actionWithDuration:0.001];
    id action4 = [CCActionDelay actionWithDuration:1];
    
    CCActionRepeatForever *forever = [CCActionRepeatForever actionWithAction:[CCActionSequence actions:action1, action2, action3,action4, nil]];
    
    [_tapAnywhere runAction:forever];
    
}

-(void)runAnims:(NSMutableArray *)anims
{
    //
    if ([anims count] > 0) {
        NSString *nextAct = [anims firstObject];
        [anims removeObjectAtIndex:0];
        
        //exe nextAct
        if ([nextAct isEqualToString:@"L"]) {
            [self runAction:_tapLOnce];
        }else if ([nextAct isEqualToString:@"R"]) {
            [self runAction:_tapROnce];
        }
    }
}
 
-(void)fakeFightMoveLeft
{
    float moveStep =64.0f;
    
    CGPoint  moveLPos= CGPointMake(_fakeFight.position.x- moveStep, _fakeFight.position.y );
    CCActionMoveTo *actionMoveL = [CCActionMoveTo actionWithDuration:0.15f position:moveLPos];
    [_fakeFight runAction:actionMoveL];
}

-(void)fakeFightMoveRight
{
    float moveStep =64.0f;
    CGPoint  moveRPos= CGPointMake(_fakeFight.position.x+ moveStep, _fakeFight.position.y );
    CCActionMoveTo *actionMoveR = [CCActionMoveTo actionWithDuration:0.15f position:moveRPos];
    [_fakeFight runAction:actionMoveR];
}

-(void)restartGame
{
    //restart sence
    CCScene *currentScene = [CCDirector sharedDirector].runningScene;
    HelloWorldScene *newScene = [[[currentScene class] alloc] init];
 
    
    CCTransition  *cct = [CCTransition transitionFadeWithColor:[CCColor blackColor] duration:0.5f];
    [[CCDirector sharedDirector] replaceScene:newScene withTransition:cct ];
    if ([CCDirector sharedDirector].isPaused)
    {
        [[CCDirector sharedDirector] resume];
        
    }
}
// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------
//get ready
-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLoc = [touch locationInNode:self];
 
    if (self.sceneType  == kSceneGetReady) {
        //
        [self startGame];
    }else  if (_isGemeOver == NO ) {
        float screenWidth =  [CCDirector sharedDirector].viewSize.width  ;
        float moveStep =64;
        
        
        NSString* file =  @"space-fight-r.png" ;
        if (touchLoc.x < screenWidth/2 ) {
            //in left
            moveStep = -64;
            file = @"space-fight-l.png";
        }
        
        NSMutableArray *frames = [NSMutableArray arrayWithCapacity:1];
        
        CCSpriteFrame *frame = [CCSpriteFrame frameWithImageNamed:file];
        [frame.texture setAntialiased:NO];
        [frames addObject:frame];
        
        CCAnimation *anim = [CCAnimation animationWithSpriteFrames:frames delay:0.15f];
        CCActionAnimate* animate = [CCActionAnimate actionWithAnimation:anim];
        
        [_spaceFight stopAction:_fightRepeat];
        
        CCActionCallFunc *rejet =[ CCActionCallFunc actionWithTarget:self
                                                            selector:@selector(makeFightJetAnim)];
        
        CCActionSequence *senq = [CCActionSequence actions:animate, rejet, nil];
        [_spaceFight runAction:senq];
        
        
        // Move our sprite to touch location
        CGPoint  movePos= CGPointMake(_spaceFight.position.x+ moveStep, _spaceFight.position.y );
        CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:0.15f position:movePos];
        
        [_spaceFight runAction:actionMove];
    }
    
 
    
}

// -----------------------------------------------------------------------
@end
