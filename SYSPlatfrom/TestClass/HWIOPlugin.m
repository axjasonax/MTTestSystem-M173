//
//  HWIO.m
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/23.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import "HWIOPlugin.h"
#import "Config.h"
#import "ZmqItem.h"
#define JWIOKEY @"HWIO"

@implementation HWIOPlugin
{
    BOOL mStopped;
}

- (void)initializeWithParameters:(NSArray *)parameters
{
    
}

- (void)executeWithParameters:(NSArray *)parameters
{
    ZmqItem *item = [parameters objectAtIndex:1] ;
    
    if(![[[Config instance].testfunctionDir objectForKey:JWIOKEY] containsObject:item.itemMethod])
    {
        return  ;
    }
    
    SEL aSelector = NSSelectorFromString([NSString stringWithFormat:@"%@:",item.itemMethod]);
    IMP imp = [self methodForSelector:aSelector];
    
    void(*func)(id,SEL,id) = (void *)imp ;
    func(self,aSelector,item) ;
}

-(void)dmm:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"HWIOPlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
}

-(void)supply:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"HWIOPlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
}

-(void)eload:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"HWIOPlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
}

-(void)measure:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"HWIOPlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
}

-(void)relay:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"HWIOPlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
}

-(void)disconnect:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"HWIOPlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
}

-(void)button:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"HWIOPlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
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
