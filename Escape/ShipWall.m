//
//  ShipWall.m
//  Escape
//
//  Created by user on 14-7-17.
//  Copyright (c) 2014年 david_tsang. All rights reserved.
//

#import "ShipWall.h"
#import "cocos2d.h"

NSInteger const WALL_TILE_SIZE = 16;
NSInteger const MAX_TILE_NUMBER = 18;
static NSInteger  wallHeight = 16*18* kScaleRate;//288px;

@implementation ShipWall

-(CCNode *)getAnRandomWall
{
    // l ,r side have wall , sometime have door, door can active
    //1. make wall
    // wall wall-header,wall-0,wall-1 *** wall-footer
    // wall length 4~20

    
    // i. conform wall length
    // ii. build wall(l,r)
    
    
    CCNode *deathshipWall =[CCNode node];
    deathshipWall.contentSize =  CGSizeMake([CCDirector sharedDirector].viewSize.width, wallHeight)  ;
    deathshipWall.position = ccp(0, 0);
    deathshipWall.userInteractionEnabled = NO;
    
    //    //test
        CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.5f alpha:1.0f]];
        [deathshipWall addChild:background  ];
    
    // header wall
    CCSprite *wallHeader = [CCSprite spriteWithImageNamed:@"wall-header.png"];
    [wallHeader setScale:kScaleRate];
    [wallHeader.texture setAntialiased:NO];
    
    
    //random start 1~4* 16px
    NSInteger randomStartY = arc4random_uniform(2)*2;
    float startYpos= randomStartY * WALL_TILE_SIZE * kScaleRate ;
    
    NSInteger maxWallLen = MAX_TILE_NUMBER - randomStartY;
    NSInteger   randomInt = arc4random_uniform((unsigned int)maxWallLen);
    NSInteger wallLen = randomInt +4;
    
    wallHeader.position= ccp(wallHeader.contentSize.width/2 *kScaleRate, startYpos + wallHeader.contentSize.height/2*kScaleRate);
    
    //r header
    CCSprite *wallHeaderR = [CCSprite spriteWithTexture:wallHeader.texture];
    [wallHeaderR setScale:kScaleRate];
    wallHeaderR.flipX = YES;
    
    wallHeaderR.position   = ccp(deathshipWall.contentSize.width - wallHeaderR.contentSize.width /2*kScaleRate, wallHeader.position.y);
    
    
    [deathshipWall addChild:wallHeader];
    [deathshipWall addChild:wallHeaderR];
    
    for (NSInteger i =0; i < wallLen; i++) {
        
        CCSprite *wallPart;
        CCSprite *wallPartR;
        if (i % 2 != 0) {
            //signle wall
            wallPart = [CCSprite spriteWithImageNamed:@"wall-0.png"];
            //wallPartR = [CCSprite spriteWithImageNamed:@"wall-0.png"];
            
        }else{
            wallPart = [CCSprite spriteWithImageNamed:@"wall-1.png"];
            //wallPartR = [CCSprite spriteWithImageNamed:@"wall-1.png"];
        }
        
        [wallPart setScale:kScaleRate];
        [wallPart.texture setAntialiased:NO];
        
        //[wallPartR setScale:kScaleRate];
        //[wallPartR.texture setAntialiased:NO];
        // iii, set postion ,
        float yPos = wallHeader.position.y + wallPart.contentSize.height * kScaleRate *(i+1);
        wallPart.position= ccp(wallPart.contentSize.height * kScaleRate/2,  yPos );
        
        //R SIDE
        wallPartR  =[CCSprite spriteWithTexture:wallPart.texture];
        [wallPartR setScale:kScaleRate];
        wallPartR.flipX = YES;
        
        wallPartR.position = ccp(deathshipWall.contentSize.width- wallPartR.contentSize.width/2 * kScaleRate, yPos);
        
        
        [deathshipWall addChild:wallPart];
        [deathshipWall addChild:wallPartR];
        
    }
    
    
    CCSprite *wallFooter = [CCSprite spriteWithImageNamed:@"wall-footer.png"];
    [wallFooter  setScale:kScaleRate];
    [wallFooter.texture setAntialiased:NO];
    float wfYPos =  wallHeader.position.y + (wallLen+1) * kScaleRate * WALL_TILE_SIZE ;
    wallFooter.position= ccp(wallFooter.contentSize.width/2 *kScaleRate, wfYPos);
    
    // r footer
    CCSprite   *wallFooterR = [CCSprite spriteWithTexture:wallFooter.texture];
    [wallFooterR setScale:kScaleRate];
    wallFooterR.flipX = YES;
    wallFooterR.position= ccp(deathshipWall.contentSize.width - wallFooterR.contentSize.width/2* kScaleRate, wallFooter.position.y);
    
    [deathshipWall addChild:wallFooter];
    [deathshipWall addChild:wallFooterR];
    
    return deathshipWall;
}

-(void)makeWall
{
    // make wall 1
    _wall1 = [self getAnRandomWall];
    _wall2 = [self getAnRandomWall];
    //_wall2.position = ccp(0, _wall1.position.y +  wallHeight  );
    
}

@end
