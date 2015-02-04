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
#import "HeaderView.h"

#include "vchess/turn.h"
#include "StorageManager.h"
#include "ChessGame.h"

NSString* const SaveGameNotification = @"SaveGameNotification";
NSString* const LoadGameNotification = @"LoadGameNotification";

@interface DeskController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *controlButtons;
@property (weak, nonatomic) IBOutlet Desk *desk;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerVerticalSpace;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rotateBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fileBtn;
@property (weak, nonatomic) IBOutlet HeaderView *headerView;

- (IBAction)controlEvent:(id)sender;
- (IBAction)rotateDesk;
- (IBAction)loadGame;

@end

@implementation DeskController

+ (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)viewDidLoad {
	
    [super viewDidLoad];

	self.title = @"vChess Viewer";
	if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_7_0) {
		_headerVerticalSpace.constant = 44.0;
	} else {
		_rotateBtn.tintColor = [UIColor whiteColor];
		_fileBtn.tintColor = [UIColor whiteColor];
		_controlButtons.tintColor = [UIColor whiteColor];
	}
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"marble.png"]];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlayNext:) 
												 name:PlayNextNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlayPreviouse:) 
												 name:PlayPreviuoseNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSaveGame:) 
												 name:SaveGameNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadGame:) 
												 name:LoadGameNotification object:nil];
	
	_controlButtons.enabled = NO;
//	_headerView.hidden = YES;
}

- (void)handlePlayNext:(NSNotification*)note {
	
	if ([self nextTurn] == NO) {
		_controlButtons.selectedSegmentIndex = PLAY_STOP;
	}
}

- (void)handlePlayPreviouse:(NSNotification*)note {
	
	if ([self previouseTurn] == NO) {
		_controlButtons.selectedSegmentIndex = PLAY_STOP;
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
	
	return [_desk turnForward];
}

- (bool)previouseTurn {
	
	return [_desk turnBack];
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
			_desk.playMode = PLAY_BACKWARD;
			[self handlePlayPreviouse:NULL];
			break;
		case PLAY_PREV:
			_desk.playMode = NOPLAY;
			[self previouseTurn];
			_controlButtons.selectedSegmentIndex = PLAY_STOP;
			break;
		case PLAY_STOP:
			_desk.playMode = NOPLAY;
			break;
		case PLAY_NEXT:
			_desk.playMode = NOPLAY;
			[self nextTurn];
			_controlButtons.selectedSegmentIndex = PLAY_STOP;
			break;
		case PLAY_FINISH:
			_desk.playMode = PLAY_FORWARD;
			[self handlePlayNext:NULL];
			break;
		default:
			break;
	}
}

- (void)startGame:(vchess::Game*)game {
	
	NSLog(@"startGame");
	[_desk setGame:game];
	_controlButtons.enabled = YES;
	_headerView.hidden = NO;
	_headerView.whiteName = [NSString stringWithUTF8String:game->white().data()];
	_headerView.blackName = [NSString stringWithUTF8String:game->black().data()];
	[_headerView setNeedsDisplay];
}

- (IBAction)rotateDesk
{	
	[_desk rotate];
}

- (IBAction)loadGame
{
	[self performSegueWithIdentifier:@"openArchive" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

@end
