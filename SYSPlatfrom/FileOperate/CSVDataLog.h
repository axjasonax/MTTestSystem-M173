//
//  SumaryLog.h
//  X2AX2B
//
//  Created by hotabbit on 14-8-5.
//  Copyright (c) 2014年 hotabbit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSVDataLog : NSObject

- (void) createCsvWithTitle:(NSArray *) testItems
            withStationName:(NSString *) stationName
            swVersion:(NSString *) swVersion
            fixtureID:(NSString *) fixtureID
              slotNum:(NSString*) slotNum ;
- (void) writeSumary:(NSArray *)testItems
        SerialNumber:(NSString *)sn
           FixtureID:(NSString *)fixtrueID
           Starttime:(time_t)startTime
             Endtime:(time_t)endTime
         StationName:(NSString *)stationName
           SWVersion:(NSString *)swVersion
             slotNum:(NSString *)slotNum ;

@end
