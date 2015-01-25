//
//  DeskController.m
//  vChess
//
//  Created by Sergey Seitov on 1/26/10.ƒ
//  Copyright 2010 V-Channel. All rights reserved.
//

#import "DeskController.h"
#import "Desk.h"
#import "Figure.h"
#import "GameManager.h"
#include "vchess/turn.h"
#include "StorageManager.h"
#include "ChessGame.h"

NSString* const SaveGameNotification = @"SaveGameNotification";
NSString* const LoadGameNotification = @"LoadGameNotification";

@implementation DeskController

+ (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	NSLog(@"viewDidLoad");
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlayNext:) 
												 name:PlayNextNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlayPreviouse:) 
												 name:PlayPreviuoseNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSaveGame:) 
												 name:SaveGameNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadGame:) 
												 name:LoadGameNotification object:nil];
	
	desk = [[Desk alloc] initWithFrame:CGRectMake(0, 2, 320, 345)];
	[self.view addSubview:desk];
	
	controlButtons.hidden = YES;
	whiteName.text = @"";
	whiteName.numberOfLines = 2;
	blackName.text = @"";
	blackName.numberOfLines = 2;
		
	UIBarButtonItem *rotateButton = [[UIBarButtonItem alloc]
									 initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh 
									 target:self 
										 action:@selector(rotateDesk)];
	self.navigationItem.leftBarButtonItem = rotateButton;

	UIBarButtonItem *loadButton = [[UIBarButtonItem alloc]
									initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize 
									target:self 
									action:@selector(loadGame)];
	self.navigationItem.rightBarButtonItem = loadButton;
	
}

- (void)viewDidUnload {

	[[NSNotificationCenter defaultCenter] removeObserver:self];
	desk = nil;
    [super viewDidUnload];
}

- (void)handlePlayNext:(NSNotification*)note {
	
	if ([self nextTurn] == NO) {
		controlButtons.selectedSegmentIndex = PLAY_STOP;
	}
}

- (void)handlePlayPreviouse:(NSNotification*)note {
	
	if ([self previouseTurn] == NO) {
		controlButtons.selectedSegmentIndex = PLAY_STOP;
	}
}

- (void)handleLoadGame:(NSNotification*)note {
	
	ChessGame *chessGame = (ChessGame*)note.object;
	
	try {
		TurnsArray turns;
		if ([StorageManager parseTurns:chessGame.turns into:&turns]) {
			vchess::Game* game = new vchess::Game(turns,
												  [chessGame.white UTF8String],
												  [chessGame.black UTF8String]);
			printf("SUCCESS\n");
			[self.navigationController popToRootViewControllerAnimated:YES];
			[self startGame:game];
		} else {
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@"Error"
								  message:@"Error load game"
								  delegate:nil
								  cancelButtonTitle:@"Ok"
								  otherButtonTitles:nil];
			[alert show];
		}
	} catch (std::exception& e) {
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Error"
							  message:[NSString stringWithFormat:@"%s", e.what()]
							  delegate:nil
							  cancelButtonTitle:@"Ok"  
							  otherButtonTitles:nil];
		[alert show];
	}
}

- (void)handleSaveGame:(NSNotification*)note {

	NSLog(@"handleSaveGame");
}

- (bool)nextTurn {
	
	return [desk turnForward];
}

- (bool)previouseTurn {
	
	return [desk turnBack];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
}

- (IBAction)controlEvent:(id)sender {
	
	UISegmentedControl* control = (UISegmentedControl*)sender;
	NSInteger index = control.selectedSegmentIndex;
	switch (index) {
		case PLAY_START:
			desk.playMode = PLAY_BACKWARD;
			[self handlePlayPreviouse:NULL];
			break;
		case PLAY_PREV:
			desk.playMode = NOPLAY;
			[self previouseTurn];
			controlButtons.selectedSegmentIndex = PLAY_STOP;
			break;
		case PLAY_STOP:
			desk.playMode = NOPLAY;
			break;
		case PLAY_NEXT:
			desk.playMode = NOPLAY;
			[self nextTurn];
			controlButtons.selectedSegmentIndex = PLAY_STOP;
			break;
		case PLAY_FINISH:
			desk.playMode = PLAY_FORWARD;
			[self handlePlayNext:NULL];
			break;
		default:
			break;
	}
}

- (void)startGame:(vchess::Game*)game {
	
	NSLog(@"startGame");
	[desk setGame:game];
	controlButtons.hidden = NO;
	whiteName.text = [NSString stringWithUTF8String:game->white().data()];
	blackName.text = [NSString stringWithUTF8String:game->black().data()];
}

- (void)rotateDesk {
	
	[desk rotate];
}

- (void)loadGame {
    
	GameManager *gameManager = [[GameManager alloc] init];
	[self.navigationController pushViewController:gameManager animated:TRUE];
}

- (void)playGame {
}

@end
