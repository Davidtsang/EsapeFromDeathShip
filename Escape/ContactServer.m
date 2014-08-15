//
//  ContactServer.m
//  Escape
//
//  Created by user on 14-8-2.
//  Copyright (c) 2014年 david_tsang. All rights reserved.
//

#import "ContactServer.h"
#import "CommonFuns.h"
#import "AFNetworking.h"

@implementation ContactServer

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    
    if (self) {
    
    NSString *rqsBaseURI = ApiAddress;
//    #ifdef DEBUG
//    rqsBaseURI = @"http://127.0.0.1:5000/api/v1.0";
//    #endif
    
    self.rqsBaseURI  = rqsBaseURI;
    // done
    }
	return self;
}

//-(void)getFriendRankingWithLimit:(NSInteger)limit_
//{
//    // address GET /user/friend_ranking
//    //1 WHO IS His friend ?
//    //some's phone num  in his book;
//}
//-(void)submitAddressbook:(NSMutableArray *)book withUserID:(NSNumber *)userID
//{
//    //POST /api/v1.0/user/address_book
//    
//    NSInteger nowTime = [[NSDate date] timeIntervalSince1970 ];
//    
//    NSString *md5AuthString = [CommonFuns makeAuthToken:[NSString stringWithFormat:@"%d",nowTime ]];
//    
//    NSString *userIDString =[CommonFuns makeAuthToken:[userID stringValue] ] ;
//    
//    //NSString *postPath = [self.rqsBaseURI stringByAppendingPathComponent:@"/user?game_id=1"];
//    NSString *postPath = [NSString stringWithFormat:@"user/%@/address_book?game_id=1&auth_token=%@&user_id=%@&time_stamp=%ld",[userID stringValue], md5AuthString,userIDString,(long)nowTime ];
//    NSURL *baseURL = [[NSURL alloc] initWithString:_rqsBaseURI];
//    
//    NSDictionary *param =@{@"address_book": book };
//    //AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:baseURL];
//    //[client setParameterEncoding:AFJSONParameterEncoding];
//    NSMutableURLRequest *request = [client requestWithMethod:@"POST"
//                                                        path:postPath
//                                                  parameters:param];
//    
//    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        NSLog(@"%@", JSON);
//        //[JSON objectForKey:@"success"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:NoticeAddressBookSubmited object:self];
//        
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//        NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
//    }];
//    
//    [operation start];
//    
//}

-(void)getHiScore
{
    
    // GET /ranking/best
    NSInteger nowTime = [[NSDate date] timeIntervalSince1970 ];
    
    NSString *md5AuthString = [CommonFuns makeAuthToken:[NSString stringWithFormat:@"%d",nowTime ]];
    
    NSString *apiURI = [self.rqsBaseURI stringByAppendingPathComponent:@"/ranking/best?game_id=1"];
    apiURI = [NSString stringWithFormat:@"%@&auth_token=%@&time_stamp=%ld",apiURI, md5AuthString,(long)nowTime ];
    //NSURL *url = [[NSURL alloc] initWithString:apiURI];
    
    //NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:apiURI parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSDictionary *result =  (NSDictionary *)responseObject;
             
             //NSInteger success = [[result objectForKey:@"success"] integerValue];
             NSLog(@"%@", result);
             [[NSNotificationCenter defaultCenter] postNotificationName:NoticeGotHiScore object:self userInfo:[NSDictionary dictionaryWithObject:[result objectForKey:@"score"] forKey:@"score"]];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
         }];

}

-(void)createUser
{
 //POST /user/
 
    NSInteger nowTime = [[NSDate date] timeIntervalSince1970 ];
    
    NSString *md5AuthString = [CommonFuns makeAuthToken:[NSString stringWithFormat:@"%d",nowTime ]];
    
    //NSString *postPath = [self.rqsBaseURI stringByAppendingPathComponent:@"/user?game_id=1"];
    NSString *postPath = [NSString stringWithFormat:@"%@/user?game_id=1&auth_token=%@&time_stamp=%ld",self.rqsBaseURI,md5AuthString,(long)nowTime ];
    //NSURL *baseURL = [[NSURL alloc] initWithString:_rqsBaseURI];
    
    //AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:baseURL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:postPath parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSDictionary *result =  (NSDictionary *)responseObject;
             
             //NSInteger success = [[result objectForKey:@"success"] integerValue];
             NSLog(@"%@", result);
            [[NSNotificationCenter defaultCenter] postNotificationName:NoticeGotUserID
                                                                object:self userInfo:[NSDictionary dictionaryWithObject:[result objectForKey:@"user_id"] forKey:@"user_id"]];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
         }];
 
    
}
-(void)submitScore:(NSInteger)score withUserID:(NSNumber *)userID
{
    //PUT /api/v1.0/user/
    NSInteger nowTime = [[NSDate date] timeIntervalSince1970 ];
    
    NSString *md5AuthString = [CommonFuns makeAuthToken:[NSString stringWithFormat:@"%d",nowTime ]];
    
    NSString *userIDString =[CommonFuns makeAuthToken:[userID stringValue] ] ;
    
    //NSString *postPath = [self.rqsBaseURI stringByAppendingPathComponent:@"/user?game_id=1"];
    NSString *postPath = [NSString stringWithFormat:@"%@/user/%@?game_id=1&auth_token=%@&user_id=%@&time_stamp=%ld",
                          _rqsBaseURI,[userID stringValue], md5AuthString,userIDString,(long)nowTime ];
    //NSURL *baseURL = [[NSURL alloc] initWithString:_rqsBaseURI];
    
    NSDictionary *param =@{@"score": [NSNumber numberWithInteger:score]};
    //AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:baseURL];
    //[client setParameterEncoding:AFJSONParameterEncoding];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager PUT:postPath parameters:param
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              NSDictionary *result =  (NSDictionary *)responseObject;
              
              //NSInteger success = [[result objectForKey:@"success"] integerValue];
              NSLog(@"submit score result:%@", result);
              [[NSNotificationCenter defaultCenter] postNotificationName:NoticeScoreSubmited object:self];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
          }];
 
    
}
-(void)getMyBeat:(NSNumber *)userID score:(NSInteger)score_
{
    // : GET /user/<:id>/beatrank
 
    NSInteger nowTime = [[NSDate date] timeIntervalSince1970 ];
    
    NSString *md5AuthString = [CommonFuns makeAuthToken:[NSString stringWithFormat:@"%d",nowTime ]];
    
    NSString *userIDString =[CommonFuns makeAuthToken:[userID stringValue]];
    NSString *apiURI =[NSString stringWithFormat:@"%@/user/%@/beatrank?game_id=1&user_id=%@&score=%ld",
                       self.rqsBaseURI,userID, userIDString,(long)score_];
    apiURI = [NSString stringWithFormat:@"%@&auth_token=%@&time_stamp=%ld",apiURI, md5AuthString,(long)nowTime ];
    //NSURL *url = [[NSURL alloc] initWithString:apiURI];
    
    //NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:apiURI parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSDictionary *result =  (NSDictionary *)responseObject;
             
             //NSInteger success = [[result objectForKey:@"success"] integerValue];
             NSLog(@"%@", result);
            [[NSNotificationCenter defaultCenter] postNotificationName:NoticeGotBeatRank
                                                                object:self userInfo:result];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
         }];
    



}
@end
