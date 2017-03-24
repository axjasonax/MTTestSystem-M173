//
//  ClientManage.m
//  SocketTest
//
//  Created by Jason_Mac on 2016/12/27.
//  Copyright © 2016年 Jason_Mac. All rights reserved.
//

#import "Client.h"
#import "HiperTimer.h"
#import "Parser.h"

@interface Client()
{
    NSString *_ipAddress ;
    NSUInteger _port ;
    GCDAsyncSocket *clientSocket ;
    NSString *errorInfo ;
    id delegate ;
    NSMutableString *tempStoreReceiveData ;
    BOOL isConnected ;
}

@end

@implementation Client

-(instancetype)initClient:(NSString *)ipAddress andPort:(NSUInteger)port andDelegate:(id)dele
{
    if(self = [super init])
    {
        _ipAddress = ipAddress ;
        _port = port ;
        errorInfo = @"" ;
        delegate = dele ;
        tempStoreReceiveData = [[NSMutableString alloc] init] ;
        isConnected = NO ;
    }
    
    return self ;
}

-(BOOL)connect
{
    if(isConnected)
    {
        return YES ;
    }
    
    BOOL flag = YES ;
    clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()] ;
    NSError *err = nil ;
    
    if(![clientSocket connectToHost:_ipAddress onPort:_port error:&err])
    {
        flag = NO ;
        errorInfo = err.description ;
        
    }
    else
    {
        isConnected = YES ;
        [clientSocket readDataWithTimeout:-1 tag:0] ;
    }
    
    return flag ;
}

-(BOOL)isConnected
{
    return isConnected ;
}

-(NSString *)getErrorInfo
{
    return errorInfo ;
}

//receive data and store it in tempStoreReceiveData
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *receive = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ;
    [tempStoreReceiveData appendString:receive] ;
    [sock readDataWithTimeout:-1 tag:0] ;
}

-(void)sendData:(NSString *)data
{
    [clientSocket writeData:[data dataUsingEncoding:NSUTF8StringEncoding] withTimeout:1 tag:0] ;
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err
{
    isConnected = NO ;
}


-(NSString *)getAllData
{
    NSString *strRtn = tempStoreReceiveData ;
    [tempStoreReceiveData setString:@""] ;
    
    return strRtn ;
}

-(void)disconnect
{
    [clientSocket disconnect] ;
}

-(NSString*)ReadTo:(NSString *)data timeOut:(double)timeout Interval:(double)interval
{
    if([data length] == 0)
    {
        return @"";
    }
    
    NSRange range = NSMakeRange(-1, 0);
    NSMutableString* result = [[NSMutableString alloc] init];
    HiperTimer* hp = [[HiperTimer alloc] init];
    
    [hp Start];
    
    while (isConnected)
    {
        range = [tempStoreReceiveData rangeOfString:data];
        
        if (range.length > 0) {
            break;
        }
        
        if([hp durationMillisecond] >= timeout * 1000)
        {
            break;
        }
        
        [NSThread sleepForTimeInterval:interval];
    }
    
    [result appendString:tempStoreReceiveData] ;
    [tempStoreReceiveData setString:@""] ;
    
    return result;
}


-(NSString*)ReadRegularLen:(int)len timeOut:(double)timeout Interval:(double)interval
{
    if(len <= 0)
    {
        return @"" ;
    }
    
    NSMutableString* result = [[NSMutableString alloc] init] ;
    
    HiperTimer* hp = [[HiperTimer alloc] init] ;
    [hp Start] ;
    
    while (isConnected) {
        
        if(tempStoreReceiveData.length >= len)
        {
            break ;
        }
        
        if([hp durationMillisecond] >= timeout*1000)
        {
            break ;
        }
        
        [NSThread sleepForTimeInterval:interval] ;
    }
    
    [result appendString:tempStoreReceiveData] ;
    [tempStoreReceiveData setString:@""] ;
    
    return result ;
}

-(NSString*)ReadRegularFormat:(NSString *)format timeOut:(double)timeout Interval:(double)interval
{
    if([format length] == 0)
    {
        return @"";
    }
    
    NSRange range = NSMakeRange(-1, 0);
    NSMutableString* result = [[NSMutableString alloc] init];
    HiperTimer* hp = [[HiperTimer alloc] init];
    NSError* err = [[NSError alloc] init] ;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:format options:0 error:&err];
    
    [hp Start];
    
    while (isConnected)
    {
        range = [regex rangeOfFirstMatchInString:tempStoreReceiveData options:0 range:NSMakeRange(0, tempStoreReceiveData.length)];
        
        if (range.length > 0) {
            break;
        }
        
        if([hp durationMillisecond] >= timeout * 1000)
        {
            break;
        }
        
        [NSThread sleepForTimeInterval:interval];
    }
    
    [result appendString:tempStoreReceiveData] ;
    [tempStoreReceiveData setString:@""] ;
    
    return result;
}

-(NSString*)ReadMutableEndStr:(NSString *)data andSubStr:(NSString *)subStr timeOut:(double)timeout Interval:(double)interval
{
    if([data length] == 0)
    {
        return @"" ;
    }
    
    NSMutableString* result = [[NSMutableString alloc] init] ;
    NSArray* array = [data componentsSeparatedByString:subStr] ;
    HiperTimer* hp = [[HiperTimer alloc] init] ;
    NSRange range ;
    
    while (isConnected)
    {
        for (NSString* str in array)
        {
            range = [tempStoreReceiveData rangeOfString:str] ;
            
            if(range.length > 0)
            {
                break ;
            }
        }
        
        if([hp durationMillisecond] >= timeout)
        {
            break ;
        }
        
        [NSThread sleepForTimeInterval:interval] ;
    }
    
    [result appendString:tempStoreReceiveData] ;
    [tempStoreReceiveData setString:@""] ;
    
    return result ;
}

-(NSString*)infoProcess:(NSString*)infoMsg
{
    NSString* returnValue  ;
    
    return returnValue ;
}

@end
