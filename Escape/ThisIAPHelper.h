//
//  Nsj2IAPHelper.h
//  nsjenglish2
//
//  Created by user on 14-6-19.
//  Copyright (c) 2014年 david_tsang. All rights reserved.
//

#import "IAPHelper.h"

@interface ThisIAPHelper : IAPHelper

+ (ThisIAPHelper *)sharedInstance;
-(void)thanks;
-(void)buyRemoveAds;

@end
