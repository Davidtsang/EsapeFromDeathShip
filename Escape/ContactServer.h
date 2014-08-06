//
//  ContactServer.h
//  Escape
//
//  Created by user on 14-8-2.
//  Copyright (c) 2014年 david_tsang. All rights reserved.
//

#import <Foundation/Foundation.h>


static NSString *ApiAddress =@"https://iphonebestapp.com/cherryboard/api/v1.0";
static NSString *NoticeGotHiScore = @"got_hi_score";
static NSString *NoticeGotUserID = @"got_user_id";
static NSString *NoticeGotBeatRank = @"got_beatrank";
static NSString * NoticeScoreSubmited = @"score_submited";
@interface ContactServer : NSObject

@property(nonatomic,strong)NSString *rqsBaseURI;

//get hi-score;
-(void)getHiScore;


// GET api/v1/ranking/best
-(void)createUser;
// POST api/v1/user

-(void)getMyBeat:(NSNumber *)userID;
// GET /user/<id>/beatrank

-(void)sumbitScore:(NSInteger)score withUserID:(NSNumber *)userID;
// PUT /api/v1.0/user/

@end
