//
//  Desk.m
//  vChess
//
//  Created by Sergey Seitov on 1/26/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import "Desk.h"
#import "DeskRule.h"
#import "Figure.h"
#import "LostFigures.h"
#import <QuartzCore/QuartzCore.h>

#include "vchess/game.h"
using namespace vchess;

@implementation Desk

@synthesize playMode;

NSString* const PlayNextNotification = @"PlayNextNotification";
NSString* const PlayPreviuoseNotification = @"PlayPreviuoseNotification";

- (void)dealloc {

	delete currentGame;
}

- (id)initWithFrame:(CGRect)frame {

	if (self = [super initWithFrame:frame]) {
		self.opaque = NO;
		deskImage = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, 280, 280)];
		deskImage.image = [UIImage imageNamed:@"ChessDesk.png"];
		[self addSubview:deskImage];
		
		whiteLost = [[LostFigures alloc] initWithFrame:CGRectMake(5, 305, 20, 20) 
										image:[UIImage imageNamed:@"WhiteCross.png"]];
		[self addSubview:whiteLost];
		
		blackLost = [[LostFigures alloc] initWithFrame:CGRectMake(5, 325, 20, 20)
										image:[UIImage imageNamed:@"BlackCross.png"]];
		[self addSubview:blackLost];
		
		horzRule = [[DeskRule alloc] initHorizontalRule:YES withFrame:CGRectMake(30, 280, 280, 20)];
		[self addSubview:horzRule];
		
		vertRule = [[DeskRule alloc] initHorizontalRule:NO withFrame:CGRectMake(10, 0, 20, 280)];
		[self addSubview:vertRule];
		
		currentGame = new Game();
		figures = [[NSMutableArray alloc] init];
		for (int i=0; i<vchess::Game::POSITION_SIZE; i++) {
			unsigned char cell = currentGame->positionAt(i);
			if (cell > 0 && cell < 0xff) {
				Figure *f = [[Figure alloc] initFigure:cell];
				[self addSubview:f];
				[self moveFigure:f to:[NSNumber numberWithInt:i]];
				[figures addObject:f];
			}
		}
	}
	return self;
}

- (void)setGame:(vchess::Game*)game {
	
	delete currentGame;
	currentGame = game;
	[blackLost.array removeAllObjects];
	[whiteLost.array removeAllObjects];
	
	NSEnumerator *enumerator = [figures objectEnumerator];
	Figure *f;
	while ((f = [enumerator nextObject])) {
		if (f.liveState == KILLED) {
			[self aliveFigure:f];
		}
		[f promote:f.model];
	}
	
	isRotate = NO;
	NSMutableArray *array = [NSMutableArray arrayWithArray:figures];
	for (int i=0; i<vchess::Game::POSITION_SIZE; i++) {
		unsigned char cell = currentGame->positionAt(i);
		if (cell > 0 && cell < 0xff) {
			Figure *f = [self figureFor:cell fromArray:array];
			NSNumber *pos = [NSNumber numberWithInt:i];
			if (!f) {
				NSLog(@"not found figure at %s", POSITION_TEXT(i).data());
			} else {
				[self moveFigure:f to:pos];
			}
		}
	}
	
	self.playMode = NOPLAY;
	
	CGRect rc = whiteLost.frame;
	rc.size.width = 20;
	whiteLost.frame = rc;
	rc = blackLost.frame;
	rc.size.width = 20;
	blackLost.frame = rc;
}

- (void)rotate {
	
	isRotate = !isRotate;
	horzRule.bRotate = isRotate;
	[horzRule setNeedsDisplay];
	vertRule.bRotate = isRotate;
	[vertRule setNeedsDisplay];
	NSEnumerator *enumerator = [figures objectEnumerator];
	Figure *f;
	while ((f = [enumerator nextObject])) {
		if (f.position) {
			[self moveFigure:f to:f.position];
		}
	}
}

- (CGPoint)cellCenterX:(int)x Y:(int)y {
	
	if (!isRotate) {
		int height = 280 - 35 - y*35 + 17;
		int offset = 30 + x *35 + 17;
		return CGPointMake(offset, height);;
	} else {
		int height = y*35 + 17;
		int offset = 30 + 280 - 35 - x*35 + 17;
		return CGPointMake(offset, height);;
	}
}

