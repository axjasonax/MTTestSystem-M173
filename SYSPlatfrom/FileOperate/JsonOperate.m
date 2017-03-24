//
//  JsonOperate.m
//  SYSPlatfrom
//
//  Created by Jason_Mac on 2017/3/17.
//  Copyright © 2017年 Jason_Mac. All rights reserved.
//

#import "JsonOperate.h"

@implementation JsonOperate


+(NSMutableDictionary*)readFile:(NSString *)filePath
{
    NSData* data = [NSData dataWithContentsOfFile:filePath] ;
    NSMutableDictionary * dir = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil] ;
    
    return dir ;
}

+(NSMutableDictionary*)analysisContent:(NSString *)content
{
   NSMutableDictionary *dir = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil] ;
    
    return dir ;
}

+(NSMutableDictionary*)analysisNSDataContent:(NSData *)data
{
    NSMutableDictionary *dir = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil] ;
    
    return dir ;
}

+(NSString*)transToJsonFormat:(NSMutableDictionary *)dir
{
    NSData *formatData = [self transToJasonFormatData:dir] ;
    NSString *formatStr = [[NSString alloc] initWithData:formatData encoding:NSUTF8StringEncoding] ;
    
    return formatStr ;
}

+(NSData*)transToJasonFormatData:(NSMutableDictionary *)dir
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:dir options:0 error:nil] ;

    return data ;
}

+(NSMutableArray*)readCSVFile:(NSString*)filePath
{
    NSMutableArray* rtnArr = [[NSMutableArray alloc] init] ;
    
    NSString *contents = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] ;
    NSArray *arr = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] ;
    
    NSArray *keyArray = [arr[0] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";"]] ;

    
    if(arr.count == 0)
    {
        return  nil;
    }
    
    for(int i = 1;i < arr.count;i++)
    {
        if(arr[i] == nil || [arr[i] isEqualToString:@""])
        {
            continue ;
        }
        
        NSString *str = arr[i] ;
        NSArray *timeDataArr = [str componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";"]] ;
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init] ;
        
        if(timeDataArr.count > keyArray.count)
        {
            int k = 0 ;
            k++ ;
        }
        
        
        for(int i = 0; i < timeDataArr.count;i++)
        {
            [dic setObject:timeDataArr[i] forKey:keyArray[i]] ;
        }
        
        [rtnArr addObject:dic] ;
        
    }
    
    return rtnArr ;
}


@end
