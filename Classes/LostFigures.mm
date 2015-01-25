//
//  LostFigures.m
//  vChess
//
//  Created by Sergey Seitov on 9/11/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import "LostFigures.h"


@implementation LostFigures

@synthesize array;

- (void)dealloc {
	
	CGGradientRelease(gradient);
}

- (id)initWithFrame:(CGRect)frame image:(UIImage*)image {
	
	self = [super initWithFrame:frame];
    if (self) {
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
		
		lostLabel = [[UIImageView alloc] initWithImage:image];
		[self addSubview:lostLabel];
		lostLabel.center = CGPointMake(10, 10);
		array = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	// create bubble clip path
	CGFloat radius = 2.0;
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
	CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, rect.size.height), 0);
	
	CGContextRestoreGState(context);
}


@end
