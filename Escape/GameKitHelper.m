//
//  GameKitHelper.m
//
//  Created by Steffen Itterheim on 05.10.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "GameKitHelper.h"
#import "AppDelegate.h"

static NSString* kCachedAchievementsFile = @"CachedAchievements.archive";

@interface GameKitHelper (Private)
-(void) registerForLocalPlayerAuthChange;
-(void) setLastError:(NSError*)error;
-(void) initCachedAchievements;
-(void) cacheAchievement:(GKAchievement*)achievement;
-(void) uncacheAchievement:(GKAchievement*)achievement;
-(void) loadAchievements;
-(void) initMatchInvitationHandler;
-(UIViewController*) getRootViewController;
@end

@implementation GameKitHelper

static GameKitHelper *instanceOfGameKitHelper;

#pragma mark Singleton stuff
//+(id) alloc
//{
//	@synchronized(self)	
//	{
//		NSAssert(instanceOfGameKitHelper == nil, @"Attempted to allocate a second instance of the singleton: GameKitHelper");
//		instanceOfGameKitHelper = [super alloc] ;
//		return instanceOfGameKitHelper;
//	}
//	
//	// to avoid compiler warning
//	return nil;
//}

+ (GameKitHelper*)sharedInstance {
    static dispatch_once_t once;
    static GameKitHelper * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init ];
    });
    return sharedInstance;
}


//+(GameKitHelper*) sharedGameKitHelper
//{
//	@synchronized(self)
//	{
//		if (instanceOfGameKitHelper == nil)
//		{
//			[[GameKitHelper alloc] init];
//		}
//		
//		return instanceOfGameKitHelper;
//	}
//	
//	// to avoid compiler warning
//	return nil;
//}

#pragma mark Init & Dealloc

@synthesize delegate;
@synthesize isGameCenterAvailable;
@synthesize lastError;
@synthesize achievements;
@synthesize currentMatch;
@synthesize matchStarted;

-(id) init
{
	if ((self = [super init]))
	{
		// Test for Game Center availability
		Class gameKitLocalPlayerClass = NSClassFromString(@"GKLocalPlayer");
		bool isLocalPlayerAvailable = (gameKitLocalPlayerClass != nil);
		
//		// Test if device is running iOS 4.1 or higher
		NSString* reqSysVer = @"4.1";
		NSString* currSysVer = [[UIDevice currentDevice] systemVersion];
		bool isOSVer41 = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
		
		isGameCenterAvailable = (isLocalPlayerAvailable && isOSVer41);
		NSLog(@"GameCenter available = %@", isGameCenterAvailable ? @"YES" : @"NO");

		[self registerForLocalPlayerAuthChange];

		//[self initCachedAchievements];
        //user country
        NSLocale *locale = [NSLocale currentLocale];
        NSString *country = [locale objectForKey:NSLocaleCountryCode];
        NSLog(@"user country:%@",country);
        self.userCountryCode  = country;
        
	}
	
	return self;
}

-(void) dealloc
{
	CCLOG(@"dealloc %@", self);


	[[NSNotificationCenter defaultCenter] removeObserver:self];


}

#pragma mark setLastError

-(void) setLastError:(NSError*)error
{
	lastError = [error copy];
	
	if (lastError)
	{
		NSLog(@"GameKitHelper ERROR: %@", [[lastError userInfo] description]);
	}
}

#pragma mark Player Authentication

-(void) authenticateLocalPlayer
{
	if (isGameCenterAvailable == NO)
		return;

	GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
	if (localPlayer.authenticated == NO)
	{
		// Authenticate player, using a block object. See Apple's Block Programming guide for more info about Block Objects:
        __weak GKLocalPlayer *player = localPlayer;
		[localPlayer setAuthenticateHandler:(^(UIViewController* viewcontroller, NSError *error)
		{
			[self setLastError:error];
			
            if (player.authenticated) {
                [self initMatchInvitationHandler];
                //[self reportCachedAchievements];
				//[self loadAchievements];
            }else if (viewcontroller) {
                [self presentViewController:viewcontroller];
            }
		})];
		
 
	}
}

-(void) onLocalPlayerAuthenticationChanged
{
	[delegate onLocalPlayerAuthenticationChanged];
}

