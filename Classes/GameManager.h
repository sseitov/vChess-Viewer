//
//  GameManager.h
//  vChess
//
//  Created by Sergey Seitov on 6/29/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChessComLoader.h"

@interface GameManager : UITableViewController <ChessComLoaderDelegate>

@property (nonatomic, strong) NSArray *masterPackages;

@end
