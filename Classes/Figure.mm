//
//  Figure.m
//  vChess
//
//  Created by Sergey Seitov on 1/29/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import "Figure.h"
#include "vchess/turn.h"

using namespace vchess;

@implementation Figure

@synthesize model;
@synthesize position;
@synthesize liveState;

+ (UIImage*)smallImageByType:(unsigned char)figType forColor:(unsigned char)figColor {
	
	switch (figType) {
		case KING:
			if (figColor == CBLACK) {
				return [UIImage imageNamed:@"SmallBlackK.png"];
			} else {
				return [UIImage imageNamed:@"SmallWhiteK.png"];
			}
		case QUEEN:
			if (figColor == CBLACK) {
				return [UIImage imageNamed:@"SmallBlackQ.png"];
			} else {
				return [UIImage imageNamed:@"SmallWhiteQ.png"];
			}
		case ROCK:
			if (figColor == CBLACK) {
				return [UIImage imageNamed:@"SmallBlackR.png"];
			} else {
				return [UIImage imageNamed:@"SmallWhiteR.png"];
			}
		case BISHOP:
			if (figColor == CBLACK) {
				return [UIImage imageNamed:@"SmallBlackB.png"];
			} else {
				return [UIImage imageNamed:@"SmallWhiteB.png"];
			}
		case KNIGHT:
			if (figColor == CBLACK) {
				return [UIImage imageNamed:@"SmallBlackN.png"];
			} else {
				return [UIImage imageNamed:@"SmallWhiteN.png"];
			}
		case PAWN:
			if (figColor == CBLACK) {
				return [UIImage imageNamed:@"SmallBlackP.png"];
			} else {
				return [UIImage imageNamed:@"SmallWhiteP.png"];
			}
		default:
			return nil;
	}
}

+ (UIImage*)imageByType:(int)figType forColor:(unsigned char)figColor {
	
	switch (figType) {
		case KING:
			if (figColor == CBLACK) {
				return [UIImage imageNamed:@"BlackK.png"];
			} else {
				return [UIImage imageNamed:@"WhiteK.png"];
			}
		case QUEEN:
			if (figColor == CBLACK) {
				return [UIImage imageNamed:@"BlackQ.png"];
			} else {
				return [UIImage imageNamed:@"WhiteQ.png"];
			}
		case ROCK:
			if (figColor == CBLACK) {
				return [UIImage imageNamed:@"BlackR.png"];
			} else {
				return [UIImage imageNamed:@"WhiteR.png"];
			}
		case BISHOP:
			if (figColor == CBLACK) {
				return [UIImage imageNamed:@"BlackB.png"];
			} else {
				return [UIImage imageNamed:@"WhiteB.png"];
			}
		case KNIGHT:
			if (figColor == CBLACK) {
				return [UIImage imageNamed:@"BlackN.png"];
			} else {
				return [UIImage imageNamed:@"WhiteN.png"];
			}
		case PAWN:
			if (figColor == CBLACK) {
				return [UIImage imageNamed:@"BlackP.png"];
			} else {
				return [UIImage imageNamed:@"WhiteP.png"];
			}
		default:
			return nil;
	}
}


- (id)initFigure:(unsigned char)figure {
	
	if (self = [super initWithFrame:CGRectMake(0, 0, 35, 35)]) {
		self.opaque = NO;
		self.liveState = LIVING;
		self.model = figure;
		self.position = nil;
		image = [Figure imageByType:FIGURE(self.model) forColor:COLOR(self.model)];
		smallImage = [Figure smallImageByType:FIGURE(self.model) forColor:COLOR(self.model)];
	}
	
	return self;
}

- (void)promote:(unsigned char)figType {

	image = [Figure imageByType:FIGURE(figType) forColor:COLOR(self.model)];
	[self setNeedsDisplay];
}

- (void)kill:(BOOL)died {

	if (died) {
		self.bounds = CGRectMake(0, 0, 20, 20);
		liveState = KILLED;
	} else {
		self.bounds = CGRectMake(0, 0, 35, 35);
		liveState = LIVING;
	}
}

- (void)drawRect:(CGRect)rect {
	
	if (liveState == KILLED) {
		[smallImage drawAtPoint:CGPointMake(0, 0)];
	} else {
		[image drawAtPoint:CGPointMake(0, 0)];
	}
}

@end