- (CGPoint)lostCenterForColor:(int)color {
	
	if (color == vchess::CWHITE) {
		return CGPointMake(15 + [whiteLost.array count]*20, 315); //330
	} else {
		return CGPointMake(15 + [blackLost.array count]*20, 335); // 355
	}

}

- (Figure*)figureAt:(NSNumber*)position {
	
	NSEnumerator *enumerator = [figures objectEnumerator];
	Figure *f;
	while (f = [enumerator nextObject]) {
		if (f.position && [f.position isEqual:position]) {
			return f;
		}
	}
	return nil;
}

- (Figure*)figureFor:(unsigned char)model fromArray:(NSMutableArray*)array {
	
	NSEnumerator *enumerator = [array objectEnumerator];
	Figure *f;
	while (f = [enumerator nextObject]) {
		if (f.model == model) {
			[array removeObject:f];
			return f;
		}
	}
	return nil;
}

- (BOOL)turnForward {

	if (!currentGame->hasNextTurn()) {
		return NO;
	}
	Turn turn = currentGame->nextTurn();
	
	NSMutableArray *theFigures = [NSMutableArray array];
	NSMutableArray *thePositions = [NSMutableArray array];
	Figure *f = [self figureAt:[NSNumber numberWithInt:turn.fromPos]];
	if (!f) {
		NSLog(@"Figure not found in turn %s", POSITION_TEXT(turn.fromPos).data());
		return false;
	}
	if (IS_PROMOTE(turn.turnType)) {
		[f promote:turn.figure];
	}
	[theFigures addObject:f];
	[thePositions addObject:[NSNumber numberWithInt:turn.toPos]];
	
	if (TURN(turn.turnType) == KingCastling || TURN(turn.turnType) == QueenCastling) {
		Figure *rock = [self figureAt:[NSNumber numberWithInt:turn.rockFromPos]];
		if (!rock) {
			NSLog(@"Figure not found in turn %s", POSITION_TEXT(turn.rockFromPos).data());
			return false;
		}
		[theFigures addObject:rock];
		[thePositions addObject:[NSNumber numberWithInt:turn.rockToPos]];
	} else if (TURN(turn.turnType) == Capture) {
		Figure *eat;
		if (turn.eatPos >= 0) {
			eat = [self figureAt:[NSNumber numberWithInt:turn.eatPos]];
		} else {
			eat = [self figureAt:[NSNumber numberWithInt:turn.toPos]];
		}
		if (!eat) {
			NSLog(@"Figure not found in turn %s", POSITION_TEXT(turn.toPos).data());
			return false;
		}

		if (COLOR(turn.figure) == CWHITE) {
			[blackLost.array addObject:eat];
		} else {
			[whiteLost.array addObject:eat];
		}
		eat.liveState = KILLED;
		[theFigures addObject:eat];
		[thePositions addObject:[NSNull null]];
	}
	
		
	[self moveFigures:theFigures toPos:thePositions];
	
	if (currentGame->hasNextTurn()) {
		return YES;
	} else {
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Game over"
							  message:[NSString stringWithFormat:@"%@\n%@\n%@", 
									   [NSString stringWithUTF8String:currentGame->white().data()], 
									   [NSString stringWithUTF8String:currentGame->black().data()], 
									   [NSString stringWithUTF8String:currentGame->result().data()]]
							  delegate:nil
							  cancelButtonTitle:@"Ok"  
							  otherButtonTitles:nil];
		[alert show];
		return NO;
	}
}

- (BOOL)turnBack {
	
	if (!currentGame->hasPrevTurn()) {
		return NO;
	}
	Turn turn = currentGame->prevTurn();
	
	NSMutableArray *theFigures = [NSMutableArray array];
	NSMutableArray *thePositions = [NSMutableArray array];
	Figure *f = [self figureAt:[NSNumber numberWithInt:turn.toPos]];
	if (!f) {
		NSLog(@"Figure not found in turn %s", POSITION_TEXT(turn.toPos).data());
		return false;
	}
	if (IS_PROMOTE(turn.turnType)) {
		[f promote:f.model];
	}
	[theFigures addObject:f];
	[thePositions addObject:[NSNumber numberWithInt:turn.fromPos]];
	
	if (turn.turnType == KingCastling || turn.turnType == QueenCastling) {
		Figure *rock = [self figureAt:[NSNumber numberWithInt:turn.rockToPos]];
		if (!rock) {
			NSLog(@"Figure not found in turn %s", POSITION_TEXT(turn.rockToPos).data());
			return false;
		}
		[theFigures addObject:rock];
		[thePositions addObject:[NSNumber numberWithInt:turn.rockFromPos]];
	} else if (TURN(turn.turnType) == Capture) {
		Figure *eat;
		if (COLOR(turn.figure) == CWHITE) {
			eat = [blackLost.array lastObject];
			[blackLost.array removeLastObject];
		} else {
			eat = [whiteLost.array lastObject];
			[whiteLost.array removeLastObject];
		}
		eat.liveState = ALIVED;
		[theFigures addObject:eat];
		if (turn.eatPos >= 0) {
			[thePositions addObject:[NSNumber numberWithInt:turn.eatPos]];
		} else {
			[thePositions addObject:[NSNumber numberWithInt:turn.toPos]];
		}
	}
	[self moveFigures:theFigures toPos:thePositions];
	
	return YES;
}

