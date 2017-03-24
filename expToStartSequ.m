//
//  expToStartSequ.m
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/22.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import "expToStartSequ.h"
#import "Config.h"

@interface expToStartSequ()
{
    NSString *expFilePath ;
    NSTask *task ;
}

@end

@implementation expToStartSequ


-(instancetype)init
{
    if(self = [super init])
    {
        expFilePath = [[NSBundle mainBundle ] pathForResource:[Config instance].expFilepath ofType:@"exp"];
//        expFilePath = [Config instance].expFilepath ;
    }
    
    return self ;
}

-(void)start:(int)stationNum
{
    NSString* command = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %i",expFilePath,@"jason",@"123",[Config instance].sequenceFilepath,@"1",stationNum - 1];
    
    [NSThread detachNewThreadSelector:@selector(runtask:) toTarget:self withObject:command] ;
//    [self runtask:command] ;
}

-(void)close
{
    NSString *cmd = [NSString stringWithFormat:@"kill %d", task.processIdentifier];
    system([cmd UTF8String]);
}

-(void)runtask:(NSString*)cmd
{
    NSPipe *pipe = [NSPipe pipe] ;
    task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/expect"];
    
    NSArray* arguments = [NSArray arrayWithArray:[cmd componentsSeparatedByString:@" "]];
//  NSArray* arguments = [NSArray arrayWithObjects:cmd , nil];
    [task setArguments:arguments];
//    [task setStandardOutput:pipe];
//    [task setStandardError:pipe];

    
    [task launch];
    
    
    [NSThread sleepForTimeInterval:0.1] ;
//    NSData* data=[[pipe fileHandleForReading] readDataToEndOfFile];
  //
//    NSLog(@"Pipe return value is:%@",pipeValue) ;
//    [task waitUntilExit];
    
//    if (0 == [task terminationStatus]) {
//        NSLog(@"PySend ok.");
//        return YES;
//        
//    }
//    
//    NSLog(@"PySend fail.");
//    
//    return NO;
}

@end
