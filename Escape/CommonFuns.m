//
//  CommonFuns.m
//  nsjenglish2
//
//  Created by user on 14-5-6.
//  Copyright (c) 2014年 david_tsang. All rights reserved.
//

#import "CommonFuns.h"
#import <CommonCrypto/CommonDigest.h>

@implementation CommonFuns
+ (NSString*) makeAuthToken:(NSString *)timeStamp
{
    NSString *preSharedKey =@"The same came for a witness, to bear witness of the Light, that all men through him might believe.";
    NSString *encodeString = [NSString stringWithFormat:@"%@:%@",timeStamp,[CommonFuns md5:preSharedKey] ];
    return [CommonFuns md5:encodeString];
    
}

+ (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

//随机数组
+ (NSMutableArray *)shuffleArray:(NSMutableArray *)_array
{
    NSUInteger count = [_array count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSUInteger nElements = count - i;
        NSUInteger n = (random() % nElements) + i;
        [_array exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
	return _array;
}


+(void)delCookie:(NSURL *) url
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL: url];
    for (NSHTTPCookie *cookie in cookies)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

+(NSString *)getWordResPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
 
    NSString *wordResPath = [cachePath stringByAppendingPathComponent:@"words_res"];
    return wordResPath;
    
}

 
+(UIImage *)decryptImage:(NSString *)imagePath withName:(NSString *)name
{
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
    [self transformImage:imageData withName:name];
    UIImage *decodeImage = [UIImage imageWithData:imageData ];
    return decodeImage;
}

+(void)transformImage:(NSData *)input withName:(NSString *)imageName
{
    NSString *encKey =[NSString stringWithFormat:@"ZTvKEWVs687NbPYmruDG2SEWui0xgSMj-|-%@",imageName];
    [self transformImage:input withKey:encKey];
}
+ (void)transformImage:(NSData *)input  withKey:(NSString *)aKey
{
	
	//NSString *keys=@"pBytesInput";
	NSString* key =aKey;
	//NSLog(@"key is:%@",key);
	
	unsigned char* pBytesInput = (unsigned char*)[input bytes];
	unsigned char* pBytesKey   = (unsigned char*)[[key dataUsingEncoding:NSUTF8StringEncoding] bytes];
	NSUInteger vlen = [input length];
	NSUInteger klen = [key length];
	
	NSUInteger k = vlen % klen;
	unsigned char c;
	
	for (unsigned int v = 0; v < vlen; v++) {
        
		c = pBytesInput[v] ^ pBytesKey[k];
		pBytesInput[v] = c;
		
		k = (++k < klen ? k : 0);
	}
}//end fun


@end
