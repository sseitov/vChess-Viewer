//
//  ChessComLoader.h
//  vChess
//
//  Created by Sergey Seitov on 12.03.13.
//  Copyright (c) 2013 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@protocol ChessComLoaderDelegate <NSObject>

- (void)loaderDidFinish:(UIViewController*)loader;

@end

enum {
	ImportIsWorking,
	ImportIsDone
};

@interface ChessComLoader : UIViewController <UIWebViewDelegate, MBProgressHUDDelegate> {
	
	MBProgressHUD *HUD;
	BOOL doImport;
	NSConditionLock *importStopped;
}

@property (strong, nonatomic) UIWebView *webView;
@property (weak, nonatomic) id<ChessComLoaderDelegate> delegate;

@end
