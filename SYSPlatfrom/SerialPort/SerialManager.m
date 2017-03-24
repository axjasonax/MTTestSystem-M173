//
//  SerialManager.m
//  X2AX2B
//
//  Created by hotabbit on 14-8-5.
//  Copyright (c) 2014年 hotabbit. All rights reserved.
//

#import "SerialManager.h"
#import "serialPort.h"
#import "Config.h"
//#import "Untiy.h"
#import "Parser.h"
//#import "ControlBits.h"
//#import "JKSerialPort.h"
//#import <JKFramework/JKFramework.h>
#import "TestItem.h"

#define SERIAL @"SERIAL"

@interface SerialManager()
{
//    ControlBits *controlBit;

}
@end

@implementation SerialManager
{
    BOOL mStopped;
}

@synthesize stopped = mStopped;

- (instancetype) init
{
    if (self = [super init]) {
    }
    
    return self;
}

- (void) dealloc
{
    
}


- (void) dispose
{
//    for (SerialPort* port in [Config instance].portBox.allValues) {
//        if (port != nil) {
//            [port Close];
//        }
//    }
}


- (void)writeCommand:(TestItem *)unit port:(SerialPort *)port
{
    [port ReadExisting] ;
    

    if(unit.testCommand == nil ||[unit.testCommand isEqualToString:@""])
    {
        
    }
    else
    {
        [port WriteLine:[SerialManager parseCommand:unit.testCommand]];
    }
    
    [NSThread sleepForTimeInterval:0.01];
}

- (NSString *)readSerialData:(SerialPort *)port unit:(TestItem *)unit serialData:(NSString *)serialData
{
    if(unit.isCircleCheck && unit.endStr != nil && ![unit.endStr isEqualToString:@""])
    {
        serialData = [port CircleReadTo:unit.endStr] ;
    }
    else if([unit.endStr isEqualToString:@"."])
    {
        serialData = [port ReadTo:unit.endStr
                          Timeout:[unit.timeout intValue]
                     ReadInterval:0.5];
        
        [NSThread sleepForTimeInterval:0.01] ;
        serialData = [[NSString alloc] initWithFormat:@"%@%@",serialData,[port ReadExisting]] ;
        
        if(serialData.length -[serialData rangeOfString:@"."].location==1)
        {
            serialData = [serialData substringFromIndex:serialData.length - 1] ;
        }
        
    }
    else if([unit.endStr containsString:@";"])
    {
        serialData = [port ReadMutableEndStr:unit.endStr TimeOut:[unit.timeout intValue] ReadInterval:1] ;
    }
    else if([unit.needLength intValue] > 0)
    {
        serialData = [port ReadToRegularLen:[[unit.endStr substringFromIndex:3] intValue] Timeout:[unit.timeout intValue] ReadInterval:1] ;
    }
    else  if(unit.endStr != nil && ![unit.endStr isEqualToString:@""]){
        serialData = [port ReadTo:unit.endStr
                          Timeout:[unit.timeout intValue]
                     ReadInterval:1];
    }
    else
    {
        [NSThread sleepForTimeInterval:[unit.timeout doubleValue]/1000] ;
        [port ReadExisting];
    }
   
    unit.testReturnStr = serialData;
    
    return serialData;
}

