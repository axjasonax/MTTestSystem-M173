//
//  ImageManager.m
//  GrapeModule
//
//  Created by Galib Arrieta on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageManager.h"

@implementation ImageManager

@synthesize imgPass = _imgPass;
@synthesize imgFail = _imgFail;
@synthesize imgTesting = _imgTesting;
@synthesize imgRebooting = _imgRebooting;

-(id) init {
    self = [super init];
    if (self) {
        do {
            NSString* imageName = [[NSBundle mainBundle] pathForResource:@"pass" ofType:@"png"];
            _imgPass = [[NSImage alloc] initWithContentsOfFile:imageName];
            if (_imgPass == nil) {
                NSLog(@"Failed to load the following image:\n%@",imageName); 
                break;
            }
            
            imageName = [[NSBundle mainBundle] pathForResource:@"fail" ofType:@"png"];
            _imgFail = [[NSImage alloc] initWithContentsOfFile:imageName];
            if (_imgFail == nil) {
                NSLog(@"Failed to load the following image:\n%@",imageName); 
                break;
            }
            
            imageName = [[NSBundle mainBundle] pathForResource:@"testing" ofType:@"png"];
            _imgTesting = [[NSImage alloc] initWithContentsOfFile:imageName];
            if (_imgTesting == nil) {
                NSLog(@"Failed to load the following image:\n%@",imageName); 
                break;
            }
			
			imageName = [[NSBundle mainBundle] pathForResource:@"rebooting" ofType:@"png"];
            _imgRebooting = [[NSImage alloc] initWithContentsOfFile:imageName];
            if (_imgRebooting == nil) {
                NSLog(@"Failed to load the following image:\n%@",imageName); 
                break;
            }
			imageName = [[NSBundle mainBundle] pathForResource:@"ready" ofType:@"png"];
            _imgReady = [[NSImage alloc] initWithContentsOfFile:imageName];
            if (_imgReady == nil) {
                NSLog(@"Failed to load the following image:\n%@",imageName);
                break;
            }
            imageName = [[NSBundle mainBundle] pathForResource:@"stopped" ofType:@"png"];
            _imgStopped = [[NSImage alloc] initWithContentsOfFile:imageName];
            if (_imgStopped == nil) {
                NSLog(@"Failed to load the following image:\n%@",imageName);
                break;
            }
            imageName = [[NSBundle mainBundle] pathForResource:@"fatal_error" ofType:@"png"];
            _imgFatalError = [[NSImage alloc] initWithContentsOfFile:imageName];
            if (_imgFatalError == nil) {
                NSLog(@"Failed to load the following image:\n%@",imageName);
                break;
            }
            imageName = [[NSBundle mainBundle] pathForResource:@"Pass1" ofType:@"png"];
            _imgBigPass = [[NSImage alloc] initWithContentsOfFile:imageName];
            if (_imgBigPass == nil) {
                NSLog(@"Failed to load the following image:\n%@",imageName);
                break;
            }
            imageName = [[NSBundle mainBundle] pathForResource:@"Fail1" ofType:@"png"];
            _imgBigFail = [[NSImage alloc] initWithContentsOfFile:imageName];
            if (_imgBigFail == nil) {
                NSLog(@"Failed to load the following image:\n%@",imageName);
                break;
            }
            imageName = [[NSBundle mainBundle] pathForResource:@"loopTest1" ofType:@"png"];
            _imgLoopTest1 = [[NSImage alloc] initWithContentsOfFile:imageName];
            if (_imgLoopTest1 == nil) {
                NSLog(@"Failed to load the following image:\n%@",imageName);
                break;
            }
            imageName = [[NSBundle mainBundle] pathForResource:@"loopTest2" ofType:@"png"];
            _imgLoopTest2 = [[NSImage alloc] initWithContentsOfFile:imageName];
            if (_imgLoopTest2 == nil) {
                NSLog(@"Failed to load the following image:\n%@",imageName);
                break;
            }
            imageName = [[NSBundle mainBundle] pathForResource:@"comm._error" ofType:@"png"];
            _imgCommError = [[NSImage alloc] initWithContentsOfFile:imageName];
            if (_imgCommError == nil) {
                NSLog(@"Failed to load the following image:\n%@",imageName);
                break;
            }
            imageName = [[NSBundle mainBundle] pathForResource:@"greenLed" ofType:@"png"] ;
            _imgGreenLed = [[NSImage alloc] initWithContentsOfFile:imageName] ;
            if(_imgGreenLed == nil){
                NSLog(@"Fail to load the following image:\n%@",imageName);
                break ;
            }
            imageName = [[NSBundle mainBundle] pathForResource:@"redLed" ofType:@"png"] ;
            _imgRedLed = [[NSImage alloc] initWithContentsOfFile:imageName] ;
            if(_imgRedLed == nil){
                NSLog(@"Fail to load the following image:\n%@",imageName) ;
                break ;
            }

        } while (0);
        
    }
    
    return self;
}

@end
