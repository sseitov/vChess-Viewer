//
//  DeskRule.h
//  vChess
//
//  Created by Sergey Seitov on 1/26/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeskRule : UIView {

	bool bHorizontal;
	bool bRotate;
	CGGradientRef	gradient;
}

- (id)initHorizontalRule:(bool)horizontal withFrame:(CGRect)frame;

@property (readwrite, nonatomic) bool bHorizontal;
@property (readwrite, nonatomic) bool bRotate;

@end
