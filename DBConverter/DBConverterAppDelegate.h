//
//  DBConverterAppDelegate.h
//  DBConverter
//
//  Created by Sergey Seitov on 7/1/10.
//  Copyright 2010 Progorod Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DBConverterAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
