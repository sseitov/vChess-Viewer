//
//  ChessComLoader.m
//  vChess
//
//  Created by Sergey Seitov on 12.03.13.
//  Copyright (c) 2013 V-Channel. All rights reserved.
//

#import "ChessComLoader.h"
#import "PGNImporter.h"
#import "StorageManager.h"

static NSString *serverURL = @"http://www.chess.com/downloads/database+of+games";

@interface DownloadAlert : UIAlertView

@property (strong, nonatomic) NSURL *url;

@end

@implementation DownloadAlert

@synthesize url;

@end

@implementation ChessComLoader

@synthesize webView, delegate = _delegate;

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Chess.com";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.hidesBackButton = YES;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(done)];
	CGRect r = self.view.bounds;
	r.size.width *= 2;
	webView = [[UIWebView alloc] initWithFrame:r];
	webView.delegate = self;
	webView.backgroundColor = [UIColor clearColor];
//	webView.scalesPageToFit = NO;
//	webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:webView];
	
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:serverURL]]];
}

- (void)done {

	if (doImport) {
		doImport = NO;
		[importStopped lockWhenCondition:ImportIsDone];
		[importStopped unlock];
	}
	[self.delegate loaderDidFinish:self];
}

- (void)back {

	[webView goBack];
}

#pragma mark - UIWebView delegate

- (void)webViewDidStartLoad:(UIWebView *)theWebView {
	
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
	
	if ([theWebView canGoBack]) {
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
																				 style:UIBarButtonItemStyleDone
																				target:self
																				action:@selector(back)];
	} else {
		self.navigationItem.leftBarButtonItem = nil;
	}
}

- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	
	if ([request.URL.lastPathComponent.pathExtension isEqual:@"zip"]) {
		NSString *package = [request.URL.lastPathComponent stringByDeletingPathExtension];
		DownloadAlert* dialog = [[DownloadAlert alloc] initWithTitle:@"Download Archive" message:@"Package name:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
		dialog.url = request.URL;
		[dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
		[[dialog textFieldAtIndex:0] setText:package];
		[dialog show];
		return NO;
	}
	return YES;
}

#pragma mark - UIAlertView delegate

-(void)alertView:(DownloadAlert *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
	if (buttonIndex == 1) {
		HUD = [[MBProgressHUD alloc] initWithView:self.view];
		[self.view addSubview:HUD];
		
		HUD.delegate = self;
		HUD.labelText = @"Downloading...";
		HUD.minSize = CGSizeMake(135.f, 135.f);
		[HUD showWhileExecuting:@selector(importPGN:) onTarget:self withObject:alertView animated:YES];
	}
}

#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}

#pragma mark - Import thread

- (void)importFinish {
	
	[self.delegate loaderDidFinish:self];
}

- (void)importError:(NSString*)error {
	
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Import error"
													message:error
												   delegate:nil
										  cancelButtonTitle:@"Ok"
										   otherButtonTitles:nil];
	[alert show];
}

- (void)importPGN:(DownloadAlert*)alert {
	
	doImport = YES;
	importStopped = [[NSConditionLock alloc] initWithCondition:ImportIsWorking];

	PGNImporter *importer = [PGNImporter sharedPGNImporter];
	
	NSMutableArray *catalog = [NSMutableArray array];
	int countGames = [importer fillImportCatalog:catalog fromURL:alert.url];
	if (countGames < 1) {
		[self performSelectorOnMainThread:@selector(importError:) withObject:@"DOWNLOAD ERROR" waitUntilDone:NO];
	}
	
	HUD.mode = MBProgressHUDModeDeterminate;
	HUD.userInteractionEnabled = NO;
	HUD.labelText = @"Import...";
	HUD.progress = 0.0;
	float delta = 1.0 / (float)countGames;
	
	NSString *package = [alert textFieldAtIndex:0].text;
	[[StorageManager sharedStorageManager] removePackage:package];
	
	int success = 0;
	for (NSString *file in catalog) {
		NSError *error = nil;
		NSString *gameText = [NSString stringWithContentsOfFile:file encoding:NSASCIIStringEncoding error:&error];
		if (error) {
			NSLog(@"ERROR: %@", [error localizedDescription]);
			continue;
		}
		NSArray *elements = [gameText componentsSeparatedByString:@"\r\n\r\n"];
		if (!elements || elements.count < 2) {
			elements = [gameText componentsSeparatedByString:@"\n\n"];
		}
		if (!elements || elements.count < 2) {
			continue;
		}

		NSEnumerator *enumerator = [elements objectEnumerator];
		NSString *header;
		while (header = [enumerator nextObject]) {
			NSString *pgn = [enumerator nextObject];
			if (!pgn) {
				break;
			}
			@autoreleasepool {
				if ([importer appendGame:package header:header pgn:pgn]) {
					success++;
				};
			}
			HUD.progress += delta;
			if (!doImport) {
				break;
			}
		}
		if (!doImport) {
			break;
		}
	}
	
	if (doImport) {
		if (success <= 0) {
			[self performSelectorOnMainThread:@selector(importError:) withObject:@"IMPORT ERROR" waitUntilDone:NO];
		} else {
			[self performSelectorOnMainThread:@selector(importFinish) withObject:nil waitUntilDone:NO];
		}
		doImport = NO;
	}
	[importStopped lock];
	[importStopped unlockWithCondition:ImportIsDone];
}

@end
