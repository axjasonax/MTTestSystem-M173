//
//  UartLogPlugin.m
//  X2a
//
//  Created by Jack.MT on 15/8/14.
//  Copyright (c) 2015年 Jack.MT. All rights reserved.
//

#import "UartLogPlugin.h"
#import "TestItem.h"
#import "Config.h"

#define SEPARATE_LINE   @"------------------------------------------------------------------------\n\n\r\n"



@interface UartLogPlugin ()
{
    NSFileHandle* _fileHandle;
    NSDateFormatter* _formatter;
}
@end

@implementation UartLogPlugin
{
    BOOL mStopped;
}

@synthesize stopped = mStopped;

- (enum eTypePlugin) typePlugin
{
    return FUNCTION;
}

- (void) initializeWithParameters:(NSArray *)parameters
{
    _fileHandle = nil;
    _logPath = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[Config instance].uartLogFloderPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[Config instance].uartLogFloderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    _formatter = [[NSDateFormatter alloc] init];
    [_formatter setDateFormat:@"[yyyy-MM-dd HH:mm:ss]: "];
}

- (void) executeWithParameters:(NSArray *)parameters
{
    NSString* selector = [parameters objectAtIndex:0];
    TestItem* unit = [parameters objectAtIndex:1];
    NSString *sn = [parameters objectAtIndex:2];
    NSError *err = nil;
    
    if (unit == nil || ((unit.class == [TestItem class]) && ![unit.type isEqualToString:@"UUT"])) {
        return;
    }
    
    BOOL success = YES;
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];

    [fmt setDateFormat:@"yyyy_MM_dd"];
    NSString *dir = [[NSString alloc] initWithFormat:@"%@/%@", [Config instance].uartLogFloderPath, [fmt stringFromDate:[NSDate date]]];
    if(![[NSFileManager defaultManager] fileExistsAtPath:dir])
    {
        success = [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&err];
        
    }
    
    [fmt setDateFormat:@"HHmmss"];
    _logPath = (_logPath != nil) ? _logPath : [[NSString alloc] initWithFormat:@"%@/%@_%@.log",  dir, [fmt stringFromDate:[NSDate date]], sn];
    if(![[NSFileManager defaultManager] fileExistsAtPath:_logPath])
    {
        success = [[NSFileManager defaultManager] createFileAtPath:_logPath contents:nil attributes:nil];
    }

    _fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:_logPath];
    
    if(_fileHandle != nil)
    {
        [_fileHandle seekToEndOfFile];
        
        if ([selector isEqual:@"commit"] || [selector isEqualToString:@"stopped"] || [selector isEqual:@"reset"])
        {
            [_fileHandle writeData:[selector dataUsingEncoding:NSUTF8StringEncoding]];
            
            _logPath = nil;
        }
        else
        {
            if (unit.testReturnStr == nil || [unit.testReturnStr isEqual:@""]) {
                unit.testReturnStr = @"[No Return Data]";
            }
            
            [_fileHandle writeData:[[_formatter stringFromDate:[NSDate date]]
                                    dataUsingEncoding:NSUTF8StringEncoding]];
            [_fileHandle writeData:[unit.testCommand dataUsingEncoding:NSUTF8StringEncoding]];
            [_fileHandle writeData:[[unit.testReturnStr stringByReplacingOccurrencesOfString:unit.testCommand withString:@""] dataUsingEncoding:NSUTF8StringEncoding]];
            [_fileHandle writeData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        [_fileHandle closeFile];
        _fileHandle = nil;
    }
}

@end

