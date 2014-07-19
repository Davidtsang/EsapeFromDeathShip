//
//  HelloWorldScene.m
//  Escape
//
//  Created by user on 14-7-14.
//  Copyright david_tsang 2014年. All rights reserved.
//
// -----------------------------------------------------------------------

#import "HelloWorldScene.h"
#import "IntroScene.h"
#import "CCAnimation.h"
//#import "ShipWall.h"


// -----------------------------------------------------------------------
#pragma mark - HelloWorldScene
// -----------------------------------------------------------------------



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
    
}


-(void)shipFloorMove:(CCTime)delta
{
    _deathshipFloor1.position= ccp(_deathshipFloor1.position.x, _deathshipFloor1.position.y-2);
    _deathshipFloor2.position= ccp(_deathshipFloor2.position.x, _deathshipFloor1.position.y+ _deathshipFloor1.contentSize.height );
    if (_deathshipFloor2.position.y <= 0) {
        [_deathshipFloor1 setPosition:ccp(_deathshipFloor1.position.x, 0)];
    }
    
   //move door
    //get a pos out screen door
    [self moveDoors];
    
 }//end move

-(void)addScore{
    
    _scoreNumber += 1;
    
    [[OALSimpleAudio sharedInstance] playEffect:@"score-add.wav"];
    //test
    
    //[[CCDirector sharedDirector] pause];
    [_score setString:[NSString stringWithFormat:@"%ld", (long)_scoreNumber]];
}
-(void)moveDoors
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
                
                
                //test:
//                if ( i % 2 == 0) {
//                    doorGapLoction = 4  ;
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
          
                
                //doorGapLoction = 4;
                //doorGapLoction = 1;
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
        CGSize viewSize = [CCDirector sharedDirector].viewSize;
        float addScoreLine = viewSize.height/3 - _spaceFight.contentSize.height*kScaleRate+door.contentSize.height/2 ;
        
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
 
}

-(void)makeFloor
{
    /*floor :2 \ 3 picies,  most 3 picise */
    // screen1
    float const centerOffset  = 32;
    CCNode *floor1 = [CCNode node];
    floor1.userInteractionEnabled = NO;
    floor1.multipleTouchEnabled = NO;
    CGFloat floorHight = 64*4;
    floor1.contentSize = CGSizeMake([CCDirector sharedDirector].viewSize.width, floorHight) ;
    floor1.position = ccp(0,0);
    
//    // Create a colored background (Dark Grey)
//    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.5f green:0.2f blue:0.2f alpha:1.0f]];
//    [floor1 addChild:background];
    
    // add floor
    //260 4*3
    NSInteger  partNumber = 4*3 ;
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
    
    [self schedule:@selector(shipFloorMove:) interval:0.0055f];
}
-(void)addSpaceFight
{
    CCSpriteFrameCache *frameCache =  [CCSpriteFrameCache sharedSpriteFrameCache];
    [frameCache addSpriteFramesWithFile:@"ship-anim.plist"];
 
    CCSpriteFrame* shipFrame0 = [frameCache spriteFrameByName:@"ship-anim0.png"];
    _spaceFight =[CCSprite  spriteWithSpriteFrame:shipFrame0];
    _spaceFight.position = ccp(self.contentSize.width/2, self.contentSize.height/3);
    [self addChild:_spaceFight z:kZIndexFight];
    
    [_spaceFight setScale:2.0f];
    [[_spaceFight texture] setAntialiased:NO];
    // Animate sprite with action
    //CCActionRotateBy* actionSpin = [CCActionRotateBy actionWithDuration:1.5f angle:360];
    //[//_spaceFight runAction:[CCActionRepeatForever actionWithAction:actionSpin]];
    // load the ship's animation frames as textures and create a sprite frame
    NSMutableArray* frames = [NSMutableArray arrayWithCapacity:4];
    for (int i = 0; i < 4; i++)
    {
        NSString* file = [NSString stringWithFormat:@"ship-anim%i.png", i];

        CCSpriteFrame *frame = [frameCache spriteFrameByName:file];
        [frames addObject:frame];
    }
    
    // create an animation object from all the sprite animation frames
    //CCAnimation* anim = [CCAnimation animationWithName:@"move" delay:0.08f frames:frames];
    CCAnimation *anim = [CCAnimation animationWithSpriteFrames:frames delay:0.1f];
    //CCAnimation *anim = [CCAnimation ;
    // add the animation to the sprite
    //[self addAnimation:anim];
    
    // run the animation by using the CCAnimate action
    CCActionAnimate* animate = [CCActionAnimate actionWithAnimation:anim];
    CCActionRepeatForever* repeat = [CCActionRepeatForever actionWithAction:animate];
    //[_spaceFight runAction:repeat];
 
    
}
-(void ) gameOver
{
    [[OALSimpleAudio sharedInstance] playEffect:@"explosion.wav"];
    [[CCDirector sharedDirector] pause];
}

