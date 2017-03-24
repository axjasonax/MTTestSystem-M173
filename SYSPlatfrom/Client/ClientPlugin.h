//
//  ClientPlugin.h
//  SYS Platfrom
//
//  Created by Jason_Mac on 2016/12/29.
//  Copyright © 2016年 Jason_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginForefather.h"

@interface ClientPlugin : NSObject<PluginForefather>
- (void)initializeWithParameters:(NSArray *)parameters;
- (void)executeWithParameters:(NSArray *)parameters;
@end
