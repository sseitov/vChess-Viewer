//
//  LostFigures.h
//  vChess
//
//  Created by Sergey Seitov on 9/11/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LostFigures : UIView {

	CGGradientRef	gradient;
	UIImageView		*lostLabel;
}

@property (strong, nonatomic) NSMutableArray	*array;

- (id)initWithFrame:(CGRect)frame image:(UIImage*)image;

@end
