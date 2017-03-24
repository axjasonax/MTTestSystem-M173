//
//  CBPlugin.m
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/23.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import "Config.h"
#import "CBPlugin.h"
#import "ControlBits.h"
#import "ZmqItem.h"
#define CBDIRKEY @"CB"

@implementation CBPlugin
{
    BOOL mStopped;
}


- (void)initializeWithParameters:(NSArray *)parameters
{
    
}

- (void)executeWithParameters:(NSArray *)parameters
{
    ZmqItem *item = [parameters objectAtIndex:1] ;
    
    
    if(![[[Config instance].testfunctionDir objectForKey:CBDIRKEY] containsObject:item.itemMethod])
    {
        return ;
    }
    
    SEL aSelector = NSSelectorFromString([NSString stringWithFormat:@"%@:",item.itemMethod]);
    IMP imp = [self methodForSelector:aSelector];
    
    void(*func)(id,SEL,id) = (void *)imp ;
    func(self,aSelector,item) ;
    
}

-(void)rtc:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
//    if([[item.itemArgs objectAtIndex:0] isEqualToString:@"get"])
//    {
//        
//    }
//    else
//    {
//        
//    }
//    
    NSLog(@"CBPlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;
}

-(void)clearlistedcb:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"CBPlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
    time(&end) ;
    item.startTime = start ;
    item.endTime = end ;

}

-(void)writecb:(ZmqItem*)item
{
    time_t start,end = 0 ;
    time(&start) ;
    
    
    NSLog(@"CBPlugin:method:%@ args:%@",item.itemMethod,item.itemArgs) ;
    
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
