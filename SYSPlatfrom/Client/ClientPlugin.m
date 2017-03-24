//
//  ClientPlugin.m
//  SYS Platfrom
//
//  Created by Jason_Mac on 2016/12/29.
//  Copyright © 2016年 Jason_Mac. All rights reserved.
//

#import "ClientPlugin.h"
#import "ClientManager.h"
#import "EnvPluginForefather.h"

@interface ClientPlugin()
{
    id<EnvPluginForefather> _sysPlugin;
    ClientManager* _manage ;
}

@end

@implementation ClientPlugin
{
    BOOL mStopped ;
}

@synthesize stopped = mStopped ;

- (instancetype) init
{
    if (self = [super init]) {
        _manage = [[ClientManager alloc] init];
    }
    
    return self;
}

- (enum eTypePlugin) typePlugin
{
    return FUNCTION;
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
        [_manage getData:parameters];
    }
    
}

/**************  stoppable implement  ***************/

-(void)setStopped:(BOOL)stopped
{
    mStopped = stopped;
    
    [_manage setStopped:mStopped] ;
}

-(BOOL)stopped
{
    return mStopped;
}

/****************************************************/

@end
