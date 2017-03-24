//
//  WavePlugin.m
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/24.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import "WavePlugin.h"
#import "ZmqItem.h"
#import "Config.h"
#define WAVE @"WAVE"

@implementation WavePlugin
{
    BOOL mStopped;
}

- (void)initializeWithParameters:(NSArray *)parameters
{
    
}

- (void)executeWithParameters:(NSArray *)parameters
{
    ZmqItem *item = [parameters objectAtIndex:1] ;
    
    if(![[[Config instance].testfunctionDir objectForKey:WAVE] containsObject:item.itemMethod])
    {
        return  ;
    }
    
    SEL aSelector = NSSelectorFromString([NSString stringWithFormat:@"%@:",item.itemMethod]);
    IMP imp = [self methodForSelector:aSelector];
    
    void(*func)(id,SEL,id) = (void *)imp ;
    func(self,aSelector,item) ;
}


-(void)thdn:(ZmqItem *)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"WavePlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
}


-(void)amplitude:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"WavePlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
}

-(void)frequency:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"WavePlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
}

- (enum eTypePlugin) typePlugin
{
    return FUNCTION;
}


-(void)setStopped:(BOOL)stopped
{
    mStopped = stopped;
}

-(BOOL)stopped
{
    return mStopped;
}


@end
