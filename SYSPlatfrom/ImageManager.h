//
//  ImageManager.h
//  GrapeModule
//
//  Created by Galib Arrieta on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import<Cocoa/Cocoa.h>

@interface ImageManager : NSObject

@property (readonly) NSImage* imgPass;
@property (readonly) NSImage* imgFail;
@property (readonly) NSImage* imgTesting;
@property (readonly) NSImage* imgRebooting;
@property (readonly) NSImage* imgReady;
@property (readonly) NSImage* imgStopped;
@property (readonly) NSImage *imgFatalError;
@property (readonly) NSImage *imgBigPass;
@property (readonly) NSImage *imgBigFail;
@property (readonly) NSImage *imgLoopTest1;
@property (readonly) NSImage *imgLoopTest2;
@property (readonly) NSImage *imgCommError;
@property (readonly) NSImage *imgGreenLed ;
@property (readonly) NSImage *imgRedLed ;

@end

