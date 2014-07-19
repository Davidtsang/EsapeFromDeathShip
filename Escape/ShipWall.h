//
//  ShipWall.h
//  Escape
//
//  Created by user on 14-7-17.
//  Copyright (c) 2014年 david_tsang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCNode;



@interface ShipWall : NSObject
{
    //CCNode * _wall1;
    //CCNode *_wall2;
}

@property(nonatomic,weak)CCNode* wall1;
@property(nonatomic,weak)CCNode* wall2;

-(CCNode *)getAnRandomWall;
-(void)makeWall;

@end
