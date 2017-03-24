//
//  SumaryLogPlugin.m
//  X2AX2B
//
//  Created by hotabbit on 14-8-5.
//  Copyright (c) 2014年 hotabbit. All rights reserved.
//

#import "CSVDataLogPlugin.h"
#import "CSVDataLog.h"
#import "Config.h"
#import "TestItem.h"

@interface CSVDataLogPlugin()
{
    CSVDataLog* _writer;
    NSMutableArray* _items;
    NSMutableArray* allItems ;
}
@end

@implementation CSVDataLogPlugin
{
    BOOL mStopped;
}

- (instancetype) init
{
    if (self = [super init]) {
        _writer = [[CSVDataLog alloc] init];
        _items = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < 4; i++) {
            NSMutableArray* testitem = [[NSMutableArray alloc] init] ;
            [allItems addObject:testitem] ;
        }
        
    }
    
    return self;
}

- (void) initializeWithParameters:(NSArray *)parameters
{
//    NSArray* testItems = [parameters objectAtIndex:1];
    
//    if (testItems != nil) {
//        [_writer createCsvWithTitle:testItems
//                    withStationName:[Configuration instance].stationName
//                     swVersion:[Configuration instance].swVesion
//                     fixtureID:[Configuration instance].fixtureID
//                     productType:[Configuration instance].whichear];
//    }
}

- (enum eTypePlugin) typePlugin
{
    return FUNCTION;
}


-(void)executeWithParameters:(NSArray *)parameters
{
    NSString* selector = parameters[0];
    
    if (selector != nil) {
//        selector isEqualToString:@"commit"
        if ([selector rangeOfString:@"commit"].length > 0) {
            [_writer writeSumary:_items
                    SerialNumber:parameters[2]
                       FixtureID:@""
                       Starttime:[parameters[3] longValue]
                         Endtime:[parameters[4] longValue]
                     StationName:[Config instance].softwareName
                       SWVersion:[Config instance].softwareVersion
             slotNum:[selector substringFromIndex:(selector.length - 1)]];
            [_items removeAllObjects];
        }
//        selector isEqualToString:@"stopped"
        else if([selector rangeOfString:@"stopped"].length > 0)
        {
            [_writer writeSumary:_items
                    SerialNumber:parameters[2]
                       FixtureID:@""
                       Starttime:[parameters[3] longValue]
                         Endtime:[parameters[4] longValue]
                     StationName:[Config instance].softwareName
                       SWVersion:[Config instance].softwareVersion
                            slotNum:[selector substringFromIndex:(selector.length - 1)]];

            
            [_items removeAllObjects];
        }
        else if([selector rangeOfString:@"reset"].length > 0)
        {
            [_items removeAllObjects];
        }
        else {
            TestItem* unit = parameters[1];
            
            if (![unit.itemName isEqual:@""]) {
                if ([unit.testValue rangeOfString:@","].length > 0) {
                    unit.testValue = [unit.testValue stringByReplacingOccurrencesOfString:@"," withString:@" "];
                }
                [_items addObject:unit];
                NSLog(@"[CSV]item result = %@, isPass = %hhd", unit.testValue, unit.isPass);
            }
        }
    }
}

/**************  stoppable implement  ***************/

-(void)setStopped:(BOOL)stopped
{
    mStopped = stopped;
}

-(BOOL)stopped
{
    return mStopped;
}

/****************************************************/

@end