// 获得串口中数据
- (NSString *) getSerialData:(NSArray *)parameter
{
    @autoreleasepool {
        NSString* __strong serialData = [[NSString alloc] init];
        NSString* selector = [parameter objectAtIndex:0] ;
        TestItem* unit = [parameter objectAtIndex:1];
        SerialPort* port ;
        
        if(![unit.type isEqualToString:@"Serial"])
        {
            return nil;
        }
        
        if(unit.isExcluHardware)
        {
            port = [[Config instance].portBox objectForKey:[[NSString alloc] initWithFormat:@"%@%@",unit.hardwareName,[selector substringFromIndex:selector.length - 1]]] ;
        }
        else
        {
            port = [[Config instance].portBox objectForKey:unit.hardwareName] ;
        }
        
        if (port == nil) {
            unit.testValue = (unit.testValue != nil && ![unit.testValue isEqualToString:@""]) ? unit.testValue : @"0";
            return nil;
        }
        
        @try {
            // clear old result
            unit.isPass = YES;
            unit.testValue = @"";
            unit.testReturnStr = @"";
            
            if (![port IsOpen])
            {
                if (![port Open])
                {
                    [port Close] ;
                    [NSThread sleepForTimeInterval:1] ;
                    
                    if(![port Open])
                    {
                        unit.isPass = NO;
                        unit.testValue = unit.testReturnStr = [[NSString alloc] initWithFormat:@"(Cant't Open Port <%@>)",[port devicePath]];
                        NSLog(@"open port<%@> error", [port devicePath]);
                        return nil;
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
                
            }
            [NSThread sleepForTimeInterval:0.01];
            
            
//            if (unit.testCommand != nil) {
//                
//                [self writeCommand:unit port:port parameter:parameter];
//                serialData = [self readSerialData:port unit:unit serialData:serialData];
//                serialData = [serialData stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
//                serialData = [serialData stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
//                serialData = [serialData stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
//                serialData = [serialData stringByReplacingOccurrencesOfString:@" " withString:@""];
//                
//                NSLog(@"serialData is:%@",serialData) ;
//                
//                NSLog(@"%@",serialData) ;
//                if([serialData isEqualToString:@"PASS"])
//                {
//                    unit.isPass = YES;
//                }
//            }
//            else if(unit.specialCommand != nil)
//            {
//                
//            }
            
            [self writeCommand:unit port:port] ;
            serialData = [self readSerialData:port unit:unit serialData:serialData];
            serialData = [serialData stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
            serialData = [serialData stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
            serialData = [serialData stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            serialData = [serialData stringByReplacingOccurrencesOfString:@" " withString:@""];

            NSLog(@"serialData is:%@",serialData) ;

            
            
        }
        @catch (NSException *exception) {
            unit.isPass = NO;
            serialData = nil;
            [self performSelectorOnMainThread:@selector(message:)
                                   withObject:exception.description
                                waitUntilDone:YES];
        }
        
        NSLog(@"Item %@:\r\nreceived Data:%@ from Port<%@> by command: %@", unit.itemName, serialData, unit.type, unit.testCommand);
        
        if(unit.isNeedClosehardware)
        {
            [port ReadExisting] ;
            [port Close] ;
        }
        
//        return [self extractSerialData:serialData param:unit station:[parameter[0] substringFromIndex:([parameter[0] length] - 1)].intValue];
        return [self extractSerialData:serialData param:unit];
    }
}


// 提取数据
- (NSString*) extractSerialData:(NSString *)serialData param:(TestItem *)unit
{
    if(unit == nil )
    {

    }
    else
    {
        unit.testReturnStr = serialData;
        // 数据为nil时，处理情况
        if (serialData == nil || [serialData isEqual:@""]) {
            unit.isPass = NO;
            unit.testValue = @"(null)";
            unit.testReturnStr = @"Port disconnet or block or DUT problems";
            return serialData;
        }
        
        Parser* parser = [[NSClassFromString(unit.parser) alloc] init];
        unit = [parser parse:serialData usingTestUnit:unit];

        if ([unit.testValue isEqual:@""] || ([[unit.testValue lowercaseString] rangeOfString:@"error"].length > 0)
                || [[unit.testValue lowercaseString] rangeOfString:@"fail"].length > 0) {
            unit.isPass = NO;
        }

        if (unit.itemName != nil &&![unit.itemName isEqual:@""])
            NSLog(@"[SERIAL]unit testResult is = %@, isPass = %hhd",unit.testValue, unit.isPass);
    }
    return unit.testValue;
}


// 提取数据
- (NSString*) extractSerialData:(NSString *)serialData param:(TestItem *)unit station:(int)stationNum
{
    if(unit == nil)
    {
        
    }
    else
    {
        unit.testReturnStr = serialData;
        // 数据为nil时，处理情况
        if (serialData == nil || [serialData isEqual:@""]) {
            unit.isPass = NO;
            unit.testValue = @"(null)";
            unit.testReturnStr = @"Port disconnet or block or DUT problems";
            return serialData;
        }
        
        Parser* parser = [[NSClassFromString(unit.parser) alloc] init];
       unit = [parser parse:serialData usingTestUnit:unit];
        
        if ([unit.testValue isEqual:@""] || ([[unit.testValue lowercaseString] rangeOfString:@"error"].length > 0)
            || [[unit.testValue lowercaseString] rangeOfString:@"fail"].length > 0) {
            unit.isPass = NO;
        }
        
        if (unit.itemName != nil &&![unit.itemName isEqual:@""])
            NSLog(@"[SERIAL]unit testResult is = %@, isPass = %hhd",unit.testValue, unit.isPass);
    }
    return unit.testValue;
}


-(void)ClosePort:(NSArray *)parameters
{
    @autoreleasepool
    {
        
        NSString* selector = parameters[0];
        TestItem* unit = parameters[1];
        SerialPort*  port ;
        
        if(unit.isExcluHardware)
        {
            port = [[Config instance].portBox objectForKey:unit.hardwareName] ;
        }
        else
        {
            port = [[Config instance].portBox objectForKey:[[NSString alloc] initWithFormat:@"%@%@",unit.hardwareName,[selector substringFromIndex:(selector.length - 1)]]] ;
        }
        
        [port Close] ;
        [NSThread sleepForTimeInterval:0.5] ;
    }
}

-(void)CloseAllPort
{
    @autoreleasepool {
        
        SerialPort* port ;
        port = [[Config instance].portBox objectForKey:@"INSTRUMENT"] ;
        [port Close] ;
    }
}


- (void) message:(NSString *)msg
{
    [NSAlert alertWithMessageText:msg
                    defaultButton:@"OK"
                  alternateButton:nil
                      otherButton:nil
        informativeTextWithFormat:@"Exception: %@\n", msg];
}

+ (NSString *) parseCommand:(NSString *)cmd
{
    if (cmd == nil || [cmd isEqual:@""]) {
        return @"";
    }
    
    NSString* command = cmd;
    NSRange range = [cmd rangeOfString:@"\\r\\n"];
    
    if (range.length > 0) {
        command = [cmd substringToIndex:range.location];
        command = [command stringByAppendingString:@"\r\n"];
    }
    
    return command;
}

- (NSString *) extractCRC16:(NSString *)message
{
    NSString* crc16 = nil;
    NSRange range, range1;
    
    if (message != nil && message.length > 30) {
        range = [message rangeOfString:@"badcrc-"];
        range1 = [message rangeOfString:@"->"];
        
        if (range.length > 0 && range1.length > 0) {
            // <snwr-fatp-xxxxxxxxxxxx:badcrc-2323->
            range.location = range.location + range.length;
            range.length = 4;
            crc16 = [message substringWithRange:range];
        }
    }
    
    return crc16;
}

-(void)setStopped:(BOOL)stopped
{
    for(SerialPort *sp in [Config instance].portBox.allValues)
    {
//        sp.stopped = stopped;
        [sp setStopped:stopped] ;
    }
}


-(void)sendCommand
{
    SerialPort* port = [[Config instance].portBox objectForKey:@"ControlBoard"] ;
    
    Byte byte[] = {0x16,0x54,0x0d} ;
    NSData* sendData = [[NSData alloc] initWithBytes:byte length:3] ;
    
    if(!port.IsOpen)
    {
        if(![port Open])
        {
            return ;
        }
    }
    
    [port WriteData:sendData] ;

}

-(NSString*)recStr
{
    SerialPort* port = [[Config instance].portBox objectForKey:@"ControlBoard"] ;
    NSString* str = [[NSString alloc] init];
    
    if(!port.IsOpen)
    {
        if(![port Open])
        {
            return @"" ;
        }
    }
    
    str = [port ReadExisting] ;
    
    return str ;
}

//-(NSString *)getCBCommand:(NSString *)result
//{
//    time_t nowTime;
//    time(&nowTime);
//    
//    NSString *password = [controlBit GetSHA1Password:[[[Configuration instance].bufferStore objectForKey:@"[CBNONCE]"] substringFromIndex:2]];
//    
//    NSString *swVersion = @"0";
//    NSString *version = [[[Configuration instance] swVesion] stringByReplacingOccurrencesOfString:@"." withString:@""];
//    version = [version substringFromIndex:1];
//    if (version.length < 4) {
//        version = [swVersion stringByAppendingString:version];
//    }
//    
//    NSString* combinedCommand = [NSString stringWithFormat:@"[CBWRITE-0x0b-%@-%ld-%@-%@]",password,nowTime,version,result];
//    
//    return combinedCommand;
//}

@end
