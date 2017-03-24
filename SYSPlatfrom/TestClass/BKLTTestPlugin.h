//
//  BKLTTestPlugin.h
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/23.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PluginForFather.h"

@interface BKLTTestPlugin : NSObject<PluginForFather>
- (void)initializeWithParameters:(NSArray *)parameters;
- (void)executeWithParameters:(NSArray *)parameters;

@end
