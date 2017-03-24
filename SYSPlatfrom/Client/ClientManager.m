//
//  ClientManager.m
//  SYS Platfrom
//
//  Created by Jason_Mac on 2016/12/29.
//  Copyright © 2016年 Jason_Mac. All rights reserved.
//

#import "ClientManager.h"
#import "Client.h"
#import "Parser.h"
#import "Configuration.h"
#import "SpeicalCmd.h"

@interface ClientManager()
{
    
}

@end

@implementation ClientManager
{
    BOOL mStopped ;
}

@synthesize stopped = mStopped ;


-(instancetype)init
{
    if(self = [super init])
    {
        
    }
    
    return self ;
}

- (void)writeCommand:(TestUnit *)unit client:(Client *)client
{
    [client getAllData] ;
    
    if(unit.bufferName && ![unit.bufferName isEqual:@""])
    {
        NSString* combinedCommand = [NSString stringWithString:unit.testCommand] ;
        combinedCommand = [NSString stringWithFormat:combinedCommand,(NSString*)[[Configuration instance].bufferStore objectForKey:unit.bufferName]] ;
        [client sendData:combinedCommand] ;
    }
    else if(unit.speicalCommand && ![unit.speicalCommand isEqual:@""])
    {
        SpeicalCmd* spcmd = [[NSClassFromString(unit.speicalCommand) alloc] init] ;
        NSString* cmd = [spcmd speicalCmd] ;
        [client sendData:cmd] ;
    }
    else
    {
        [client sendData:unit.testCommand] ;
    }
    
    [NSThread sleepForTimeInterval:0.01] ;
}

-(NSString*)readData:(TestUnit *)unit client:(Client*)client
{
    NSString* strRtn = [[NSString alloc] init] ;
    
    if(unit.endStr != nil && ![unit.endStr isEqualToString:@""])
    {
        strRtn = [client ReadTo:unit.endStr timeOut:[unit.timeout doubleValue] Interval:0.001] ;
    }
    else if (unit.endFormat != nil && ![unit.endFormat isEqualToString:@""])
    {
        strRtn = [client ReadRegularFormat:unit.endFormat timeOut:[unit.timeout doubleValue] Interval:0.001] ;
    }
    else if(unit.needLength != nil)
    {
        strRtn =[client ReadRegularLen:[unit.needLength intValue] timeOut:[unit.timeout doubleValue] Interval:0.001] ;
    }
    else if(unit.mutableEndStr != nil && ![unit.mutableEndStr isEqualToString:@""])
    {
        strRtn = [client ReadMutableEndStr:unit.mutableEndStr andSubStr:unit.mutableSubStr timeOut:[unit.timeout doubleValue] Interval:0.001] ;
    }
    else
    {
        [NSThread sleepForTimeInterval:[unit.timeout doubleValue]] ;
        
        strRtn = [client getAllData] ;
    }
    
    return strRtn ;
}

-(NSString*)getData:(NSArray *)parameter
{
    @autoreleasepool
    {
        NSString* strData= [[NSString alloc] init] ;
        
        NSString* selector = [parameter objectAtIndex:0] ;
        TestUnit* unit = [parameter objectAtIndex:1];
        Client* client ;
        
        if(![unit.type isEqualToString:@"Socket"])
        {
            return nil ;
        }
        
        if(unit.isExcluHardware)
        {
            client = [[Configuration instance].socketBox objectForKey:[[NSString alloc] initWithFormat:@"%@%@",unit.hardwareName,[selector substringFromIndex:selector.length - 1]]] ;
        }
        else
        {
            client = [[Configuration instance].socketBox objectForKey:unit.hardwareName] ;
        }
        
        @try
        {
            unit.isPass = YES ;
            unit.testValue = unit.testReturnStr = @"" ;
            
            if(!client.isConnected)
            {
                if(![client connect])
                {
                    unit.isPass = NO ;
                    
                    unit.testValue = unit.testReturnStr = [NSString stringWithFormat:@"%@ can't connected to server ",@"SOCKET"] ;
                    
                    return nil ;
                }
                else
                {
                    [NSThread sleepForTimeInterval:0.01] ;
                }
            }
            else
            {
                [NSThread sleepForTimeInterval:0.01] ;
            }
            
            [self writeCommand:unit client:client] ;
            strData = [self readData:unit client:client] ;
            strData = [strData stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
            strData = [strData stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
            strData = [strData stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            strData = [strData stringByReplacingOccurrencesOfString:@" " withString:@""];
            
        } @catch (NSException *exception)
        {
            unit.isPass = NO;
            strData = nil;
        }
        
        return [self extractSerialData:strData param:unit];
        
    }
}

// 提取数据
- (NSString*) extractSerialData:(NSString *)data param:(TestUnit *)unit
{
    if(unit.pattern)
    {
        
    }
    else
    {
        unit.testReturnStr = data;
        // 数据为nil时，处理情况
        if (data == nil || [data isEqual:@""]) {
            unit.isPass = NO;
            unit.testValue = @"(null)";
            unit.testReturnStr = @"Port disconnet or block or DUT problems";
            return data;
        }
        
        Parser* parser = [[NSClassFromString(unit.parser) alloc] init];
        unit = [parser parse:data usingTestUnit:unit];
        
        if ([unit.testValue isEqual:@""] || ([[unit.testValue lowercaseString] rangeOfString:@"error"].length > 0)
            || [[unit.testValue lowercaseString] rangeOfString:@"fail"].length > 0) {
            unit.isPass = NO;
        }
        
        if (unit.testName != nil &&![unit.testName isEqual:@""])
            NSLog(@"[SERIAL]unit testResult is = %@, isPass = %hhd",unit.testValue, unit.isPass);
    }
    return unit.testValue;
}


@end
