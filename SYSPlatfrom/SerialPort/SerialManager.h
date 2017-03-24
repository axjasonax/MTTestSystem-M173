//
//  SerialManager.h
//  X2AX2B
//
//  Created by hotabbit on 14-8-5.
//  Copyright (c) 2014年 hotabbit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stoppable.h"

@interface SerialManager : NSObject<Stoppable>

- (NSString *) getSerialData:(NSArray *)parameter;
- (void) dispose;

@end
