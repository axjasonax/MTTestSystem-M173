//
//  PluginForefather.h
//  X2AX2B
//
//  Created by hotabbit on 14-8-2.
//  Copyright (c) 2014年 hotabbit. All rights reserved.
//

/*  zmq测试类暂定链表中第二个元素为测试结构体  */


#import <Foundation/Foundation.h>
#import "Stoppable.h"

enum eTypePlugin
{
    FUNCTION,
    EVENT
};

@protocol PluginForFather <NSObject, Stoppable>

- (void) executeWithParameters:(NSArray *) parameters;
@property (readonly, nonatomic) enum eTypePlugin typePlugin;

@optional
- (void) initializeWithParameters:(NSArray *)parameters;

@end