#pragma mark Player animation

- (void)killFigure:(Figure*)f {
	
	[f kill:YES];
	if (COLOR(f.model) == CWHITE) {
		CGRect rc = whiteLost.frame;
		rc.size.width += 20;
		whiteLost.frame = rc;
	} else {
		CGRect rc = blackLost.frame;
		rc.size.width += 20;
		blackLost.frame = rc;
	}
}

- (void)aliveFigure:(Figure*)f {
	
	[f kill:NO];
	if (COLOR(f.model) == vchess::CWHITE) {
		CGRect rc = whiteLost.frame;
		rc.size.width -= 20;
		whiteLost.frame = rc;
	} else {
		CGRect rc = blackLost.frame;
		rc.size.width -= 20;
		blackLost.frame = rc;
	}
}

- (void)moveFigure:(Figure*)f to:(NSNumber*)position {
	
	if (f.liveState == KILLED) {
		f.center = [self lostCenterForColor:COLOR(f.model)];
		f.position = nil;
	} else {
		unsigned char x, y;
		POS_FROM_NUM([position intValue], x, y);
		f.center = [self cellCenterX:x Y:y];
		f.position = position;
	}
	if (f.liveState == KILLED) {
		[self killFigure:f];
	} else if (f.liveState == ALIVED) {
		[self aliveFigure:f];
	}
}

- (void)moveFigures:(NSArray*)theFigures toPos:(NSArray*)positions {

	if (self.playMode == PLAY_FORWARD) {
		[UIView animateWithDuration:0.2 delay:0.8 options:UIViewAnimationOptionTransitionNone
						 animations:^{
							 self.userInteractionEnabled = NO;
							 for (int i=0; i<[theFigures count]; i++) {
								 [self moveFigure:[theFigures objectAtIndex:i] to:[positions objectAtIndex:i]];
							 }
						 }
						 completion:^(BOOL finished){
							 self.userInteractionEnabled = YES;
							 if (self.playMode == PLAY_FORWARD) {
								 [[NSNotificationCenter defaultCenter] postNotificationName:PlayNextNotification object:self];
							 } else if (self.playMode == PLAY_BACKWARD) {
								 [[NSNotificationCenter defaultCenter] postNotificationName:PlayPreviuoseNotification object:self];
							 }
						 }
		 ];
	} else if (self.playMode == PLAY_BACKWARD) {
		[UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionTransitionNone
						 animations:^{
							 self.userInteractionEnabled = NO;
							 for (int i=0; i<[theFigures count]; i++) {
								 [self moveFigure:[theFigures objectAtIndex:i] to:[positions objectAtIndex:i]];
							 }
						 }
						 completion:^(BOOL finished){
							 self.userInteractionEnabled = YES;
							 if (self.playMode == PLAY_FORWARD) {
								 [[NSNotificationCenter defaultCenter] postNotificationName:PlayNextNotification object:self];
							 } else if (self.playMode == PLAY_BACKWARD) {
								 [[NSNotificationCenter defaultCenter] postNotificationName:PlayPreviuoseNotification object:self];
							 }
						 }
		 ];
	} else {
		[UIView animateWithDuration:0.2
						 animations:^{
							 self.userInteractionEnabled = NO;
							 for (int i=0; i<[theFigures count]; i++) {
								 [self moveFigure:[theFigures objectAtIndex:i] to:[positions objectAtIndex:i]];
							 }
						 }
						 completion:^(BOOL finished){
							 self.userInteractionEnabled = YES;
						 }
		 ];
	}
}

#pragma mark Touch animation

