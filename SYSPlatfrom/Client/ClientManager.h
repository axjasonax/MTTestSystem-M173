//
//  ClientManager.h
//  SYS Platfrom
//
//  Created by Jason_Mac on 2016/12/29.
//  Copyright © 2016年 Jason_Mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Stoppable.h"

@interface ClientManager : NSObject<Stoppable>

- (NSString *) getData:(NSArray *)parameter;

@end
