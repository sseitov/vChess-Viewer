//
//  Figure.h
//  vChess
//
//  Created by Sergey Seitov on 1/29/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>

enum LiveState {
	LIVING,
	KILLED,
	ALIVED
};

@interface Figure : UIView {

	unsigned char	model;
	NSNumber		*position;
	UIImage			*image;
	UIImage			*smallImage;
	int				liveState;
}

@property (readwrite, nonatomic) unsigned char	model;
@property (strong, nonatomic) NSNumber *position;
@property (readwrite, nonatomic) int liveState;

- (id)initFigure:(unsigned char)model;
- (void)kill:(BOOL)died;
- (void)promote:(unsigned char)figType;

@end
