//
//  HeaderView.m
//  vChess
//
//  Created by Sergey Seitov on 25.01.15.
//  Copyright (c) 2015 V-Channel. All rights reserved.
//

#import "HeaderView.h"

typedef enum {
	NSVerticalTextAlignmentTop,
	NSVerticalTextAlignmentMiddle,
	NSVerticalTextAlignmentBottom
} NSVerticalTextAlignment;

@interface NSString (VerticalAlign)
- (CGSize)drawInRect:(CGRect)rect withFont:(UIFont *)font verticalAlignment:(NSVerticalTextAlignment)vAlign;
- (CGSize)drawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode verticalAlignment:(NSVerticalTextAlignment)vAlign;
- (CGSize)drawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment verticalAlignment:(NSVerticalTextAlignment)vAlign;
@end

@implementation NSString (VerticalAlign)

- (CGSize)drawInRect:(CGRect)rect withFont:(UIFont *)font verticalAlignment:(NSVerticalTextAlignment)vAlign {
	switch (vAlign) {
		case NSVerticalTextAlignmentTop:
			break;
			
		case NSVerticalTextAlignmentMiddle:
			rect.origin.y = rect.origin.y + ((rect.size.height - font.pointSize) / 2);
			break;
			
		case NSVerticalTextAlignmentBottom:
			rect.origin.y = rect.origin.y + rect.size.height - font.pointSize;
			break;
	}
	return [self drawInRect:rect withFont:font];
}

- (CGSize)drawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode verticalAlignment:(NSVerticalTextAlignment)vAlign {
	switch (vAlign) {
		case NSVerticalTextAlignmentTop:
			break;
			
		case NSVerticalTextAlignmentMiddle:
			rect.origin.y = rect.origin.y + ((rect.size.height - font.pointSize) / 2);
			break;
			
		case NSVerticalTextAlignmentBottom:
			rect.origin.y = rect.origin.y + rect.size.height - font.pointSize;
			break;
	}
	return [self drawInRect:rect withFont:font lineBreakMode:lineBreakMode];
}

- (CGSize)drawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(NSLineBreakMode)lineBreakMode alignment:(NSTextAlignment)alignment verticalAlignment:(NSVerticalTextAlignment)vAlign {
	switch (vAlign) {
		case NSVerticalTextAlignmentTop:
			break;
			
		case NSVerticalTextAlignmentMiddle:
			rect.origin.y = rect.origin.y + ((rect.size.height - font.pointSize) / 2);
			break;
			
		case NSVerticalTextAlignmentBottom:
			rect.origin.y = rect.origin.y + rect.size.height - font.pointSize;
			break;
	}
	return [self drawInRect:rect withFont:font lineBreakMode:lineBreakMode alignment:alignment];
}

@end

@implementation HeaderView

- (void)awakeFromNib
{
	_whiteName = @"White";
	_blackName = @"Black";
}

- (void)drawRect:(CGRect)rect
{
    CGRect rw = CGRectMake(0, 0, rect.size.width/2, rect.size.height);
    UIBezierPath *w = [UIBezierPath bezierPathWithRoundedRect:rw cornerRadius:10.0];
    [[UIColor whiteColor] setFill];
    [w fill];
    CGRect rb = CGRectMake(rect.size.width/2, 0, rect.size.width/2, rect.size.height);
    UIBezierPath *b = [UIBezierPath bezierPathWithRoundedRect:rb cornerRadius:10.0];
    [[UIColor blackColor] setFill];
    [b fill];
	
	if (_whiteName) {
		[_whiteName drawInRect:rw
					  withFont:[UIFont fontWithName:@"HelveticaNeue" size:12]
				 lineBreakMode:NSLineBreakByWordWrapping
					 alignment:NSTextAlignmentCenter
			 verticalAlignment:NSVerticalTextAlignmentMiddle];
	}
	if (_blackName) {
		[[UIColor whiteColor] setFill];
		[_blackName drawInRect:rb
					  withFont:[UIFont fontWithName:@"HelveticaNeue" size:12]
				 lineBreakMode:NSLineBreakByWordWrapping
					 alignment:NSTextAlignmentCenter
			 verticalAlignment:NSVerticalTextAlignmentMiddle];
	}
}

@end
