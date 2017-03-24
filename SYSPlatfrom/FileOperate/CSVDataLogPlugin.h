//
//  SumaryLogPlugin.h
//  X2AX2B
//
//  Created by hotabbit on 14-8-5.
//  Copyright (c) 2014年 hotabbit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginForFather.h"

//#define DIR_DATA_LOG @"/vault/Data_Log";

@interface CSVDataLogPlugin : NSObject<PluginForFather>
- (void)initializeWithParameters:(NSArray *)parameters;
- (void)executeWithParameters:(NSArray *)parameters;
@end
