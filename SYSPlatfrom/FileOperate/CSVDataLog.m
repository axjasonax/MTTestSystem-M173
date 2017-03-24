//
//  SumaryLog.m
//  X2AX2B
//
//  Created by hotabbit on 14-8-5.
//  Copyright (c) 2014年 hotabbit. All rights reserved.
//

#import "CSVDataLog.h"
#import "TestItem.h"
#import "Config.h"
#import "LoadTestItems.h"

@implementation CSVDataLog
{
    NSString* _csvDataLog;
    BOOL mStopped;
}
static bool isLockWriteCSV = NO ;

- (instancetype) init
{
    if (self = [super init]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[Config instance].csvLogFloderPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    
    return self;
}

// 初始化SumaryLog.csv 文件的项
- (void) createCsvWithTitle:(NSArray *)testItems
            withStationName:(NSString *)stationName
             swVersion:(NSString *)version
            fixtureID:(NSString *)fixtureID
            slotNum:(NSString *)slotNum
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dFormatter = [[NSDateFormatter alloc]init];
    dFormatter.dateFormat = @"yyyy-MM-dd";
    
    _csvDataLog = [[NSString alloc]initWithFormat:@"%@/%@_%@.csv",[Config instance].csvLogFloderPath,[Config instance].softwareName, [dFormatter stringFromDate:date]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:_csvDataLog]) {
        return;
    }
    
    NSMutableString* titleStr = [[NSMutableString alloc] init];
    
    [titleStr appendFormat:@"%@,Version%@\r\n", stationName, version];
    
    
    NSString* lineNameStr   = @",Slot,SN,Test Result,List of Fail,Start Time,Stop Time,";
    NSString* upperLimitStr = @"Upper limit,,,,,,";
    NSString* lowerLimitStr = @"Lower limit,,,,,,";
    NSString* unitstr       = @"Unit,,,,,,,";
    
    if([Config instance].slotCount == 1)
    {
        lineNameStr =  @",SN,Test Result,List of Fail,Start Time,Stop Time,";
        upperLimitStr = @"Upper limit,,,,,,";
        lowerLimitStr = @"Lower limit,,,,,,";
        unitstr       = @"Unit,,,,,,";

    }
    
    @try {
        for (TestItem* item in testItems) {
            if (item.itemName == nil || [item.itemName isEqual:@""]) {
                continue;
            }
        
            if (item.itemName != nil && ![item.itemName isEqual:@""]
                ) {
                lineNameStr = [lineNameStr stringByAppendingFormat:@"%@,", [item itemName]];
                if (item.upper == nil && item.lower == nil) {
                    upperLimitStr = [upperLimitStr stringByAppendingString:@"N/A,"];
                    lowerLimitStr = [lowerLimitStr stringByAppendingString:@"N/A,"];
                    unitstr       = [unitstr stringByAppendingString:@"N/A,"];
                }
                else {
                    upperLimitStr = [upperLimitStr stringByAppendingFormat:@"%@,", [item upper]];
                    lowerLimitStr = [lowerLimitStr stringByAppendingFormat:@"%@,", [item lower]];
                    unitstr       = [unitstr stringByAppendingFormat:@"%@,", [item unit]];
                }
            }
        }
        
        [titleStr appendFormat:@"%@\r\n%@\r\n%@\r\n%@\r\n", lineNameStr, upperLimitStr, lowerLimitStr, unitstr];
        
        NSError* error;
        [titleStr writeToFile:_csvDataLog atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        if (error != nil && ![error isEqual:@""]) {
            @throw [error description];
        }

    }
    @catch (NSException *exception) {
        [self performSelectorOnMainThread:@selector(showMsg:)
                               withObject:[exception description]
                            waitUntilDone:YES];
    }
}

// 添加测试数据至SumaryLog.csv文件
- (void) writeSumary:(NSArray *)testItems
        SerialNumber:(NSString *)sn
           FixtureID:(NSString *)fixtrueID
           Starttime:(time_t)startTime
             Endtime:(time_t)endTime
         StationName:(NSString *)stationName
           SWVersion:(NSString *)swVersion
             slotNum:(NSString *)slotNum
{
    while (isLockWriteCSV) {
        [NSThread sleepForTimeInterval:0.1] ;
    }
    
    isLockWriteCSV = YES ;
    
    if (_csvDataLog == nil || ![[NSFileManager defaultManager] fileExistsAtPath:_csvDataLog]) {
        
//        id<EnvPluginForefather> _sysPlugin = (id<EnvPluginForefather>)[[NSClassFromString(@"ScriptPlugin") alloc] init];
//        [_sysPlugin loadPlugin];
        
//        NSArray* arrtestItems = [_sysPlugin getScript];
        NSArray *arrtestItems = [LoadTestItems getTestItems:[[Config instance].testFilePath objectAtIndex:0]] ;
//         NSArray *arrtestItems = [LoadTestItems getTestItems:[Config instance].testplanFilePath] ;;
        
        
        [self createCsvWithTitle:arrtestItems
                 withStationName:stationName
                  swVersion:swVersion
                    fixtureID:fixtrueID
                         slotNum:slotNum];
    }
    
    BOOL flagResult = YES;
    NSMutableString* sumaryData = [[NSMutableString alloc] initWithFormat:@",%@,%@",slotNum,sn];
    
    if([Config instance].slotCount == 1)
    {
        sumaryData = [[NSMutableString alloc] initWithFormat:@",%@",sn] ;
    }
    
    NSMutableString* tmpData = [[NSMutableString alloc] init];
    NSMutableString* failStr = [[NSMutableString alloc] init];
    
    for (TestItem* item in testItems) {
        if (item.itemName == nil || [item.itemName isEqual:@""]) {      // 过滤掉无测试名的项
            continue;
        }
        
        NSString* rst = item.testValue;
        
        if (rst == nil || [rst isEqual:@""]) {
            rst = @"Null";
        }
        
        [tmpData appendFormat:@",%@", rst];
        flagResult &= item.isPass;
        
        if (!item.isPass) {
            [failStr appendFormat:@" & %@", item.itemName];
        }
    }
    
    [sumaryData appendFormat:@",%@,%@,%@,%@%@\n", flagResult ? @"PASS" : @"FAIL",
        failStr, [CSVDataLog gettime:startTime], [CSVDataLog gettime:endTime], tmpData];
    
    NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingAtPath:_csvDataLog];
    
    if (fileHandle != nil) {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[sumaryData dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    }
    
    _csvDataLog = nil;
    isLockWriteCSV = NO ;
}


+ (NSString *) gettime:(time_t)time
{
    struct tm* tmStrct = localtime(&time);
    NSString *strTime = [NSString stringWithFormat:@"%d-%d-%d %d:%d:%d",
                        (tmStrct->tm_year + 1900), (tmStrct->tm_mon + 1), tmStrct->tm_mday,
                        tmStrct->tm_hour, tmStrct->tm_min, tmStrct->tm_sec];
    return strTime;
}

+ (NSString *) getFailStr:(NSArray *)failItems
{
    NSMutableString* failStr = [[NSMutableString alloc] initWithString:failItems[0]];
    
    for (int i = 1; i < failItems.count; i++) {
        [failStr appendFormat:@" & %@", failItems[i]];
    }
    
    return failStr;
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
