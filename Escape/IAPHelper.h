//
//  IAPHelper.h
//  nsjenglish2
//
//  Created by user on 14-6-19.
//  Copyright (c) 2014年 david_tsang. All rights reserved.
//
#import <StoreKit/StoreKit.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;
-(void)readReceiptData;
- (void)provideContentForProductIdentifier:(NSString *)productIdentifier;

@end
