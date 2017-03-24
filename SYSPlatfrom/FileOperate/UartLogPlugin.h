//
//  UartLogPlugin.h
//  X2a
//
//  Created by Jack.MT on 15/8/14.
//  Copyright (c) 2015年 Jack.MT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginForFather.h"

//#define DIR_UART_LOG    @"/vault/Uart_Log"

@interface UartLogPlugin : NSObject<PluginForFather>
@property(readonly) NSString *logPath;

@end
