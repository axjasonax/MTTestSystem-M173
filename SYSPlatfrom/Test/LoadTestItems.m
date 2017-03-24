//
//  LoadTestItems.m
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/17.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import "LoadTestItems.h"
#import "TestItem.h"
#import "Config.h"
#import "JsonOperate.h"

#define GROUPKEY @"GROUP"
#define TIDKEY @"TID"
#define TIMEOUTKEY @"TIMEOUT"
#define UNITKEY @"UNIT"
#define FAILCOUNTKEY @"FAIL_COUNT"
#define PARAM1KEY @"PARAM1"
#define FUNCTIONKEY @"FUNCTION"

@implementation LoadTestItems

+(NSMutableArray*)getTestItems:(NSString *)filePath
{
    NSMutableArray *items = [[NSMutableArray alloc] init] ;
    
    int iD = 1;
    NSArray *fileData ;
    BOOL isCSVFile = NO ;
    
    if([filePath containsString:@".csv"])
    {
         fileData  = [JsonOperate readCSVFile:filePath] ;
        isCSVFile = YES ;
    }
    else
    {
         fileData = [NSArray arrayWithContentsOfFile:filePath];
    }
    
    [items removeAllObjects];
    
    
    if(fileData != nil && ![fileData isEqual:@""])
    {
        for(NSDictionary *dir in fileData)
        {
            float subNum = 0 ;
            TestItem *item = [[TestItem alloc] init] ;
            item =  isCSVFile?[self loadSingleItemZmq:dir]:[self loadSingleItem:dir] ;
            item.uID = [NSNumber numberWithInt:iD] ;
            
            if([[dir objectForKey:@"beforeItems"] count] > 0)
            {
                NSArray *arrBefore = [dir objectForKey:@"beforeItems"] ;
                NSMutableArray *arrbeforeItem = [[NSMutableArray alloc] init] ;
                
                for(NSDictionary *beforeDir in arrBefore)
                {
                    TestItem *beforeItem = isCSVFile?[self loadSingleItemZmq:beforeDir]:[self loadSingleItem:beforeDir] ;
                    [arrbeforeItem addObject:beforeItem] ;
                }
                
                [item setValue:arrbeforeItem forKey:@"beforeItems"] ;
            }
            
            if([[dir objectForKey:@"afterItems"] count] > 0)
            {
                NSArray *arrAfter = [dir objectForKey:@"afterItems"] ;
                NSMutableArray *arrafterItem = [[NSMutableArray alloc] init] ;
                
                for(NSDictionary *afterDir in arrAfter)
                {
                    TestItem *beforeItem = isCSVFile?[self loadSingleItemZmq:afterDir]:[self loadSingleItem:afterDir] ;
                    [arrafterItem addObject:beforeItem] ;
                }
                
                [item setValue:arrafterItem forKey:@"afterItems"] ;
            }
            
            if([[dir objectForKey:@"retryItems"] count] > 0)
            {
                NSArray *arrRetry = [dir objectForKey:@"retryItems"] ;
                NSMutableArray *arrretryItem = [[NSMutableArray alloc] init] ;
                
                for(NSDictionary *retryDir in arrRetry)
                {
                    TestItem *retryItem = isCSVFile?[self loadSingleItemZmq:retryDir]:[self loadSingleItem:retryDir] ;
                    [arrretryItem addObject:retryItem] ;
                }
                
                [item setValue:arrretryItem forKey:@"retryItems"] ;
            }
            
            if([[dir objectForKey:@"subItems"] count] > 0)
            {
                NSArray *arrSub = [dir objectForKey:@"subItems"] ;
                NSMutableArray *arrsubItem = [[NSMutableArray alloc] init] ;
                
                for(NSDictionary *subDir in arrSub)
                {
                    TestItem *subItem = isCSVFile?[self loadSingleItemZmq:subDir]:[self loadSingleItem:subDir] ;
                    
                    if(subItem.itemName != nil && ![subItem.itemName isEqualToString:@""])
                    {
                        subItem.uID = [NSNumber numberWithFloat:iD + subNum/10] ;
                    }
                    
                    [arrsubItem addObject:subItem] ;
                }
                
                [item setValue:arrsubItem forKey:@"subItems"] ;
            }
            
            iD++ ;
            [items addObject:item] ;
        }
    }
    
    return items ;
}