-(void) registerForLocalPlayerAuthChange
{
	if (isGameCenterAvailable == NO)
		return;

	// Register to receive notifications when local player authentication status changes
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(onLocalPlayerAuthenticationChanged)
			   name:GKPlayerAuthenticationDidChangeNotificationName
			 object:nil];
}

#pragma mark Friends & Player Info

-(void) getLocalPlayerFriends
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
	if (localPlayer.authenticated)
	{
		// First, get the list of friends (player IDs)
		[localPlayer loadFriendsWithCompletionHandler:^(NSArray* friends, NSError* error)
		{
			[self setLastError:error];
			[delegate onFriendListReceived:friends];
		}];
	}
}

-(void) getPlayerInfo:(NSArray*)playerList
{
	if (isGameCenterAvailable == NO)
		return;

	// Get detailed information about a list of players
	if ([playerList count] > 0)
	{
		[GKPlayer loadPlayersForIdentifiers:playerList withCompletionHandler:^(NSArray* players, NSError* error)
		{
			[self setLastError:error];
			[delegate onPlayerInfoReceived:players];
		}];
	}
}

#pragma mark Scores & Leaderboard

-(void) submitScore:(int64_t)score category:(NSString*)category
{
	if (isGameCenterAvailable == NO)
		return;

	GKScore* gkScore = [[GKScore alloc] initWithCategory:category];
	gkScore.value = score;

	[gkScore reportScoreWithCompletionHandler:^(NSError* error)
	{
		[self setLastError:error];
		
		bool success = (error == nil);
		[delegate onScoresSubmitted:success];
	}];
}

-(void) retrieveScoresForPlayers:(NSArray*)players
						category:(NSString*)category 
						   range:(NSRange)range
					 playerScope:(GKLeaderboardPlayerScope)playerScope 
					   timeScope:(GKLeaderboardTimeScope)timeScope 
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKLeaderboard* leaderboard = nil;
	if ([players count] > 0)
	{
		leaderboard = [[GKLeaderboard alloc] initWithPlayerIDs:players];
	}
	else
	{
		leaderboard = [[GKLeaderboard alloc] init];
		leaderboard.playerScope = playerScope;
	}
	
	if (leaderboard != nil)
	{
		leaderboard.timeScope = timeScope;
		leaderboard.category = category;
		leaderboard.range = range;
		[leaderboard loadScoresWithCompletionHandler:^(NSArray* scores, NSError* error)
		{
			[self setLastError:error];
			[delegate onScoresReceived:scores];
		}];
	}
}

-(void) retrieveTop100AllTimeGlobalScores
{
	[self retrieveScoresForPlayers:nil
						  category:kMainLeaderBoardID
							 range:NSMakeRange(1, 100)
					   playerScope:GKLeaderboardPlayerScopeGlobal 
						 timeScope:GKLeaderboardTimeScopeAllTime];
}

#pragma mark Achievements

-(void) loadAchievements
{
	if (isGameCenterAvailable == NO)
		return;

	[GKAchievement loadAchievementsWithCompletionHandler:^(NSArray* loadedAchievements, NSError* error)
	{
		[self setLastError:error];
		 
		if (achievements == nil)
		{
			achievements = [[NSMutableDictionary alloc] init];
		}
		else
		{
			[achievements removeAllObjects];
		}
		
		for (GKAchievement* achievement in loadedAchievements)
		{
			[achievements setObject:achievement forKey:achievement.identifier];
		}
		 
		[delegate onAchievementsLoaded:achievements];
	}];
}

-(GKAchievement*) getAchievementByID:(NSString*)identifier
{
	if (isGameCenterAvailable == NO)
		return nil;
		
	// Try to get an existing achievement with this identifier
	GKAchievement* achievement = [achievements objectForKey:identifier];
	
	if (achievement == nil)
	{
		// Create a new achievement object
		achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
		[achievements setObject:achievement forKey:achievement.identifier];
	}
	
	return achievement;
}

-(void) reportAchievementWithID:(NSString*)identifier percentComplete:(float)percent
{
	if (isGameCenterAvailable == NO)
		return;

	GKAchievement* achievement = [self getAchievementByID:identifier];
	if (achievement != nil && achievement.percentComplete < percent)
	{
		achievement.percentComplete = percent;
		[achievement reportAchievementWithCompletionHandler:^(NSError* error)
		{
			[self setLastError:error];
			
			bool success = (error == nil);
			if (success == NO)
			{
				// Keep achievement to try to submit it later
				[self cacheAchievement:achievement];
			}
			
			[delegate onAchievementReported:achievement];
		}];
	}
}

