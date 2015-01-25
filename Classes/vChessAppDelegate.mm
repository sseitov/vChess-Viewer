//
//  vChessAppDelegate.m
//  vChess
//
//  Created by Sergey Seitov on 1/26/10.
//  Copyright V-Channel 2010. All rights reserved.
//

#import "vChessAppDelegate.h"
#import "DeskController.h"
#import "StorageManager.h"

@implementation vChessAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// StoreManager initialization.
	[[StorageManager sharedStorageManager] managedObjectContext];
	[[StorageManager sharedStorageManager] initUserPackages];
	
	return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

	[[NSNotificationCenter defaultCenter] postNotificationName:SaveGameNotification object:self];
}

- (void)applicationWillTerminate:(UIApplication *)application {

}

@end