+(NSMutableDictionary*)getDirTestItems:(NSString *)filePath
{
    NSMutableDictionary *dirTestItems = [[NSMutableDictionary alloc] init] ;
    
    NSMutableArray *testItems = [self getTestItems:filePath] ;
    
    for(TestItem *item in testItems)
    {
        [dirTestItems setObject:item forKey:item.itemName] ;
    }
    
    return dirTestItems ;
}


+(TestItem *)loadSingleItem:(NSDictionary *)dirItem
{
    TestItem *item = [[TestItem alloc] init] ;
    item.itemName               = [dirItem objectForKey:@"itemName"] ;
    item.testCommand            = [dirItem objectForKey:@"testCommand"] ;
    item.spec                   = [dirItem objectForKey:@"spec"] ;
    item.fromSpec               = [dirItem objectForKey:@"fromSpec"] ;
    item.toSpec                 = [dirItem objectForKey:@"toSpec"] ;
    item.endStr                 = [dirItem objectForKey:@"endStr"] ;
    item.mutableEndStr          = [dirItem objectForKey:@"mutableEndStr"] ;
    item.mutableSubStr          = [dirItem objectForKey:@"mutableSubStr"] ;
    item.endFormat              = [dirItem objectForKey:@"endFormat"] ;
    item.needLength             = [dirItem objectForKey:@"needLength"] ;
    item.unit                   = [dirItem objectForKey:@"unit"] ;
    item.upper                  = [dirItem objectForKey:@"upper"] ;
    item.lower                  = [dirItem objectForKey:@"lower"] ;
    item.type                   = [dirItem objectForKey:@"type"] ;
    item.bufferName             = [dirItem objectForKey:@"bufferName"] ;
    item.function               = [dirItem objectForKey:@"function"] ;
    item.errorCode              = [dirItem objectForKey:@"errorCode"] ;
    item.isNeedTest             = [[dirItem objectForKey:@"isNeedTest"] boolValue] ;
    item.isNeedClosehardware    = [[dirItem objectForKey:@"isNeedClosehardware"] boolValue] ;
    item.timeout                = [dirItem objectForKey:@"timeout"] ;
    item.maxTestTimes           = [dirItem objectForKey:@"maxTestTimes"] ;
    item.isFailToStop           = [[dirItem objectForKey:@"isFailToStop"] boolValue] ;
    item.parser                 = [dirItem objectForKey:@"parser"] ;
    item.hardwareName           = [dirItem objectForKey:@"hardwareName"] ;
    item.isExcluHardware        = [[dirItem objectForKey:@"isExcluHardware"] boolValue] ;
    item.isNeedReset            = [[dirItem objectForKey:@"isneedRest"] boolValue] ;
    item.pdcaAttributeName      = [dirItem objectForKey:@"pdcaAttributeName"] ;
    item.isCalcBeforeItem       = [[dirItem objectForKey:@"isCalcBeforeItem"] boolValue] ;
    item.isCalcAfterItem        = [[dirItem objectForKey:@"isCalcAfterItem"] boolValue] ;
    item.isParallelTest         = [[dirItem objectForKey:@"isCircleCheck"] boolValue] ;
    item.minTickTimes           = [dirItem objectForKey:@"miniTickTimes"] ;
    
    return item ;
}


+(TestItem *)loadSingleItemZmq:(NSDictionary *)dirItem
{
    TestItem *item = [[TestItem alloc] init] ;
    
    item.itemName                 = [NSString stringWithFormat:@"%@&%@",[dirItem objectForKey:TIDKEY],[dirItem objectForKey:PARAM1KEY]] ;
    item.unit                     = [dirItem objectForKey:UNITKEY] ;
    item.maxTestTimes             = [dirItem objectForKey:FAILCOUNTKEY] ;
    item.timeout                  = [[dirItem objectForKey:TIMEOUTKEY] isEqualToString:@""]?[NSNumber numberWithInt:2980]:[dirItem objectForKey:TIMEOUTKEY] ;
    item.function                 = [dirItem objectForKey:FUNCTIONKEY] ;
    
    return item ;
}

@end
