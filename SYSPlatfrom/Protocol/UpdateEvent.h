//
//  UpdateEvent.h
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/17.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#ifndef UpdateEvent_h
#define UpdateEvent_h

#import "TestItem.h"

@protocol UpdateEvent <NSObject>

@required
-(void)testBeginWithItem:(TestItem *) unit atRow:(NSInteger) row;
-(void)testEndWithItem:(TestItem *) unit atRow:(NSInteger) row;

@end

#endif /* UpdateEvent_h */