- (void)animateFirstTouchAtPoint:(CGPoint)touchPoint {
#define GROW_ANIMATION_DURATION_SECONDS 0.15
	
	NSValue *touchPointValue = [NSValue valueWithCGPoint:touchPoint];
	[UIView beginAnimations:nil context:(void*)touchPointValue];
	[UIView setAnimationDuration:GROW_ANIMATION_DURATION_SECONDS];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
	CGAffineTransform transform = CGAffineTransformMakeScale(2.0, 2.0);
	dragFigure.transform = transform;
	[UIView commitAnimations];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	//Animation delegate method called when the animation's finished:
	// restore the transform and reenable user interaction
	dragFigure.transform = CGAffineTransformIdentity;
	self.userInteractionEnabled = YES;
}

- (void)animateFigure:(Figure*)figure to:(CGPoint)pt {

	self.userInteractionEnabled = NO;
	CALayer *dragLayer = figure.layer;
	
	// Create a keyframe animation to follow a path back to the center
	CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	bounceAnimation.removedOnCompletion = NO;
	
	CGFloat animationDuration = 0.2;
	
	
	// Create the path for the bounces
	CGMutablePathRef thePath = CGPathCreateMutable();
	
	CGFloat midX = pt.x;
	CGFloat midY = pt.y;
	CGFloat originalOffsetX = figure.center.x - midX;
	CGFloat originalOffsetY = figure.center.y - midY;
	CGFloat offsetDivider = 4.0;
	
	BOOL stopBouncing = NO;
	
	// Start the path at the placard's current location
	CGPathMoveToPoint(thePath, NULL, figure.center.x, figure.center.y);
	CGPathAddLineToPoint(thePath, NULL, midX, midY);
	
	// Add to the bounce path in decreasing excursions from the center
	while (stopBouncing != YES) {
		CGPathAddLineToPoint(thePath, NULL, midX + originalOffsetX/offsetDivider, midY + originalOffsetY/offsetDivider);
		CGPathAddLineToPoint(thePath, NULL, midX, midY);
		
		offsetDivider += 4;
		animationDuration += 1/offsetDivider;
		if ((abs(originalOffsetX/offsetDivider) < 6) && (abs(originalOffsetY/offsetDivider) < 6)) {
			stopBouncing = YES;
		}
	}
	
	bounceAnimation.path = thePath;
	bounceAnimation.duration = animationDuration;
	CGPathRelease(thePath);
	
	// Create a basic animation to restore the size of the figure
	CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
	transformAnimation.removedOnCompletion = YES;
	transformAnimation.duration = animationDuration;
	transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
	
	
	// Create an animation group to combine the keyframe and basic animations
	CAAnimationGroup *theGroup = [CAAnimationGroup animation];
	
	// Set self as the delegate to allow for a callback to reenable user interaction
	theGroup.delegate = self;
	theGroup.duration = animationDuration;
	theGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	
	theGroup.animations = [NSArray arrayWithObjects:bounceAnimation, transformAnimation, nil];
	
	
	// Add the animation group to the layer
	[dragLayer addAnimation:theGroup forKey:@"animatePlacardViewToCenter"];
	
	// Set the placard view's center and transformation to the original values in preparation for the end of the animation
	figure.center =  pt;
	figure.transform = CGAffineTransformIdentity;
}

#pragma mark Touches implementation
/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	// We only support single touches, so anyObject retrieves just that touch from touches
	UITouch *touch = [touches anyObject];
	
	// Only move the placard view if the touch was in the placard view
	if ([touch.view isKindOfClass:[Figure class]]) {
		// Animate the first touch
		dragFigure = (Figure*)[touch view];
		dragStart = dragFigure.center;
		CGPoint pt = dragFigure.center;
		pt.y -= dragFigure.bounds.size.height/2;
		dragFigure.center = pt;
		[self animateFirstTouchAtPoint:pt];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
	
	// If the touch was in the placardView, move the placardView to its location
	if ([touch view] == dragFigure) {
		CGPoint pt = [touch locationInView:self];
		pt.y -= dragFigure.bounds.size.height/2;
		dragFigure.center = pt;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *touch = [touches anyObject];
	
	// If the touch was in the placardView, bounce it back to the center
	if ([touch view] == dragFigure) {
		[self animateFigure:dragFigure to:dragStart];
	}		
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	dragFigure.center = self.center;
	dragFigure.transform = CGAffineTransformIdentity;
}
*/
@end
