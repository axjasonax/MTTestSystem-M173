//
//  Resolver.h
//  X2a
//
//  Created by WangJackie on 15/6/23.
//  Copyright (c) 2015年 WangJackie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Config.h"
#import "TestItem.h"

@interface Parser : NSObject
- (TestItem *)parse:(NSString *)serialData usingTestUnit:(TestItem *)unit;
@end