-(void) resetAchievements
{
	if (isGameCenterAvailable == NO)
		return;
	
	[achievements removeAllObjects];
	[cachedAchievements removeAllObjects];
	
	[GKAchievement resetAchievementsWithCompletionHandler:^(NSError* error)
	{
		[self setLastError:error];
		bool success = (error == nil);
		[delegate onResetAchievements:success];
	}];
}

-(void) reportCachedAchievements
{
	if (isGameCenterAvailable == NO)
		return;
	
	if ([cachedAchievements count] == 0)
		return;

	for (GKAchievement* achievement in [cachedAchievements allValues])
	{
		[achievement reportAchievementWithCompletionHandler:^(NSError* error)
		{
			bool success = (error == nil);
			if (success == YES)
			{
				[self uncacheAchievement:achievement];
			}
		}];
	}
}

-(void) initCachedAchievements
{
	NSString* file = [NSHomeDirectory() stringByAppendingPathComponent:kCachedAchievementsFile];
	id object = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
	
	if ([object isKindOfClass:[NSMutableDictionary class]])
	{
		NSMutableDictionary* loadedAchievements = (NSMutableDictionary*)object;
		cachedAchievements = [[NSMutableDictionary alloc] initWithDictionary:loadedAchievements];
	}
	else
	{
		cachedAchievements = [[NSMutableDictionary alloc] init];
	}
}

-(void) saveCachedAchievements
{
	NSString* file = [NSHomeDirectory() stringByAppendingPathComponent:kCachedAchievementsFile];
	[NSKeyedArchiver archiveRootObject:cachedAchievements toFile:file];
}

-(void) cacheAchievement:(GKAchievement*)achievement
{
	[cachedAchievements setObject:achievement forKey:achievement.identifier];
	
	// Save to disk immediately, to keep achievements around even if the game crashes.
	[self saveCachedAchievements];
}

-(void) uncacheAchievement:(GKAchievement*)achievement
{
	[cachedAchievements removeObjectForKey:achievement.identifier];
	
	// Save to disk immediately, to keep the removed cached achievement from being loaded again
	[self saveCachedAchievements];
}

#pragma mark Matchmaking

-(void) disconnectCurrentMatch
{
	[currentMatch disconnect];
	currentMatch.delegate = nil;

	currentMatch = nil;
}

-(void) setCurrentMatch:(GKMatch*)match
{
	if ([currentMatch isEqual:match] == NO)
	{
		[self disconnectCurrentMatch];
		currentMatch = match;
		currentMatch.delegate = self;
	}
}

-(void) initMatchInvitationHandler
{
	if (isGameCenterAvailable == NO)
		return;

	[GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite* acceptedInvite, NSArray* playersToInvite)
	{
		[self disconnectCurrentMatch];
		
		if (acceptedInvite)
		{
			[self showMatchmakerWithInvite:acceptedInvite];
		}
		else if (playersToInvite)
		{
			GKMatchRequest* request = [[GKMatchRequest alloc] init] ;
			request.minPlayers = 2;
			request.maxPlayers = 4;
			request.playersToInvite = playersToInvite;

			[self showMatchmakerWithRequest:request];
		}
	};
}

-(void) findMatchForRequest:(GKMatchRequest*)request
{
	if (isGameCenterAvailable == NO)
		return;
	
	[[GKMatchmaker sharedMatchmaker] findMatchForRequest:request withCompletionHandler:^(GKMatch* match, NSError* error)
	{
		[self setLastError:error];
		
		if (match != nil)
		{
			[self setCurrentMatch:match];
			[delegate onMatchFound:match];
		}
	}];
}

-(void) addPlayersToMatch:(GKMatchRequest*)request
{
	if (isGameCenterAvailable == NO)
		return;

	if (currentMatch == nil)
		return;
	
	[[GKMatchmaker sharedMatchmaker] addPlayersToMatch:currentMatch matchRequest:request completionHandler:^(NSError* error)
	{
		[self setLastError:error];
		
		bool success = (error == nil);
		[delegate onPlayersAddedToMatch:success];
	}];
}

