//
//  DeskRule.m
//  vChess
//
//  Created by Sergey Seitov on 1/26/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import "DeskRule.h"


@implementation DeskRule

@synthesize bHorizontal;
@synthesize bRotate;

- (void)dealloc {
	
	CGGradientRelease(gradient);
}

- (id)initHorizontalRule:(bool)horizontal withFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
		self.bHorizontal = horizontal;
		self.bRotate = NO;
		self.opaque = NO;
		
		CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
		CGFloat colors[] =
		{
			255.0 / 255.0, 255.0 / 255.0, 255.0 / 255.0, 1.00,
			206.0 / 255.0, 206.0 / 255.0, 206.0 / 255.0, 1.00,
			164.0 / 255.0, 164.0 / 255.0, 164.0 / 255.0, 1.00,
		};
		gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
		CGColorSpaceRelease(rgb);
	}
	return self;
}

- (void)drawRect:(CGRect)rect {

    CGContextRef context = UIGraphicsGetCurrentContext();
	
	// create bubble clip path
	CGFloat radius = 10.0;
	CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
	CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	CGContextClosePath(context);
	
	// draw bubble with gradient
	CGContextSaveGState(context);
	CGContextClip(context);
	if (bHorizontal) {
		CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, rect.size.height), 0);
	} else {
		CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(rect.size.width, 0), 0);
	}

	CGContextRestoreGState(context);
	
	UIFont *font = [UIFont fontWithName:@"Verdana-Bold" size:14];
	if (bHorizontal) {
		NSArray *labels;
		if (!bRotate) {
			labels = [NSArray arrayWithObjects:@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h", nil];
		} else {
			labels = [NSArray arrayWithObjects:@"h", @"g", @"f", @"e", @"d", @"c", @"b", @"a", nil];
		}
		CGRect rect = CGRectMake(0, 0, 35, 20);
		for (int i=0; i<8; i++) {
			[[labels objectAtIndex:i] drawInRect:rect withFont:font lineBreakMode:(UILineBreakMode)0 alignment:NSTextAlignmentCenter];
			rect.origin.x += 35;
		}
	} else {
		NSArray *labels;
		if (!bRotate) {
			labels = [NSArray arrayWithObjects:@"8", @"7", @"6", @"5", @"4", @"3", @"2", @"1", nil];		
		} else {
			labels = [NSArray arrayWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", nil];		
		}

		CGRect rect = CGRectMake(0, 10, 20, 35);
		for (int i=0; i<8; i++) {
			[[labels objectAtIndex:i] drawInRect:rect withFont:font lineBreakMode:(UILineBreakMode)0 alignment:NSTextAlignmentCenter];
			rect.origin.y += 35;
		}
	}
}

@end
