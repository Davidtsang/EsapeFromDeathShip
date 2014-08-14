//
//  Nsj2IAPHelper.m
//  nsjenglish2
//
//  Created by user on 14-6-19.
//  Copyright (c) 2014年 david_tsang. All rights reserved.
//

#import "ThisIAPHelper.h"
#import "AppDelegate.h"

@implementation ThisIAPHelper

+ (ThisIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static ThisIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.kejike.escapeds.remove_ads",nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

-(void)buyRemoveAds
{
    //IAP
    [self requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        
        if (success) {
             //START BUYING!
            SKProduct *product = [products objectAtIndex:0];
            [self  buyProduct:product ];
            NSLog(@"start buying...");
        }
        
    }];
}

-(void)provideContentForProductIdentifier:(NSString *)productIdentifier
{
    [super provideContentForProductIdentifier:productIdentifier];
    NSLog(@"need provide: %@",productIdentifier);
    //make is provesion,
    //[[LearningManager sharedManager] markIsProVersion];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate makeIsProVersion];
    //[[LearningManager sharedManager] setIsProVersion:YES];
    //check recipie.
    
    [self thanks];
}

-(void)thanks
{
    UIAlertView *alert =[[ UIAlertView alloc] initWithTitle:@"Thank you!" message:@"Ads will be removed immediately." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
    
}


@end