-(void) cancelMatchmakingRequest
{
	if (isGameCenterAvailable == NO)
		return;

	[[GKMatchmaker sharedMatchmaker] cancel];
}

-(void) queryMatchmakingActivity
{
	if (isGameCenterAvailable == NO)
		return;

	[[GKMatchmaker sharedMatchmaker] queryActivityWithCompletionHandler:^(NSInteger activity, NSError* error)
	{
		[self setLastError:error];
		
		if (error == nil)
		{
			[delegate onReceivedMatchmakingActivity:activity];
		}
	}];
}

#pragma mark Match Connection

-(void) match:(GKMatch*)match player:(NSString*)playerID didChangeState:(GKPlayerConnectionState)state
{
	switch (state)
	{
		case GKPlayerStateConnected:
			[delegate onPlayerConnected:playerID];
			break;
		case GKPlayerStateDisconnected:
			[delegate onPlayerDisconnected:playerID];
			break;
	}
	
	if (matchStarted == NO && match.expectedPlayerCount == 0)
	{
		matchStarted = YES;
		[delegate onStartMatch];
	}
}

-(void) sendDataToAllPlayers:(void*)data length:(NSUInteger)length
{
	if (isGameCenterAvailable == NO)
		return;
	
	NSError* error = nil;
	NSData* packet = [NSData dataWithBytes:data length:length];
	[currentMatch sendDataToAllPlayers:packet withDataMode:GKMatchSendDataUnreliable error:&error];
	[self setLastError:error];
}

-(void) match:(GKMatch*)match didReceiveData:(NSData*)data fromPlayer:(NSString*)playerID
{
	[delegate onReceivedData:data fromPlayer:playerID];
}

#pragma mark Views (Leaderboard, Achievements)

// Helper methods

-(UIViewController*) getRootViewController
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	return app.navController ;
}

-(void) presentViewController:(UIViewController*)vc
{
	UIViewController* rootVC = [self getRootViewController];
	[rootVC presentViewController:vc animated:YES completion:nil];
}

-(void) dismissModalViewController
{
	UIViewController* rootVC = [self getRootViewController];
	[rootVC dismissViewControllerAnimated:YES completion:nil];
}

// Leaderboards

-(void) showLeaderboard
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKLeaderboardViewController* leaderboardVC = [[GKLeaderboardViewController alloc] init];
	if (leaderboardVC != nil)
	{
		leaderboardVC.leaderboardDelegate = self;
		[self presentViewController:leaderboardVC];
	}
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController*)viewController
{
	[self dismissModalViewController];
	[delegate onLeaderboardViewDismissed];
}

// Achievements

-(void) showAchievements
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKAchievementViewController* achievementsVC = [[GKAchievementViewController alloc] init];
	if (achievementsVC != nil)
	{
		achievementsVC.achievementDelegate = self;
		[self presentViewController:achievementsVC];
	}
}

-(void) achievementViewControllerDidFinish:(GKAchievementViewController*)viewController
{
	[self dismissModalViewController];
	[delegate onAchievementsViewDismissed];
}

// Matchmaking

-(void) showMatchmakerWithInvite:(GKInvite*)invite
{
	GKMatchmakerViewController* inviteVC = [[GKMatchmakerViewController alloc] initWithInvite:invite] ;
	if (inviteVC != nil)
	{
		inviteVC.matchmakerDelegate = self;
		[self presentViewController:inviteVC];
	}
}

-(void) showMatchmakerWithRequest:(GKMatchRequest*)request
{
	GKMatchmakerViewController* hostVC = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
	if (hostVC != nil)
	{
		hostVC.matchmakerDelegate = self;
		[self presentViewController:hostVC];
	}
}

-(void) matchmakerViewControllerWasCancelled:(GKMatchmakerViewController*)viewController
{
	[self dismissModalViewController];
	[delegate onMatchmakingViewDismissed];
}

-(void) matchmakerViewController:(GKMatchmakerViewController*)viewController didFailWithError:(NSError*)error
{
	[self dismissModalViewController];
	[self setLastError:error];
	[delegate onMatchmakingViewError];
}

-(void) matchmakerViewController:(GKMatchmakerViewController*)viewController didFindMatch:(GKMatch*)match
{
	[self dismissModalViewController];
	[self setCurrentMatch:match];
	[delegate onMatchFound:match];
}

@end
