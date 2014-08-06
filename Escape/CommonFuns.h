//
//  CommonFuns.h
//  nsjenglish2
//
//  Created by user on 14-5-6.
//  Copyright (c) 2014年 david_tsang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonFuns : NSObject

+(void)delCookie:(NSURL *) url ;
 
+ (NSMutableArray *)shuffleArray:(NSMutableArray *)_array;
+ (NSString *) md5:(NSString *) input;
+ (NSString*) makeAuthToken:(NSString *)timeStamp;
//de image
+(UIImage *)decryptImage:(NSString *)imagePath withName:(NSString *)name;

@end
