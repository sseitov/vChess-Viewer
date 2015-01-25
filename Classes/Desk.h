//
//  Desk.h
//  vChess
//
//  Created by Sergey Seitov on 1/26/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "vchess/game.h"

@class DeskRule;
@class LostFigures;
@class Figure;

enum PLAY_MODE {
	NOPLAY,
	PLAY_FORWARD,
	PLAY_BACKWARD
};

extern NSString* const PlayNextNotification;
extern NSString* const PlayPreviuoseNotification;

@interface Desk : UIView {
	
	UIImageView	*deskImage;
	DeskRule	*horzRule;
	DeskRule	*vertRule;
	
	LostFigures		*whiteLost;
	LostFigures		*blackLost;
	NSMutableArray	*figures;
	vchess::Game	*currentGame;
	
	Figure		*dragFigure;
	CGPoint		dragStart;
	int			playMode;
	BOOL		isRotate;
}

@property (readwrite) int	playMode;

- (CGPoint)cellCenterX:(int)x Y:(int)y;
- (CGPoint)lostCenterForColor:(int)color;

- (void)rotate;
- (void)setGame:(vchess::Game*)game;
- (BOOL)turnForward;
- (BOOL)turnBack;
- (void)moveFigure:(Figure*)f to:(NSNumber*)position;
- (void)moveFigures:(NSArray*)theFigures toPos:(NSArray*)positions;
- (void)animateFigure:(Figure*)figure to:(CGPoint)pt;
- (Figure*)figureAt:(NSNumber*)position;
- (Figure*)figureFor:(unsigned char)model fromArray:(NSMutableArray*)array;
- (void)aliveFigure:(Figure*)f;

@end
