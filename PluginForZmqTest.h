//
//  PluginForZmqTest.h
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/22.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//


#ifndef UIPluginForFather_h
#define UIPluginForFather_h

@protocol PluginForZmqTest <NSObject>

//- (void) executeWithParameters:(NSArray *) parameters;
-(void) executeWithParameters:(NSArray *)parameters;

@optional
- (void) initializeWithParameters:(NSArray *)parameters;

@end


#endif /* UIPluginForFather_h */