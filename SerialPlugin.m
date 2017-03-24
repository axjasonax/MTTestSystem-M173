//
//  SerialPlugin.m
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/18.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import "SerialPlugin.h"
#import "SerialManager.h"

@interface SerialPlugin()
{
    SerialManager *_manager ;
}

@end

@implementation SerialPlugin


-(instancetype)init
{
    if (self = [super init]) {
        _manager = [[SerialManager alloc] init];
    }
    
    return self;
}

- (void) initializeWithParameters:(NSArray *)parameters
{
    NSLog(@"%@ not implementate the function named \"initializeWithParameters:\"", self.className);
}


- (void) executeWithParameters:(NSArray *)parameters
{
    NSString* selector = parameters[0];
    if ([selector rangeOfString:@"commit"].length > 0 || [selector rangeOfString:@"stopped"].length > 0 || [selector rangeOfString:@"reset"].length > 0)
    {
        
    }
    else
    {
        [_manager getSerialData:parameters];
    }
    
}

-(void)setStopped:(BOOL)stopped
{
    [_manager setStopped:stopped] ;
}


@end
