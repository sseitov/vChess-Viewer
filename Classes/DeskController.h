//
//  DeskController.h
//  vChess
//
//  Created by Sergey Seitov on 1/26/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "vchess/game.h"

@class Desk;

enum CONTROL_BUTTON {
	PLAY_START,
	PLAY_PREV,
	PLAY_STOP,
	PLAY_NEXT,
	PLAY_FINISH
};

extern NSString* const SaveGameNotification;
extern NSString* const LoadGameNotification;

@interface DeskController : UIViewController

+ (NSString *)applicationDocumentsDirectory;
- (void)startGame:(vchess::Game*)game;
- (bool)nextTurn;
- (bool)previouseTurn;

@end