-(void)update:(CCTime)delta
{
    //Collision Detection
    //check door
    NSInteger doorCount = [_shipDoorsLeft count];
    
    for (NSInteger i = 0; i < doorCount ; i++) {
        CCSprite *door = [_shipDoorsLeft objectAtIndex:i];
        CCSprite  *doorRight = [_shipDoorsRight objectAtIndex:i];
        
        float fightTestWidth =32;
        float fightTestHeight= 10;
        
        CGRect fightRect = CGRectMake(
                                       _spaceFight.position.x - (fightTestWidth/2*kScaleRate),
                                       _spaceFight.position.y - (fightTestHeight/2*kScaleRate),
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
        
        if ( CGRectIntersectsRect(fightRect, doorRightRect) || CGRectIntersectsRect(fightRect, doorRect) ) {
            // game over
            [self gameOver];
        }
        
    }
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
    
    // Create a colored background (Dark Grey)
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
    [self addChild:background];
    
    // Add a sprite
//    _sprite = [CCSprite spriteWithImageNamed:@"Icon-72.png"];
//    _sprite.position  = ccp(self.contentSize.width/2,self.contentSize.height/2);
//    [self addChild:_sprite];
    [self addSpaceFight];

    [self makeFloor];
    //[self makeWall];
    [self makeDoors];
    // Create a back button
    CCButton *backButton = [CCButton buttonWithTitle:@"[ Menu ]" fontName:@"Verdana-Bold" fontSize:18.0f];
    backButton.positionType = CCPositionTypeNormalized;
    backButton.position = ccp(0.85f, 0.95f); // Top Right of screen
    [backButton setTarget:self selector:@selector(onBackClicked:)];
    [self addChild:backButton];

    // done
    
    //score
    _scoreNumber = 0;
    _score = [CCLabelBMFont labelWithString:@"0" fntFile:@"small-pixel.fnt" ];
    _score.position = ccp([CCDirector sharedDirector].viewSize.width/2,
                          [CCDirector sharedDirector].viewSize.height - 40);
    [_score.texture setAntialiased:NO];
    //[_score setScale:kScaleRate];
    
    [self addChild:_score z:kZIndexUI ];
	
    return self;
}

// -----------------------------------------------------------------------

- (void)dealloc
{
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

// -----------------------------------------------------------------------
#pragma mark - Touch Handler
// -----------------------------------------------------------------------

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchLoc = [touch locationInNode:self];
    
    // Log touch location
    NSLog(@"touch...");
    
    if ([CCDirector sharedDirector].isPaused)
    {
        //restart sence
        CCScene *currentScene = [CCDirector sharedDirector].runningScene;
        CCScene *newScene = [[[currentScene class] alloc] init];
        [[CCDirector sharedDirector] replaceScene:newScene];
        [[CCDirector sharedDirector] resume];
    }
  
    //CCLOG(@"Move sprite to @ %@",NSStringFromCGPoint(touchLoc));
    float screenWidth =  [CCDirector sharedDirector].viewSize.width  ;
    float moveStep =64;
    
    if (touchLoc.x < screenWidth/2 ) {
        //in left
        moveStep = -64;
    }
    
    // Move our sprite to touch location
    CGPoint  movePos= CGPointMake(_spaceFight.position.x+ moveStep, _spaceFight.position.y );
    CCActionMoveTo *actionMove = [CCActionMoveTo actionWithDuration:0.15f position:movePos];
    [_spaceFight runAction:actionMove];
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks
// -----------------------------------------------------------------------

- (void)onBackClicked:(id)sender
{
    // back to intro scene with transition
    [[CCDirector sharedDirector] replaceScene:[IntroScene scene]
                               withTransition:[CCTransition transitionPushWithDirection:CCTransitionDirectionRight duration:1.0f]];
}

// -----------------------------------------------------------------------
@end
