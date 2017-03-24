//
//  MutablePlugin.m
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/23.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import "MutablePlugin.h"
#import "ZmqItem.h"
#import "Config.h"
#define MUTABLETEST @"MutableTest"
#define COMPARESN @"<<comparesn>>"

@implementation MutablePlugin
{
    BOOL mStopped;
}

- (void)initializeWithParameters:(NSArray *)parameters
{
    
}

- (void)executeWithParameters:(NSArray *)parameters
{
    ZmqItem *item = [parameters objectAtIndex:1] ;
    
    if(![[[Config instance].testfunctionDir objectForKey:MUTABLETEST] containsObject:item.itemMethod])
    {
        return  ;
    }
    
    if([item.itemMethod isEqualToString:COMPARESN])
    {
        [self comparsesn:item] ;
        
        return ;
    }
    
    SEL aSelector = NSSelectorFromString([NSString stringWithFormat:@"%@:",item.itemMethod]);
    IMP imp = [self methodForSelector:aSelector];
    
    void(*func)(id,SEL,id) = (void *)imp ;
    func(self,aSelector,item) ;
}


-(void)delay:(ZmqItem *)item
{
    time_t start,end = 0 ;
    time(&start) ;
    [NSThread sleepForTimeInterval:(NSTimeInterval)[[item.itemArgs objectAtIndex:0] floatValue]/1000] ;
    NSLog(@"MutablePlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
    item.itemValue = @"-PASS-" ;
}

-(void)vendor_id:(ZmqItem *)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    NSLog(@"MutablePlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
    item.itemValue = @"-PASS-" ;
}

-(void)detect:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"MutablePlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
}

-(void)paser:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"MutablePlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
}

-(void)diags:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"MutablePlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
}

-(void)efidelect:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"MutablePlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
}

-(void)frequency:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"MutablePlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
}

-(void)iefised:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"MutablePlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
}

-(void)mobilerestore:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"MutablePlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
}

-(void)potassium:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"MutablePlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
}

-(void)powersequencedelta:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"MutablePlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
}

-(void)comparsesn:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"MutablePlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
}

-(void)powersequencemonitor:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"MutablePlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
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
